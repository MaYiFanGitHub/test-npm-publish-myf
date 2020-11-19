#!/usr/bin/env node
const exec = require('child_process').exec;
const spawn = require('child_process').spawn;
const { exit } = require('process');
const chalk = require('chalk');
const { appendFile } = require('fs');
// 123123
// asfasd
/* 命令打印输出 */
const __print = work => {
    work.stderr.on('data', d => {
        console.log(chalk.red('[ERR] ' + d + '\n'));
        // exit(1);
    });
    work.stdout.on('data', d => {
        console.log(chalk.green('[INFO] '), d, '\n');
    });

    work.on('close', (code) => {
        console.log(`子进程退出，退出码 ${code}`);
    });

};
// 阿斯顿发顺丰的

/* 登陆 */
const login = (success, error) => {
    console.log(chalk.green('[INFO]'), '正在登陆...\n')
    let cmd = '(echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login';
    __print(
        exec(cmd, (err, stdout, stderr) => {
            console.log(err, stdout, stderr);
            if (!err) {
                success();
            } else {
                error();
            }
        })
    );
};


/* git pull */
const gitPull = (success, error) => {
    console.log(chalk.green('[INFO]'), '同步远程最新代码...\n')
    // let cmd = 'git pull';
    __print(
        exec('git pull')
    );
}

/* npm version */
const npmVersion = (success, error) => {
    console.log(chalk.green('[INFO]'), '正在构建版本...\n')
    let cmd = 'npm version patch';
    __print(
        exec(cmd, (err, stdout, stderr) => {
            if (!err) {
                success();
            } else {
                error();
            }
        })
    );
}

/* npm publish */
const npmPublish = (success, error) => {
    console.log(chalk.green('[INFO]'), '正在发布版本...\n')
    let cmd = 'npm publish';
    __print(
        exec(cmd, (err, stdout, stderr) => {
            if (!err) {
                success();
            } else {
                error();
            }
        })
    );
}
// login(() => {})
gitPull(() => { console.log(111); });
// npmVersion(()=>{})
// npmPublish(() => {})
// isLogin(() => {console.log(1);}, () => {console.log(2);});
/// 

// let cmd = '(echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login';
// let cmd = 'npm whoami';

// __print(ls);


