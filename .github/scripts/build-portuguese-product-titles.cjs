'use strict';
const fs=require('node:fs');
const path=require('node:path');

function validate(rows) {
    if(!Array.isArray(rows)||rows.length===0)throw new Error('Empty or invalid catalog; previous title data must remain in place');
    const ids=new Set();
    for(const row of rows) {
        if(!Number.isSafeInteger(row?.id)||row.id<=0||ids.has(row.id))throw new Error('Invalid or duplicate product ID');
        ids.add(row.id);
        if(typeof row.name?.pt!=='string'||!row.name.pt.trim())throw new Error('Missing Portuguese product title for '+row.id);
    }
}
const quoted=value=>"'"+value.replace(/\\/g,'\\\\').replace(/'/g,"\\'")+"'";
// Keep Twig delimiters out of literal source, including titles containing "%}".
const literal=value=>{
    const parts=value.split(/([{}%])/).filter(Boolean).map(quoted);
    return parts.length>1?'('+parts.join(' ~ ')+')':parts[0]||"''";
};
function buildTemplate(rows) {
    validate(rows);
    const entries=[...rows].sort((a,b)=>a.id-b.id).map(row=>'    '+literal(String(row.id))+': '+literal(row.name.pt)).join(',\n');
    return "{# Generated privately from the Portuguese catalog. Do not edit manually. #}\n"+
        "{%- macro get(product_id, fallback, current_language, languages) -%}\n"+
        "{%- set language = current_language.code | default(current_language.lang) | default(current_language.id) | default('') -%}\n"+
        "{%- if not language -%}{%- for enabled_language in languages -%}{%- if enabled_language.active -%}{%- set language = enabled_language.lang | default(enabled_language.code) | default(enabled_language.id) -%}{%- endif -%}{%- endfor -%}{%- endif -%}\n"+
        "{%- if language starts with 'pt' or not language -%}{{- fallback | raw -}}{%- else -%}\n"+
        "{%- set titles = {\n"+entries+"\n} -%}\n"+
        "{{- titles[product_id ~ ''] | default(fallback) | raw -}}\n"+
        "{%- endif -%}\n{%- endmacro -%}\n";
}
async function readCatalog(request) {
    const rows=[];
    for(let page=1;page<=50;page++) {
        const data=await request('/products?per_page=200&page='+page+'&sort_by=created-at-ascending&fields=id,name');
        if(!Array.isArray(data))throw new Error('Unexpected catalog response');
        rows.push(...data);
        if(data.length<200){validate(rows);return rows;}
    }
    throw new Error('Catalog pagination limit exceeded; previous title data must remain in place');
}
function createReader({store,token,fetcher=fetch}) {
    if(!/^\d+$/.test(store||'')||!token||/[\r\n]/.test(token))throw new Error('Missing or invalid Nuvemshop credentials');
    let previous=0;
    return async endpoint=>{
        if(!/^\/products\?/.test(endpoint))throw new Error('Only catalog reads are supported');
        for(let attempt=0;attempt<4;attempt++) {
            const wait=550-(Date.now()-previous);
            if(wait>0)await new Promise(resolve=>setTimeout(resolve,wait));
            previous=Date.now();
            const response=await fetcher('https://api.nuvemshop.com.br/v1/'+store+endpoint,{
                method:'GET',redirect:'error',signal:AbortSignal.timeout(30000),headers:{
                    Authentication:'bearer '+token,'User-Agent':'Eora Portuguese product title snapshot'
                }
            });
            if(response.ok)return response.json();
            const status=response.status;
            const retry=Number(response.headers.get('retry-after'));
            await response.body?.cancel();
            if((status===429||status>=500)&&attempt<3){
                await new Promise(resolve=>setTimeout(resolve,Math.min(30000,Math.max(1000,retry>0?retry*1000:1000*2**attempt))));continue;
            }
            throw new Error('Catalog read returned HTTP '+status);
        }
    };
}
async function main() {
    const reader=createReader({store:process.env.NUVEMSHOP_STORE_ID,token:process.env.NUVEMSHOP_ACCESS_TOKEN});
    const rows=await readCatalog(reader);
    const output=process.argv[process.argv.indexOf('--output')+1];
    if(!process.argv.includes('--output')||!output)throw new Error('--output destination required');
    const template=buildTemplate(rows);
    fs.mkdirSync(path.dirname(output),{recursive:true});
    fs.writeFileSync(output+'.tmp',template,{encoding:'utf8',mode:0o600});
    fs.renameSync(output+'.tmp',output);
    console.log('Prepared Portuguese title data for '+rows.length+' products; no catalog fields changed.');
}
module.exports={buildTemplate,readCatalog,createReader};
if(require.main===module)main().catch(error=>{console.error(error.message);process.exitCode=1;});
