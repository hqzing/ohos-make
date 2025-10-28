# ohos-make
本项目为 OpenHarmony 平台编译了 make，并发布预构建包。

这个 make 不依赖 libc 以外的任何库，因此单独一个 make 二进制可执行文件就能运行。

## 获取预构建包
前往 [release 页面](https://github.com/Harmonybrew/ohos-make/releases) 获取。

## 从源码构建
需要用一台 Linux x64 服务器来运行项目里的 build.sh，以实现 make 的交叉编译。

这里以 Ubuntu 24.04 x64 作为示例：
```sh
sudo apt update && sudo apt install -y build-essential unzip jq
./build.sh
```
