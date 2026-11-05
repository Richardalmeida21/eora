'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const vm = require('node:vm');
const START = 'function prefetchVariationPages';
const END = 'function reorganizeEoraProductInfo';
function hash(value) { const keys = Object.keys(value).sort(); return crypto.createHash('sha256').update(JSON.stringify(keys.map(k => [k, value[k]]))).digest('hex'); }
function validateScripts(html) {
  for (const match of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi)) {
    if (/\bsrc\s*=|\btype\s*=\s*["'](?:application\/json|application\/ld\+json)/i.test(match[1])) continue;
    try { new vm.Script(match[2]); } catch (error) { throw new Error('Description script syntax error: ' + error.message); }
  }
}
function patchHtml(html, helper) {
  const start = html.indexOf(START);
  if (start < 0) return html;
  if (html.indexOf(START, start + START.length) !== -1) throw new Error('Ambiguous helper');
  const end = html.indexOf(END, start + START.length);
  if (end < 0 || html.indexOf(END, end + END.length) !== -1) throw new Error('Invalid end marker');
  let result = html.slice(0, start) + helper + html.slice(end);
  result = result.replace(/<iframe\s+src=(?=[^>]*\bembedUrl\b)/g, '<iframe loading="lazy" data-eora-video-src=');
  validateScripts(result);
  return result;
}
function buildPlan(products, options = {}) {
  const ids = options.targetIds;
  if (!Array.isArray(ids) || !ids.length || ids.length > 100 || ids.some(x => !Number.isSafeInteger(x) || x <= 0) || new Set(ids).size !== ids.length) throw new Error('Invalid targetIds');
  const byId = new Map(products.map(p => [p.id, p]));
  if (ids.some(id => !byId.has(id))) throw new Error('Allowlist product missing');
  const source = fs.readFileSync(path.join(options.root, 'maxivertice.html'), 'utf8');
  const start = source.indexOf(START), end = source.indexOf(END, start);
  if (start < 0 || end < 0) throw new Error('Template helper marker missing');
  const helper = source.slice(start, end);
  const rows = [];
  for (const id of ids) {
    const p = byId.get(id), original = p.description;
    if (!original || typeof original !== 'object' || Array.isArray(original)) throw new Error('Invalid description');
    const updated = {};
    for (const [locale, html] of Object.entries(original)) {
      if (typeof html !== 'string') throw new Error('Invalid description locale');
      updated[locale] = patchHtml(html, helper);
    }
    if (JSON.stringify(updated) !== JSON.stringify(original)) rows.push({id, originalDescriptionHash: hash(original), description: updated});
  }
  return {rows};
}
async function applyPlan({plan, request, backupDir, apply = false}) {
  if (!apply) return {dryRun: true, results: plan.rows.map(row => ({id: row.id, status: 'planned'}))};
  if (!backupDir || typeof request !== 'function') throw new Error('Backup directory and request required');
  fs.mkdirSync(backupDir, {recursive: true});
  const results = [];
  for (const row of plan.rows) {
    const url = '/products/' + row.id;
    const fresh = await request('GET', url);
    if (!fresh || fresh.id !== row.id || hash(fresh.description) !== row.originalDescriptionHash) {results.push({id: row.id, status:'stale'}); return {stopped:true, results};}
    const backupPath = path.join(backupDir, row.id + '.json');
    fs.writeFileSync(backupPath, JSON.stringify({id: row.id, originalDescriptionHash: row.originalDescriptionHash, description: fresh.description}), {flag:'wx', mode:0o600});
    await request('PUT', url, {description: row.description});
    const verified = await request('GET', url);
    if (!verified || verified.id !== row.id || hash(verified.description) !== hash(row.description)) {results.push({id:row.id,status:'verification-failed',backupPath});return {stopped:true,results};}
    results.push({id:row.id,status:'verified',backupPath});
  }
  return {stopped:false,results};
}
module.exports = {buildPlan, applyPlan};
