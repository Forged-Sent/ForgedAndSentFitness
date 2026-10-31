// Cross-platform, allowlisted MCP stdio launcher for the project.
// No Firebase cloud server and no remote shell download. Node 18+.
import {spawn} from 'node:child_process';
import {existsSync} from 'node:fs';
import {homedir} from 'node:os';
import {join, resolve} from 'node:path';
import {fileURLToPath} from 'node:url';

export function commandFor(tool, platform=process.platform, home=homedir()){
  const win = platform === 'win32';
  if (tool === 'dart') {
    if (win) {
      // Native SDK executable avoids cmd.exe searching the working directory for dart.bat.
      const dartExe = join(home, 'develop', 'flutter', 'bin', 'cache', 'dart-sdk', 'bin', 'dart.exe');
      if (!existsSync(dartExe)) {
        throw new Error('Pinned Flutter Dart SDK missing. Run SETUP-WINDOWS.cmd before starting the Dart MCP.');
      }
      return {command:dartExe,args:['mcp-server']};
    }
    const local = join(home, 'develop', 'flutter', 'bin', 'dart');
    return {command:existsSync(local) ? local : 'dart',args:['mcp-server']};
  }
  if (tool === 'playwright') {
    return win ? {command:'cmd.exe',args:['/d','/c','npx -y @playwright/mcp@0.0.83 --browser=chrome']} :
      {command:'npx',args:['-y','@playwright/mcp@0.0.83','--browser=chrome']};
  }
  if (tool === 'maestro') {
    return win ? {command:'cmd.exe',args:['/d','/c','maestro mcp']} :
      {command:'maestro',args:['mcp']};
  }
  throw new Error('Unsupported local MCP tool. Firebase cloud MCP is forbidden.');
}
function launch(){
  const tool=process.argv[2];
  let spec;
  try {spec=commandFor(tool);}
  catch(err){process.stderr.write(String(err.message)+'\n');process.exitCode=2;return;}
  const paths=[
    join(homedir(),'develop','flutter','bin'),
    '/opt/homebrew/bin','/usr/local/bin',join(homedir(),'.local','bin')
  ];
  if (process.platform==='win32'){
    paths.push(join(process.env.APPDATA || '', 'npm'));
    paths.push(join(process.env.LOCALAPPDATA || '', 'Programs','Maestro','bin'));
  }
  const env={...process.env, PATH:paths.join(process.platform==='win32'?';':':')+
    (process.platform==='win32'?';':':')+(process.env.PATH||'')};
  const child=spawn(spec.command,spec.args,{stdio:'inherit',env,windowsHide:true});
  child.on('error',err=>{process.stderr.write('MCP launch failed: '+err.message+'\n');process.exitCode=1;});
  child.on('exit',(code,signal)=>{
    process.exitCode=typeof code==='number'?code:1;
    if(signal) process.stderr.write('MCP exited by signal '+signal+'\n');
  });
  process.on('SIGINT',()=>child.kill('SIGINT'));
  process.on('SIGTERM',()=>child.kill('SIGTERM'));
}
if(process.argv[1] && resolve(process.argv[1])===fileURLToPath(import.meta.url))launch();
