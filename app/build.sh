echo "[ManualBuild] start"

# 全局参数
sdk=$(dirname $(dirname $(dirname $(which aapt2))))
androidJar=${sdk}/platforms/android-30/android.jar

# 1. 创建Build临时目录
buildDir="./out"
echo "[ManualBuild] Cleaning"
rm -rf ${buildDir}
mkdir ${buildDir}
echo "[ManualBuild] Created a build directory at ${buildDir}"

# 2. 编译资源
echo "[ManualBuild] Compile resources"
appResDir="./src/main/res"
manifest="./src/main/AndroidManifest.xml"
compileTargetArchive=${buildDir}/compiledRes
compileTargetArchiveUnzip=${buildDir}/compiledResDir
linkTarget=${buildDir}/res.apk
r=${buildDir}/r
echo "[ManualBuild] AAPT2 compiling"
# aapt2 编译资源文件 -o 输出路径 --dir 资源文件路径
aapt2 compile -o ${compileTargetArchive} --dir ${appResDir}
# 解压aapt2生成物 -q 静默执行 -d 输出路径
unzip -q ${compileTargetArchive} -d ${compileTargetArchiveUnzip}
echo -e "[ManualBuild] AAPT2 intermediates \r\n - compiled resources zip archive: ${compileTargetArchive} \r\n - unzip resources from above: ${compileTargetArchiveUnzip}"
echo "[ManualBuild] AAPT2 linking"
# 只要目录内的普通文件
linkInputs=$(find ${compileTargetArchiveUnzip} -type f | tr '\r\n' ' ')
# tips:
# echo "123456" | tr "123" "456"
# 456456
# aapt 链接资源文件 link -o 输出路径 -I 依赖库 --manifest 生成AndroidManifest.xmk文件的路径 --java 生成R.java文件的路径
aapt2 link -o ${linkTarget} -I ${androidJar} --manifest ${manifest} --java ${r} ${linkInputs}
echo -e "[ManualBuild] AAPT2 generated \r\n - R.java: ${r} \r\n - res package: ${linkTarget}"

# 3. 编译Java代码
echo "[ManualBuild] Compile Java classes"
classesOutput=${buildDir}/classes
pkgName="com/aqinn/demo/manuallybuiltapp"
mainClassesInput="./src/main/java/${pkgName}/*.java"
rDotJava=${r}/${pkgName}/R.java
mkdir ${classesOutput}
echo "[ManualBuild] Created a classes output directory at ${classesOutput}"
echo "[ManualBuild] javac (.java -> .classes)"
# .java -> .classes -d 输出路径 -bootclasspath 覆盖引导类文件的位置(--help说明)
javac -d ${classesOutput} ${mainClassesInput} ${rDotJava} -classpath ${androidJar}
echo "[ManualBuild] javac generated ${classesOutput}"
echo "[ManualBuild] D8 (.classes -> .dex)"
dexOutput=${buildDir}/dex
mkdir ${dexOutput}
# .classes -> .dex --lib 依赖库 --output 输出路径
d8 ${classesOutput}/${pkgName}/*.class --lib ${androidJar} --output ${dexOutput}
echo "[ManualBuild] D8 generated ${dexOutput}"

# 4. 打包apk
echo "[ManualBuild] Package and Sign the APK"
tools=${sdk}/tools/lib
originApk=${buildDir}/manually-built-app-unaligned-unsigned.apk
alignedApk=${buildDir}/manually-built-app-aligned-unsigned.apk
alignedSignedApk=${buildDir}/manually-built-app-aligned-signed.apk
debugKeystore=${HOME}/.android/debug.keystore
echo "[ManualBuild] Packaging"
# -uvzf 参数是 ApkBuilderMain 的参数，要看源码才知道作用
java -cp $(echo ${tools}/*.jar | tr ' ' ':') com.android.sdklib.build.ApkBuilderMain ${originApk} -u -v -z ${linkTarget} -f ${dexOutput}/classes.dex
echo "[ManualBuild] Built apk by ApkBuilderMain at ${originApk}"
echo "[ManualBuild] APK aligning"
zaTool=$(dirname $(which aapt2))/zipalign
# 为 APK 做 4 字节对齐优化
${zaTool} 4 ${originApk} ${alignedApk}
echo "[ManualBuild] APK aligned at ${alignedApk}"
echo "[ManualBuild] APK Signing"
# 为 APK 签名，这里使用 Android Studio 生成的签名文件：$HOME/.android/debug.keystore
apksigner sign --ks ${debugKeystore} --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out ${alignedSignedApk} ${alignedApk}
# tips:
# 不签名就会报错：
# Performing Streamed Install
# adb: failed to install ./out/res.apk: Failure [INSTALL_PARSE_FAILED_NO_CERTIFICATES: Failed collecting certificates for /data/app/vmdl1034097841.tmp/base.apk: Failed to collect certificates from /data/app/vmdl1034097841.tmp/base.apk: Attempt to get length of null array]
echo "[ManualBuild] APK signed"
echo "[ManualBuild] Build completed, check the final APK at ${alignedSignedApk}"
