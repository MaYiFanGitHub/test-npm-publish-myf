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
    print "----正在构造版本...----" "[32m"
    version=`npm version $publish_type`

    if [ $? -eq 1 ]; then
        print "----构造失败----" "[31m"
        git reset --soft $1
        exit 1
    fi
    
    print "----构造版本成功，最新的版本号为$version----" "[32m"
}

# 发包
function publish() {
    print "----正在发布版本...----" "[32m"
    npm publish --registry=http://registry.npm.baidu-int.com
    if [ $? -eq 0 ]; then
        sleep 1
        version=`npm view @baidu/publish-test-mayifan version`
        print "----版本发布成功，当前版本号$version----" "[32m"
        print "----请使用 npm i @baidu/med-ui@$version -S --registry=http://registry.npm.baidu-int.com 更新依赖----" "[32m"
        
        if [ "$env_type" = "local" ]; then
            git reset --soft $1
            commit_code
            print "----如需发布正式版本，请执行XXX命令----" 
        fi
    else
        # git tag -d $version1
        print "----发布失败...----" "[31m"

        # if [ "$2" != "" ]; then
        #     git reset --soft $2
        # fi
        exit 1
    fi
}

# 登陆
function login() {
    print "----正在尝试登陆NPM...----" "[32m"
    npm whoami >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        print "----当前npm用户未登陆，正在使用默认账号进行登陆！----" "[32m"
        (echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login
        if [ $? -eq 1 ]; then
            print "---NPM自动登陆失败...----" "[31m"
            exit 1
        fi
    fi
    print "----NPM账号登陆成功----" "[32m"
}

# 收集icafeID与commit信息
function gather_info() {
    read -t 30 -p "请输入本次修改的icafeId:" icafe_id
    read -t 60 -p "请输入本次修改的信息:" commet_info

    if [ -z $icafe_id  ]; then
        print "----icafeId 不能为空...----" "[31m"
        exit 1
    fi
    if [ -z $commet_info  ]; then
        print "----本次修改信息不能为空...----" "[31m"
        exit 1
    fi
}

# 获取最新代码
function pull_code() {
    print "---正在拉取最新代码...----" "[31m"

    git pull
    sleep 100
    if [ $? -eq 1 ]; then
        print "---拉取最新代码失败...----" "[31m"
        exit 1
    fi

    if [ "`git diff --check`" != "" ]; then
        print "---请解决冲突后重试...----" "[31m"
        exit 1
    fi
}

# 提交代码
function commit_code() {
    git add .
    if [ "`git diff --cached --name-only`" != "" ]; then
        git commit -m "icafeId: $icafe_id, 修改信息：$commet_info"
    fi
    if [ $? -eq 1 ]; then
        print "---提交代码失败...----" "[31m"
        exit 1
    fi
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
    fi
    print "----编译成功...----"
}

# 获取提交文件2
# git add . 1

# STAGE_FILE=1
if [ "`git diff --cached --name-only`" != "" ]; then
    STAGE_FILE=0
fi



env_type=$1 # 环境类型
publish_type=$2 # 发包类型
icafe_id="" # icafeID
commet_info="" # 提交信息

if [ "$env_type" = "local" -a "$publish_type" = "prerelease" ]; then
    # 测试包
    build   #编译
    login   #登陆
    gather_info #收集icafe信息
    preCommitId=`git rev-parse HEAD`
    commit_code #提交代码
    build_version $preCommitId   #构建版本
    publish $preCommitId
elif [ "$env_type" = "local" -a "$publish_type" != "prerelease" ]; then
    # 发CR
    gather_info
    commit_code
    cr
    if [ $? -eq 1 ]; then
        print "----发起CR失败，请执行git pull 验证代码是否冲突...----" "[31m"
        exit 1
    fi
else
    # 流水线
    build
    login
    build_version
    echo '123'
fi