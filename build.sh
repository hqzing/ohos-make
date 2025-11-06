#!/bin/sh
set -e

# 准备 ohos-sdk
# OpenHarmony 发布页（https://gitcode.com/openharmony/docs/blob/master/zh-cn/release-notes/OpenHarmony-v6.0-release.md）里面的 6.0 release 版本 ohos-sdk 并未包含代码签名工具
# 为了使用代码签名工具，这里只能从 OpenHarmony 官方社区的每日构建流水线（https://ci.openharmony.cn/workbench/cicd/dailybuild/dailylist）下载主干版本的 ohos-sdk
sdk_download_url="https://cidownload.openharmony.cn/version/Daily_Version/OpenHarmony_6.0.0.56/20251027_150702/version-Daily_Version-OpenHarmony_6.0.0.56-20251027_150702-ohos-sdk-public.tar.gz"
curl $sdk_download_url -o ohos-sdk-public.tar.gz
mkdir -p /opt/ohos-sdk
tar -zxf ohos-sdk-public.tar.gz -C /opt/ohos-sdk
cd /opt/ohos-sdk/linux
unzip -q native-*.zip
unzip -q toolchains-*.zip
cd - >/dev/null

# 设置交叉编译所需的环境变量
export OHOS_SDK=/opt/ohos-sdk/linux
export AS=${OHOS_SDK}/native/llvm/bin/llvm-as
export CC="${OHOS_SDK}/native/llvm/bin/clang --target=aarch64-linux-ohos"
export CXX="${OHOS_SDK}/native/llvm/bin/clang++ --target=aarch64-linux-ohos"
export LD=${OHOS_SDK}/native/llvm/bin/ld.lld
export STRIP=${OHOS_SDK}/native/llvm/bin/llvm-strip
export RANLIB=${OHOS_SDK}/native/llvm/bin/llvm-ranlib
export OBJDUMP=${OHOS_SDK}/native/llvm/bin/llvm-objdump
export OBJCOPY=${OHOS_SDK}/native/llvm/bin/llvm-objcopy
export NM=${OHOS_SDK}/native/llvm/bin/llvm-nm
export AR=${OHOS_SDK}/native/llvm/bin/llvm-ar
export CFLAGS="-D__MUSL__=1"
export CXXFLAGS="-D__MUSL__=1"

# 编译 make
curl -L -O https://mirrors.ustc.edu.cn/gnu/make/make-4.4.tar.gz
tar -zxf make-4.4.tar.gz
cd make-4.4
./configure --prefix=/opt/make-4.4-ohos-arm64 --host=aarch64-linux
make -j$(nproc)
make install
cd ..

# 履行开源义务，将 license 随制品一起发布
cp make-4.4/COPYING /opt/make-4.4-ohos-arm64/

# 代码签名。做这一步是为了现在或以后能让它运行在 OpenHarmony 的商业发行版——HarmonyOS 上。
/opt/ohos-sdk/linux/toolchains/lib/binary-sign-tool sign -inFile /opt/make-4.4-ohos-arm64/bin/make -outFile /opt/make-4.4-ohos-arm64/bin/make -selfSign 1

# 打包最终产物
cd /opt/
tar -zcf make-4.4-ohos-arm64.tar.gz make-4.4-ohos-arm64
