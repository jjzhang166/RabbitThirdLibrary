#注意：修改后的本文件不要上传代码库中

#注意：运行前需要设置 msvc 工具链
#   msvc 工具链的环境变量可用下面方法设置：  
#   先从菜单栏中起动vs2013编译命令行工具：  
#   C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\Shortcuts  
#   VS2013 x86 本机工具命令提示  
#   在命令行下，启动msys。 
# 启动 msys 环境：
#        c:\MinGW\msys\1.0\msys.bat
# 或者启动 msys2 环境:
#        c:\msys32\ming32_shell.bat
#   注意，msys中不要装link工具，否则会导致出错。如果有link工具，暂时把它命名成其它名称。  
#   然后再进入脚本目录：`cd ${RABBITRoot}/ThirdLibrary/build_script`。再运行你想运行的编译脚本。例如： `./build.sh` 

#bash用法：  
#   在用一sh进程中执行脚本script.sh:
#   source script.sh
#   . script.sh
#   注意这种用法，script.sh开头一行不能包含 #!/bin/sh
#   相当于包含关系

#   新建一个sh进程执行脚本script.sh:
#   sh script.sh
#   ./script.sh
#   注意这种用法，script.sh开头一行必须包含 #!/bin/sh  

#需要设置下面变量：
if [ -z "$QT_ROOT" ]; then
    QT_ROOT=/c/Qt/Qt5.7.1_msvc/5.7/msvc2015 #QT 安装根目录,默认为:${RABBITRoot}/ThirdLibrary/windows_msvc/qt
fi
JOM=make #设置 QT make 工具 JOM
MAKE="nmake"
if [ -z "$RABBIT_CLEAN" ]; then
    RABBIT_CLEAN=TRUE #编译前清理
fi
#RABBIT_BUILD_STATIC="static" #设置编译静态库，注释掉，则为编译动态库
#RABBIT_USE_REPOSITORIES="FALSE" #下载指定的压缩包。省略，则下载开发库。
if [ -z "${RABBIT_MAKE_JOB_PARA}" ]; then
    RABBIT_MAKE_JOB_PARA="-j`cat /proc/cpuinfo |grep 'cpu cores' |wc -l`"  #make 同时工作进程参数
    if [ "$RABBIT_MAKE_JOB_PARA" = "-j1" ];then
        RABBIT_MAKE_JOB_PARA=
    fi
fi

if [ -z "${RABBIT_ARCH}" ]; then
    if [ "X64" = ${Platform} ]; then
        RABBIT_ARCH=x64
    else
        RABBIT_ARCH=x86
    fi
fi
#安装前缀
if [ -n "${RABBITRoot}" ]; then
    RABBIT_BUILD_PREFIX=${RABBITRoot}/ThirdLibrary/windows_msvc
else
    RABBIT_BUILD_PREFIX=`pwd`/../windows_msvc    #修改这里为安装前缀 
fi
RABBIT_BUILD_PREFIX=${RABBIT_BUILD_PREFIX}_${RABBIT_ARCH}

if [ "$RABBIT_BUILD_STATIC" = "static" ]; then
    RABBIT_BUILD_PREFIX=${RABBIT_BUILD_PREFIX}_static
fi
if [ ! -d ${RABBIT_BUILD_PREFIX} ]; then
    mkdir -p ${RABBIT_BUILD_PREFIX}
fi

if [ -z "$RABBIT_USE_REPOSITORIES" ]; then
    RABBIT_USE_REPOSITORIES="TRUE" #下载开发库。省略，则下载指定的压缩包
fi

if [ -z "$QT_ROOT" -a -d "${RABBIT_BUILD_PREFIX}/qt" ]; then
    QT_ROOT=${RABBIT_BUILD_PREFIX}/qt
fi
QMAKE=qmake
if [ -n "${QT_ROOT}" ]; then
    QT_BIN=${QT_ROOT}/bin       #设置用于 android 平台编译的 qt bin 目录
    QMAKE=${QT_BIN}/qmake       #设置用于 unix 平台编译的 QMAKE。
                            #这里设置的是自动编译时的配置，你需要修改为你本地qt编译环境的配置.
fi

TARGET_OS=`uname -s`
if [ -z "${GENERATORS}" ]; then
    if [ "${RABBIT_ARCH}" = "x64" ]; then
        GENERATORS="Visual Studio 14 2015 Win64"
    else
        GENERATORS="Visual Studio 14 2015"
    fi
fi
if [ "$GENERATORS" = "Visual Studio 12 2013" \
    -o "$GENERATORS" = "Visual Studio 12 2013 Win64" ]; then
   VC_TOOLCHAIN=12
   MSVC_VER=1800
fi
if [ "$GENERATORS" = "Visual Studio 14 2015" \
    -o "$GENERATORS" = "Visual Studio 14 2015 Win64" ]; then
   VC_TOOLCHAIN=14
   MSVC_VER=1900
fi
if [ "$GENERATORS" = "Visual Studio 15 2017" \
    -o "$GENERATORS" = "Visual Studio 15 2017 Win64" ]; then
   VC_TOOLCHAIN=15
   MSVC_VER=2000
fi

export PATH=${RABBIT_BUILD_PREFIX}/bin:${RABBIT_BUILD_PREFIX}/lib:${QT_BIN}:$PATH
export PKG_CONFIG=pkg-config
export PKG_CONFIG_PATH=${RABBIT_BUILD_PREFIX}/lib/pkgconfig
export PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH}

echo "---------------------------------------------------------------------------"
echo "RABBIT_BUILD_PREFIX:$RABBIT_BUILD_PREFIX"
echo "QT_BIN:$QT_BIN"
echo "QT_ROOT:$QT_ROOT"
echo "PKG_CONFIG_PATH:$PKG_CONFIG_PATH"
echo "PKG_CONFIG_SYSROOT_DIR:$PKG_CONFIG_SYSROOT_DIR"
echo "PATH=$PATH"
echo "---------------------------------------------------------------------------"
