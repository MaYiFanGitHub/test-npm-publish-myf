#!/usr/bin/env node
const exec = require('child_process').exec;
const { exit } = require('process');
const chalk = require('chalk');

/* 命令打印输出 */
const __print = work => {
    work.stdout.on('data', d => {
        console.log(chalk.green('[INFO] '), d, '\n');
    });
    work.stderr.on('data', d => {
        console.log(chalk.red('[ERR] ' + d + '\n'));
        exit(1);
    });
};

/* 判断登陆 */
const isLogin = (success, error) => {
    let cmd = '(echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login';
    __print(
        exec(cmd, (err, stdout, stderr) => {
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
    console.log(chalk.green('√'), '同步远程最新代码...\n')
    let cmd = 'git pull --rebase';
    __print(
        exec(cmd, (err, stdout, stderr) => {
            console.log('err+++++', err);
            if (!err) {
                success();
            } else {
                error();
            }
        })
    );
}
gitPull(() => { console.log(111); });
// isLogin(() => {console.log(1);}, () => {console.log(2);});


// let cmd = '(echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login';
// let cmd = 'npm whoami';

// __print(ls);


