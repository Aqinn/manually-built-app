# manually-built-app

**参考 2BAB《Android 构建与架构》实现。**
使用 Android Studio 创建的 Android Application 工程，并去掉 Gradle 默认添加的外部依赖及其它相关代码。
目的是仅使用 Android SDK + JDK，而非 Gradle + AGP 的方式构建一个 APK，熟悉 APK 的构建流程。

## 步骤

### 1. 环境变量

配置 ANDROID_HOME 环境变量。
配置 ${ANDROID_HOME}/build-tools/30.0.2 环境变量。

### 2. 构建

``` shell
cd app
sh build.sh
```

### 3. 安装

``` shell
adb install ./out/manually-built-app-aligned-signed.apk
```
