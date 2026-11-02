'use strict';
// Stable entry point. Each invocation resolves the currently selected release.
const {spawn}=require('node:child_process');
const runtime=require('./opencli-runtime.cjs');
// OpenCLI resolves ~/.opencli via os.homedir(): USERPROFILE on Windows, HOME on macOS/Linux. Point both at the isolated home.
const opencliHome=require('node:path').join(__dirname,'..','state','opencli-home');
const child=spawn(process.execPath,[runtime.entry(),...process.argv.slice(2)],{stdio:'inherit',windowsHide:true,shell:false,env:{...Object.fromEntries(Object.entries(process.env).filter(([k])=>/^(PATH|PATHEXT|SYSTEMROOT|WINDIR|COMSPEC|USERPROFILE|APPDATA|LOCALAPPDATA|TEMP|TMP|TMPDIR|HOMEDRIVE|HOMEPATH|HOME|USER|LOGNAME|LANG|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)$/i.test(k))),USERPROFILE:opencliHome,HOME:opencliHome}});
child.on('error',()=>{process.stderr.write('OpenCLI启动失败，旧版仍保留。\n');process.exitCode=1;});
child.on('exit',code=>{process.exitCode=code??1;});
