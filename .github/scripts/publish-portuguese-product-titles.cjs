'use strict';
const fs=require('node:fs');
const crypto=require('node:crypto');
const {Writable}=require('node:stream');

async function publishTemplate({client,localPath,bootstrap=false}) {
    const contents=fs.readFileSync(localPath);
    if(contents.length===0||contents.length>2*1024*1024)throw new Error('Invalid title template size');
    const expected=crypto.createHash('sha256').update(contents).digest('hex');
    const staging='.product-name-pt-v2-data.pending.tpl';
    const destination='product-name-pt-v2-data.tpl';
    const backup='product-name-pt-v2-data.backup.tpl';
    await client.cd('/snipplets');
    const exists=(await client.list()).some(file=>file.name===destination);
    if(bootstrap&&exists)return {bytes:contents.length,bootstrapAlreadyPresent:true};
    await client.uploadFrom(localPath,staging);
    const chunks=[];let size=0;
    const target=new Writable({write(chunk,encoding,callback){
        size+=chunk.length;
        if(size>2*1024*1024){callback(new Error('Unexpected downloaded template size'));return;}
        chunks.push(Buffer.from(chunk));callback();
    }});
    await client.downloadTo(target,staging);
    const actual=crypto.createHash('sha256').update(Buffer.concat(chunks)).digest('hex');
    if(actual!==expected)throw new Error('Uploaded title template verification failed');
    // Nuvemshop forbids rename over an existing destination. The stable theme
    // helper can read the previous complete snapshot during this short switch.
    if(exists){await client.remove(backup,true);await client.rename(destination,backup);}
    try {await client.rename(staging,destination);}
    catch(error){
        if(exists)await client.rename(backup,destination).catch(()=>{});
        throw error;
    }
    return {bytes:contents.length,sha256:expected};
}

async function verifyNativeFallback({client,fetcher=fetch}) {
    const live='product-name-pt-v2-data.tpl',backup='product-name-pt-v2-data.backup.tpl';
    const readTitle=async path=>{
        const response=await fetcher('https://www.eoraeyewear.com'+path+'?oe_fallback_check='+Date.now(),{
            headers:{'Cache-Control':'no-cache'},signal:AbortSignal.timeout(30000)});
        const html=await response.text();
        const title=html.match(/<h2[^>]*class="[^"]*js-product-name[^"]*"[^>]*>([\s\S]*?)<\/h2>/)?.[1].trim();
        if(!response.ok||!title)throw new Error('Native fallback page did not render a title');
        return title;
    };
    const expected=await readTitle('/produtos/beam/');
    await client.cd('/snipplets');
    await client.remove(backup,true);
    await client.rename(live,backup);
    try {
        if((await client.list()).some(file=>file.name===live))throw new Error('Fallback probe requires the live file to be absent');
        for(const path of ['/us/products/beam/','/es/productos/beam/']){
            if(await readTitle(path)!==expected)throw new Error('Native fallback title did not match Portuguese');
        }
        console.log('Native English and Spanish titles verified while the live data file was absent.');
    }finally{await client.rename(backup,live);}
}

async function main() {
    if(!process.env.FTP_USER||!process.env.FTP_PASSWORD)throw new Error('Missing FTP credentials');
    const {Client}=require('basic-ftp');
    const client=new Client(30000);
    try {
        await client.access({host:'ftp.nuvemshop.com.br',user:process.env.FTP_USER,password:process.env.FTP_PASSWORD,
            secure:true,secureOptions:{minVersion:'TLSv1.2'}});
        if(process.argv.includes('--verify-fallback'))await verifyNativeFallback({client});
        else {
            const result=await publishTemplate({client,localPath:process.argv[2],bootstrap:process.argv.includes('--bootstrap')});
            console.log('Verified and published '+result.bytes+' bytes of private Portuguese title data.');
        }
    } finally {client.close();}
}
module.exports={publishTemplate,verifyNativeFallback};
if(require.main===module)main().catch(error=>{
    let message=String(error.message);
    for(const secret of [process.env.FTP_USER,process.env.FTP_PASSWORD])if(secret)message=message.split(secret).join('[REDACTED]');
    console.error('Title upload failed: '+message);
    process.exitCode=1;
});
