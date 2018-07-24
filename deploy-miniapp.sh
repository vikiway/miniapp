#!/bin/bash
 
msg() {
    printf '%b\n' "$1" >&2
}
 
info()
{
    msg "[INFO] $1"
}
 
 
error_exit() {
    msg "[ERROR] ${1}${2}"
    exit 1
}
 
exec_cmd()
{
  echo "[执行命令] $1"
  $1
  if [ "$?" != "0" ]; then
    error_exit "命令执行失败: 错误码为 $?"
  fi
}
 
 
MINI_GIT="git@xxx.xxx.xxx.com:xxxx/xxxx-miniapp.git"
ROOT="/Users/test"
MINI_HOME_ROOT="${ROOT}/xxxx-miniapp"
 
git_clone(){
    if [ -d ${MINI_HOME_ROOT} ]; then
      echo "文件夹${MINI_HOME_ROOT}存在，执行git checkout"
      exec_cmd "cd ${MINI_HOME_ROOT}"
      exec_cmd "git clean -df"
      exec_cmd "git checkout ${branch}"
      exec_cmd "git pull"
    else
      echo "文件夹${MINI_HOME_ROOT}不存在，执行git clone"
      exec_cmd "cd ${ROOT}"
      exec_cmd "git clone -b ${branch} ${MINI_GIT}"
    fi
}
 
 
# 生成开发版二维码
# 这里直接执行小程序cli的命令
uplaod_for_preview()
{
    exec_cmd "/Applications/wechatdevtool.app/Contents/Resources/app.nw/bin/cli -o"
    port=$(cat "/Users/test/Library/Application Support/微信web开发者工具/Default/.ide")
    echo "微信开发者工具运行在${port}端口"
    echo "调用http://127.0.0.1:${port}/open"
    return_code=$(curl -sL -w %{http_code} http://127.0.0.1:${port} -o /open)
    if [ $return_code == 200 ]; then
        echo "返回状态码200，devtool启动成功！"
    else
    echo "返回状态码${return_code}，devtool启动失败"
        exit 1
    fi
    priview_="http://127.0.0.1:${port}/preview?projectpath=%2FUsers%2Ftest%2Fxxxx-miniapp"
    login_="http://127.0.0.1:${port}/login"
    return_code2=$(curl -s -w "%{http_code}" -o /dev/null ${priview_})
    if [ $return_code2 == 200 ]; then
        echo "返回状态码200，开始生成二维码预览！"
        exec_cmd "pwd"
        exec_cmd "wget  -O  /Users/test/.jenkins/workspace/xxxx-miniapp/$BUILD_ID.png ${priview_}"
    elif [ $return_code2 == 400 ]; then
        echo "返回状态码400预览失败，请先登录, 再重新执行编译！"
        exec_cmd "wget  -O  /Users/test/.jenkins/workspace/xxxx-miniapp/$BUILD_ID.png ${login_}"//这里输入Jenkins的workspace路径，为了后续的二维码展示
    else
        echo "返回状态码${return_code}，生成预览二维码失败！"
        exit 1
    fi
}
 
info "发布开发版！"
git_clone
#生成二维码
uplaod_for_preview
info "预览成功！请扫描二维码进入开发版！"
