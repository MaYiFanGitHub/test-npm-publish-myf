# 输出
function print() {
    color="[33m"
    if [ $2 ]; then
        color=$2
    fi
    echo "\n\033$color$1\033[0m\n"
}

# 构造版本发包
function build_version() {
    if [ $2 -eq 0 ]; then
        preCommitId=`git rev-parse HEAD`
        git commit -m '构造版本临时提交'
    fi
    username=`npm whoami`

    print "----正在构造版本...----" "[32m"
    version=`npm version $1 -m "$username update to %s"`

    if [ $? -eq 0 ]; then
        print "----构造版本成功，最新的版本号为$version----" "[32m"
        echo $preCommitIdgi
        publish $version $preCommitId
        exit 0
    else
        print "----构造失败----" "[31m"
        
        if [ $2 -eq 0 ]; then
            git reset --soft $preCommitId
        fi
        exit 1
    fi
}

# 发包
function publish() {
    version=$1
    print "----正在发布版本 $version...----" "[32m"
    npm publish --registry=http://registry.npm.baidu-int.com
    # npm publish
    if [ $? -eq 0 ]; then
        now_version=`npm view test-publish-npm-myf version`
        print "----版本发布成功，当前版本号$version----" "[32m"
        print "----请使用 npm i @baidu/med-ui@${version#*v} -S --registry=http://registry.npm.baidu-int.com 更新依赖----" "[32m"
        print "----请自行确认本次更改的代码，是否要推送到远程仓库（git push origin HEAD:refs/for/master）----" 

        exit 0
    else
        git tag -d $version
        print "----发布失败...----" "[31m"

        if [ "$2" != "" ]; then
            git reset --soft $2
        fi
        exit 1
    fi
}

# 登陆
function login() {
    npm whoami >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        print "----当前npm用户未登陆，正在使用默认账号进行登陆！----"
        (echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login
    fi
}

# 收集icafeID与commit信息
function gather_info() {
    read -t 30 -p "请输入icafeId:" icafe_id
    read -t 60 -p "请输入本次修改的信息:" commet_info
}

# 提交代码
function commit_code() {
    git reset --soft origin/master

    git add .
    git commit -m '111111'
}

# CR
function cr() {
    # 写入changelog
    log_path=`pwd`/changelog.inc
    echo -i "1i\127.0.0.1\n123\n456" >> $log_path

    commit_code
    git push origin HEAD:refs/for/master
}

# 编译
function build() {
    build_res=`npm run build:components | sed -n '/COMPILE ERROR/p'`
    if [ -n "$build_res" ]; then
        print "----编译失败...----" "[31m"
        print "$build_res" "[31m"
        exit 1
    else
        print "----编译成功...----"
    fi
}

# 获取提交文件
# git add .

# STAGE_FILE=1
if [ "`git diff --cached --name-only`" != "" ]; then
    STAGE_FILE=0
fi



# 环境类型
env_type=$1
# 发包类型
publish_type=$2
if [ "$env_type" = "local" -a "$publish_type" = "prerelease" ]; then
    # 测试包
    gather_info

elif [ "$env_type" = "local" -a "$publish_type" != "prerelease" ]; then
    # 发CR
    cr
    if [ $? -eq 1 ]; then
        print "----发起CR失败，请执行git pull 验证代码是否冲突...----" "[31m"
        exit 1
    fi
else
    # 流水线
    build build_version
    echo '123'
fi