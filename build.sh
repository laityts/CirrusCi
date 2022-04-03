#! /bin/bash

#
# Script for building Android Kernel
#
#

# Set environment for telegram
export CHATID="$TG_CHAT_ID"
export token=$TG_TOKEN
export BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"

# Set Date and time
#DATE=$(TZ=Asia/Beijing date +"%Y%m%d-%T")
DATE=$(TZ=Asia/Beijing date +"%y%m%d")

# Set function for telegram
tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$CHATID" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}

tg_post_build() {
	# Post MD5 Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	# Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$CHATID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$2 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"
}

# Set env
BOOT="out/target/product/$TARGET/boot.img"
#DTBO="out/target/product/$TARGET/dtbo.img"

# Compile
cd $ROM
ls
ls out/target/product/$TARGET/obj/KERNEL_OBJ/arch/arm64/boot/dts/qcom || true
source build/envsetup.sh
lunch ${LUNCH}_${TARGET}-userdebug
make bootimage -j$(nproc --all) 2>&1 | tee log.txt
#make dtboimage -j$(nproc --all) 2>&1 | tee log2.txt || true
ls out/target/product/$TARGET
mv $BOOT /tmp/cirrus-ci-build/$ROM/boot.img
#mv $DTBO /tmp/cirrus-ci-build/$ROM/dtbo.img
mv -f /tmp/cirrus-ci-build/META-INF /tmp/cirrus-ci-build/$ROM/META-INF

zipname="$ROM-${DATE}.zip"

# Compress
if [ -f "dtbo.img" ]; then
    zip -r $zipname boot.img dtbo.img META-INF/
else
    zip -r $zipname boot.img META-INF/
fi 
ls

# Push files
if [ -f "$zipname" ]; then
    tg_post_build $zipname "Build Complete"
else
    tg_post_build log.txt "Build Fail"
#    tg_post_build log2.txt "Build Fail"
fi