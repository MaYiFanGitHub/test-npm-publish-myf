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

        if [ "$env_type" = "local" ]; then
            git reset --soft $1
            git reset HEAD
        fi
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
        print "----请使用 npm i @baidu/med-ui@$version --save --registry=http://registry.npm.baidu-int.com 更新依赖----" "[32m"
        
        if [ "$env_type" = "local" ]; then
            git reset --soft $1
            git reset HEAD
            print "----如需发布正式版本，请执行XXX命令----" 
        fi
    else
        print "----发布失败...----" "[31m"

        if [ "$env_type" = "local" ]; then
            git reset --soft $1
            git reset HEAD
            git checkout ./package.json
            git checkout ./package-lock.json
        fi
        exit 1
    fi
}

# 登陆
function login() {
    print "----正在验证是否已登陆NPM...----" "[32m"
    npm whoami >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        if [ "$env_type" = "local" ]; then
            print "---NPM未登陆,请在下方进行登陆...----" "[31m"
            npm login
        else
            print "----当前npm用户未登陆，正在使用默认账号进行登陆！----" "[32m"
            (echo "mayifan" && sleep 1 && echo "qq9320996688" && sleep 1 && echo "83964472@qq.com") | npm login
        fi
    fi
    print "----NPM账号已登陆----" "[32m"
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

# 提交代码
function commit_code() {
    git add .
    if [ "`git diff --cached --name-only`" != "" ]; then
        git commit -m "icafeId: $icafe_id, 修改信息：$commet_info"
    fi
    if [ $? -eq 1 ]; then
        print "---commit提交代码失败...----" "[31m"
        git reset HEAD
        exit 1
    fi
}

# CR
function cr() {
    commit_code

    preCommitId=`git rev-parse HEAD` #上次版本ID
    date=`git log --pretty=format:"%cd" --date=format:'%Y-%m-%d %H:%M:%S' $preCommitId -1`
    name=`git log --pretty=format:"%an" $preCommitId -1`
    note=`git log --pretty=format:"%s" $preCommitId  -1`
    log_path=`pwd`/changelog.inc
    echo "\n $date\n $name \n $note \n" >> $log_path

    git reset --soft HEAD^
    commit_code

    git push origin HEAD:refs/for/master
    if [ $? -eq 0 ]; then
        # echo -i "1i\127.0.0.1\n123\n456" >> $log_path
        # sed -i '' -e '1i \
        # FE: wangkai37' $log_path
        # sed -i '' -e '1i \
        # ###2019-03-01' $log_path
        # sed -i '' -e '1i \
        # NOTE: 新增测试组件' $log_path


        echo 122345
        # 其他（例如推送远程机器）
    else
        print "----发起CR失败----" "[31m"
        exit 1
    fi
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

env_type=$1 # 环境类型
publish_type=$2 # 发包类型
icafe_id="" # icafeID
commet_info="" # 提交信息

if [ "$env_type" = "local" -a "$publish_type" = "prerelease" ]; then
    # 测试包
    build   #编译
    login   #登陆
    gather_info #收集icafe信息
    preCommitId=`git rev-parse HEAD` #上次版本ID,用于回退
    commit_code #提交代码
    build_version $preCommitId   #构建版本
    publish $preCommitId #发包
elif [ "$env_type" = "local" -a "$publish_type" != "prerelease" ]; then
    # 发CR1
    gather_info
    cr
else
    # 流水线
    build
    login
    build_versionafsfa
    echo '123'
fi