'use strict';
const fs=require('node:fs');
const crypto=require('node:crypto');
const {Writable}=require('node:stream');

async function publishTemplate({client,localPath}) {
    const contents=fs.readFileSync(localPath);
    if(contents.length===0||contents.length>2*1024*1024)throw new Error('Invalid title template size');
    const expected=crypto.createHash('sha256').update(contents).digest('hex');
    const staging='.product-name-pt-data.pending.tpl';
    const destination='product-name-pt-data.tpl';
    await client.cd('/snipplets');
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
    // RNFR/RNTO replaces the complete sibling file. Never delete the live file first.
    await client.rename(staging,destination);
    return {bytes:contents.length,sha256:expected};
}

async function main() {
    if(!process.env.FTP_USER||!process.env.FTP_PASSWORD)throw new Error('Missing FTP credentials');
    const {Client}=require('basic-ftp');
    const client=new Client(30000);
    try {
        await client.access({host:'ftp.nuvemshop.com.br',user:process.env.FTP_USER,password:process.env.FTP_PASSWORD,
            secure:true,secureOptions:{minVersion:'TLSv1.2'}});
        const result=await publishTemplate({client,localPath:process.argv[2]});
        console.log('Verified and published '+result.bytes+' bytes of private Portuguese title data.');
    } finally {client.close();}
}
module.exports={publishTemplate};
if(require.main===module)main().catch(()=>{console.error('Title upload failed; inspect workflow before assuming refresh completed.');process.exitCode=1;});
