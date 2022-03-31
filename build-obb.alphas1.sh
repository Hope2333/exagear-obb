#!/bin/env bash
# snap.version=202203211246

channel=bionic
osch=ubuntu
br=devel
#release=$1

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
pkgurl="https://github.com/Hope2333/exagear-obb/releases/download/0.1.0alpha1/base-all.obb"
# 基础包可以是来自本地（制作完成后放入相对该脚步本的/build/packaging，重命名为base.zip
#
#
# 幽零来源（现用包和历史包）
# 0.1.0 
#https://github.com/Hope2333/exagear-obb/releases/download/0.1.0/base.zip
# 愚人节特供版(0.1.0)
#https://github.com/Hope2333/exagear-obb/releases/download/0.1.0alpha1/base-all.obb
# 0.0.1026
#https://github.com/Hope2333/exagear-obb/releases/download/0.0.1026/base-all.zip
#download base base-minimal1.zip URL
    
    

#
ver="tree-s1 0.1.0-alpha"
#############################
# 以下不希望被改变，改了容易运行出问题
# 主程序部分

main () {
      set_env $@
  if   [ "$#" == "0" ]
   then
    printf "%s\n" "${RED}Error${BLUE}: ${RESET}No additional options!"
    help
  else
    case $@ in
    c | -c | -clean | clean | --clean)
        clean-all
    ;;
    baseurl | --baseurl)
        
    ;;
    O | -O | Output | --Output)
        
    ;;
    *.*)
        #pass
        clean
        config_mainzip
        test -d wine-$br-i386 || config_wine-$br-i386
        test -d wine-$br || config_wine-$br
        test -d winehq-$br || config_winehq-$br
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
        TEMP_FILE=".build.sh"
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
        
}

download ()
{
    test -d $downloads || mkdir -p $downloads
    test -f $downloads/$(basename $2) || wget -O $downloads/$(basename $2) ${3:-$2}
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
                *) printf "Error4!"&&exit ;;
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
    printf "%s\n" "${RESET}ExaGear ED cache crector file builder ${BLUE}[exagear-obb]v1.0"
    printf "%s\n" "${RESET}  Usage: $0 ${YELLOW}[${BOLD}options${RESET}${YELLOW}]"
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
    printf "%s\n" "${RESET}ExaGear ED 数据包制作工具 ${BLUE}[exagear-obb]v1.0"
    printf "%s\n" "${RESET}   用法: $0 ${YELLOW}[${BOLD}选项${RESET}${YELLOW}]"
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

pass ()
{
    set +x
    echo " "
    read -s -p "Enter your Password:" pass
    echo " "
    echo "Starting..."
    echo " "
    set -xe
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
    0
}

config_wine-$br-i386 ()
{
    mkdir -p wine-$br-i386
    cd wine-$br-i386
    download wine-$br-i386 wine-$br-i386-$pkgver.deb https://dl.winehq.org/wine-builds/$osch/dists/${channel}/main/binary-i386/wine-$br-i386_${pkgver}~${channel}-1_i386.deb
    cd ..
}

config_wine-$br ()
{
    mkdir -p wine-$br
    cd wine-$br
    download wine-$br wine-$br-$pkgver.deb https://dl.winehq.org/wine-builds/$osch/dists/${channel}/main/binary-i386/wine-$br_${pkgver}~${channel}-1_i386.deb
    cd ..
}

config_winehq-$br ()
{
    mkdir -p winehq-$br
    cd winehq-$br
    download winehq-$br winehq-$br-$pkgver.deb https://dl.winehq.org/wine-builds/$osch/dists/${channel}/main/binary-i386/winehq-$br_${pkgver}~${channel}-1_i386.deb
    cd ..
}

pkgmake ()
{
    cd $pkgdir
    #echo -e "'$pass\n"|sudo zip --symlink -rq9 ../wine-dev-$pkgver.zip .
    sudo zip --symlink -rq9 ../wine-dev-$pkgver.zip .
    clean
    cd ..
    #echo -e "$pass\n"|sudo rm -rf $pkgdir
    rm -rf $pkgdir
}

#All
main $@