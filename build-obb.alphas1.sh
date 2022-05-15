#!/bin/env bash
# snap.version=202205081246
# 脚本设计者/创作者：（幽零小喵）hope2333
# 使用脚本前必须与作者取得联系，禁止滥用，其他遵循GPL3协议
# 与脚本作者联系方式：
#       QQ : 3238998313
#   E-mail : 3238998313@qq.com
#            hope2333me@gmail.com

# 设置匹配基础包的版本
#osch=ubuntu channel=bionic
#osch=ubuntu channel=xenial
#osch=debian channel=bullseye
#br=devel
#release=$1

#############################
# 目标系统软件员源
ossource="https://dl.winehq.org/wine-builds/"
# 官方源
# ossource="https://dl.winehq.org/wine-builds/"
###
# 下载工具
#dlmg=curl

############################# 未落实mod_add
# 希望打包的格式
pkgmod=0
## 独立的打包方式
# 0 base: 仅一个基础rootfs
# o opt: 分离opt和主基础包（不包括wine） 
#
opt=

## 系列: 数字加法叠加*仅识别数字
# 1 tfm: 分离rootfs基础包和tfm
# 2 execwp: 容器壁纸补丁
# 4 guest: 分离rootfs主包和wine容器客包
tfm=
execwp=
guest=

#############################
# 基础包来源
# pkgurl="https://?/#file"
# pkgurl="file:///data1/exagear-data/BRa4/v04/02/base-patched-minimal.azb"
# 基础包可以是来自本地（制作完成后放入相对该脚步本的/build/packaging，重命名为base.dzp
#
# 幽零不再提供基包来源，且将基包必源
# 需要请与作者联系
#download base base-minimal1.bzp URL
    
    

#
ver="0.2.0 (tree-s1)"
#############################
# 以下不希望被改变，改了运行容易出问题
#set="-e"
set="-x +e"
# 主程序部分




main () {
      set $set
      set_env $@
  if   [ "$#" == "0" ]
   then
    error 3
    help
  else
    case $1 in
    c | -c | -clean | clean | --clean)
        clean-all
    ;;
    *.*)
        #pass
        clean
        testpkg
        config_mainzip
        test -d wine-$br-i386 || config_wine-i386
        test -d wine-$br || config_wine
        test -d winehq-$br || config_winehq
        pkgmake
    ;;
    *version )printf "%s\n" "${BLUE}exagear-obb${GREEN}${ver}"&&printf "%s\n"
    ;;
    -h* | --h* | *)
         help
    ;;
    esac
   fi
}

set_env() {
    #Base
        sourcedir=$(cd $(dirname $0) && pwd)
        basedir=$sourcedir/build
        downloads=$basedir/packaging
        tools=$basedir/tools
        #release=$1
        pkgdir=$sourcedir/pkg
        pkgver=$1
        rootdir=$PWD
        TEMP_FILE=".building.sh"
        pkgrel
    #Colors
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        PURPLE=$(printf '\033[35m')
        CYAN=$(printf '\033[36m')
        RESET=$(printf '\033[m')
        BOLD=$(printf '\033[1m')
    #Launguage
       case $LANG in
        zh_CN*) conf_printf-zh_CN;;
        en_US*) conf_printf-en_US;;
        *)      conf_printf-en_US;;
       esac
    #Things
        brb=$br
        if [ -n "$channel" ];then true;else channel=bionic;fi
        if [ -n "$osch" ];then true;else osch=ubuntu;fi
        if [ -n "$2" ];then br1=true;else true;fi
        if [ -n "$brb" ];then br2=true;else true;fi
        if [ -n "$branch" ];then br3=true;else true;fi
        bra=${2}${br}${branch};brg=${#bra}
        if [ -n "$br1""$br2""$br3" ];then brn=true;else br=devel;fi
        if [ "$brg" -gt 4 ];then brn=true;else br=devel;fi
        if [ -n "$brn" ];then br=${2}${br}${branch} ;else true;fi
        if [ -n "$pkgmod" ];then true;else pkgmod=0;fi
        if [ -n "$ossource" ];then oss="$ossource/$osch/dists/";else oss="https://dl.winehq.org/wine-builds/$osch/dists/";fi
    #Packages
        pkgwine="${oss}${channel}/main/binary-i386/wine-${br}_${pkgver}~${channel}${_pkgrel}_i386.deb"
        pkgwinei="${oss}${channel}/main/binary-i386/wine-$br-i386_${pkgver}~${channel}${_pkgrel}_i386.deb"
        pkgwinehq="${oss}${channel}/main/binary-i386/winehq-${br}_${pkgver}~${channel}${_pkgrel}_i386.deb"


}

pkgrel ()
{
    if [ -n "$pkgrel" ];then _pkgrel=-$pkgrel;else _pkgrel=-1;fi

}

testpkg () {
    testdeb=$(curl -Is $pkgwinehq |awk 'NR==1 { print $2 }')
    case $testdeb in
     10*) msg11 等待中;;
     20*) msg3 已找到指定wine版本;;
     30*) msg7 这是个链接重定向，状态码[$testdeb];;
     400) ;;
     401) ;;
     402) ;;
     403) ;;
     404) ;; #
     405) ;;
     406) ;;
     407) ;;
     408) ;;
     409) ;;
     #
     
     500) ;; #
     502) ;; #
     504) ;; #
     
     
     
     
     
     esac
}
tpkg () {
    true
}

download ()
{
    test -d $downloads || mkdir -p $downloads
    test -f $downloads/$(basename $2) || wget -O $downloads/$(basename $2) ${3:-$2} || error dler $1
    #rm -rf $1
    case $2 in
        *.deb)
            test -e /usr/bin/dpkg && packdeb=dpkg || true
            test -e /usr/bin/bsdtar && packdeb=bsdtar || true
            test -e /data/data/com.termux/files/usr/bin/dpkg && packdeb=dpkg tmux=true || true
            case $packdeb in
                dpkg)
                    dpkg --extract $downloads/$(basename $2) $pkgdir ;;
                bsdtar)
                    bsdtar -xf $downloads/$(basename $2)
                    cd $pkgdir
                    bsdtar -xf $basedir/$1/data.tar.xz
                    cd $basedir/$1/ ;;
                *) error 2;;
            esac
            ;;
        *.zip)
            unzip -q $downloads/$(basename $2) || true ;;
        *)
            tar xf $downloads/$(basename $2) ;;
    esac
}

help() {
  case $LANG in
    zh_CN*) help-zh_CN;;
    en_US*) help-en_US;;
    *)      help-en_US;;
  esac
}

help-en_US() {
    printf "%s\n" "${RESET}ExaGear ED cache crector file builder ${BLUE}[exagear-obb]v${ver}"
    printf "%s\n" "${RESET}  Usage: $0 ${YELLOW}[${BOLD}WineHQ version${RESET}${YELLOW}] ${YELLOW}(${BOLD}WineHQ branch${RESET}${YELLOW})"
    printf "%s\n"
    printf "%s\n" "${RESET}Optional options${GREEN}:"
    printf "%s\n" "    ${PURPLE}--baseurl${GREEN} ${YELLOW}\"URL\"    ${RESET}Change rootfs download form default url to your ${GREEN}<${YELLOW}URL${GREEN}>${RESET}."
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}c${GREEN})${PURPLE}lean          ${RESET}Clean all files with download ${GREEN}[${CYAN}Alone${GREEN}]${RESET}."
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}h${GREEN})${PURPLE}elp           ${RESET}Display help documentation ${GREEN}[${CYAN}Alone${GREEN}]${RESET}."
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}O${GREEN})${PURPLE}utput ${GREEN}<${BLUE}dir${GREEN}>   ${RESET}Select the directory of the product export."
    printf "%s\n" "    ${PURPLE}--version          ${RESET}Display this software version ${GREEN}[${CYAN}Alone${GREEN}]${RESET}."
    printf "%s\n"
    printf "%s\n" "${RESET}Necessary options for making packages${GREEN}:"
    printf "%s\n" "    ${GREEN}<${RESET}Numbers${GREEN}>          ${RESET}Specifies the version of WineHQ for making the target."
    printf "%s\n"
}

help-zh_CN() {
    printf "%s\n" "${RESET}ExaGear ED 数据包制作工具 ${BLUE}[exagear-obb]v${ver}"
    printf "%s\n" "${RESET}   用法: $0 ${YELLOW}[${BOLD}WineHQ version${RESET}${YELLOW}] ${YELLOW}(${BOLD}WineHQ branch${RESET}${YELLOW})"
    printf "%s\n"
    printf "%s\n" "${RESET}可选的${GREEN}:"
    printf "%s\n" "    ${PURPLE}--baseurl${GREEN} ${YELLOW}\"网址\"    ${RESET}更改基础包的来源地址 ${GREEN}<${YELLOW}网址${GREEN}>${RESET}。"
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}c${GREEN})${PURPLE}lean           ${RESET}清除下载缓存 ${GREEN}[${CYAN}独立${GREEN}]${RESET}。"
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}h${GREEN})${PURPLE}elp            ${RESET}显示帮助（救命根本不会写QwQ）${GREEN}[${CYAN}独立${GREEN}]${RESET}。"
    printf "%s\n" "    ${PURPLE}-${RESET}-${GREEN}(${RESET}O${GREEN})${PURPLE}utput ${GREEN}<${BLUE}目录${GREEN}>   ${RESET}打包到一个目录（保存到）。"
    printf "%s\n" "    ${PURPLE}--version           ${RESET}显示工具版本号 ${GREEN}[${CYAN}独立${GREEN}]${RESET}。"
    printf "%s\n"
    printf "%s\n" "${RESET}用于制作数据包必须的${GREEN}:"
    printf "%s\n" "    ${GREEN}<${RESET}数值x.x${GREEN}>          ${RESET}选择要生成的WineHQ的版本（目前仅支持开发版）。"
    printf "%s\n"
}

conf_printf-en_US() {
    #Error
    e3_t="${RESET}${RED}Error3${BLUE}: ${RESET}No additional options!"
    e3="Print simplified help documentation"
    #Main

}

conf_printf-zh_CN() {
    #Error
    e3_t="${RESET}${RED}错误3${BLUE}: ${RESET}没有输入任何选项!"
    e3="开始列出简化帮助内容"
    e4_t="${RESET}${RED}错误4${BLUE}: ${RESET}没有输入任何选项!"
    #Main

}

pass ()
{
    set +x
    echo " "
    read -s -p "Enter your Password:" pass
    echo " "
    echo "Starting..."
    echo " "
    set $set
}

error ()
{
    #set +x
    case $1 in
     dler) dler $2;;
    3) err 3;;
    *) err 4;;
    esac
}

dler () {
    case $1 in
       base) et=$e30_t e1=$e30;err;;
       wine-$br-i386) rm -f $downloads/wine-$br-i386-$channel-$pkgver.deb || true;et=${1}$e31_t e1=${1}${e31_1} e2=${e31_1} ;err ;exit 31;;
       wine-$br ) err 32 $1;;
       winehq-$br ) err 32 $1;;
    esac
}

 err(){
  printf "%s\n"
  printf "%s\n" "   ${et}"
  printf "%s\n" "${BOLD}${YELLOW}   --------------------------------------------------"
  printf "%s\n" "   ${e1}"
  if [ -n "$e2" ];then printf "%s\n" "   ${e2}";else true;fi
  if [ -n "$e3" ];then printf "%s\n" "   ${e3}";else true;fi
  if [ -n "$e4" ];then printf "%s\n" "   ${e4}";else true;fi
  if [ -n "$e5" ];then printf "%s\n" "   ${e5}";else true;fi
 }

clean ()
{
    mkdir -p $downloads
    mv $downloads $rootdir/downloads
    test -z $pkgver || rm -rf $basedir
    test -z $pkgver || rm -rf $pkgdir
    test -d $basedir || mkdir $basedir
    test -d $pkgdir || mkdir $pkgdir
    cd $basedir
    mv $rootdir/downloads $downloads
}

clean-all ()
{
    rm -rf $basedir
    rm -rf $pkgdir
}


config_mainzip ()
{
    mkdir -p base
    cd base
    download base base.zip $pkgurl
    #download base base.zip URL
    mv ./* $pkgdir
    cd ..
}

mod_add ()
{
    case $pkgmod in
        0) ;;
        1) ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        6) ;;
        7) ;;
        o*|O*) ;;
    esac
}

config_wine-i386 ()
{
    mkdir -p wine-$br-i386
    cd wine-$br-i386
    download wine-$br-i386 wine-$br-$channel-i386-$pkgver.deb $pkgwinei
    cd ..
}

config_wine ()
{
    mkdir -p wine-$br
    cd wine-$br
    download wine-$br wine-$br-$channel-$pkgver.deb $pkgwine
    cd ..
}

config_winehq ()
{
    mkdir -p winehq-$br
    cd winehq-$br
    download winehq-$br winehq-$br-$channel-$pkgver.deb $pkgwinehq
    cd ..
}

pkgmake ()
{
    cd $pkgdir
    #echo -e "'$pass\n"|sudo zip --symlink -rq9 ../wine-dev-$pkgver.zip .
    sudo zip --symlink -rq9 ../wine-$br-$pkgver.obb .
    clean
    cd ..
    #echo -e "$pass\n"|sudo rm -rf $pkgdir
    rm -rf $pkgdir
}

#All
main $@
