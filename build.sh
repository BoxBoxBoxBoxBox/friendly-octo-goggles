# Cache
mkdir -p /tmp/rom/app
cd /tmp/rom/app
echo "${GIT_COOKIES}" > ~/git_cookies.sh
bash ~/git_cookies.sh
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR=$WORKDIR/ccache
export CCACHE_EXEC=$(which ccache)
export _JAVA_OPTIONS="-Xmx10g"
export USE_CCACHE=1
ccache -o compression=true
which ccache
ccache -M 15
ccache -z

# Sync
repo init --depth=1 --no-repo-verify -u https://github.com/crdroidandroid/android.git -b 12.1 -g default,-mips,-darwin,-notdefault
git clone https://gitlab.com/R9Lab/Manifest.git --depth 1 -b crDroid-12.1-S .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)

# Commands
source build/envsetup.sh
lunch lineage_lava-userdebug
export SELINUX_IGNORE_NEVERALLOWS=true
export TZ=Asia/Dhaka #put before last build command
make Dialer

# Upload
cd out/target/product/lava/product/priv-app/Dialer/Dialer.apk

# Upload to oshi.at
if [ -z "$TIMEOUT" ];then
    TIMEOUT=20160
fi

export OUTPUT="Dialer.apk"
FILENAME=$(echo $OUTPUT)

# Upload to WeTransfer
transfer wet $FILENAME > link.txt || { echo "ERROR: Failed to Upload the Build!" && exit 1; }

# Mirror to oshi.at
curl -T $FILENAME https://oshi.at/${FILENAME}/${OUTPUT} > mirror.txt || { echo "WARNING: Failed to Mirror the Build!"; }

DL_LINK=$(cat link.txt | grep Download | cut -d\  -f3)
MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)

# Show the Download Link
echo "=============================================="
echo "Download Link: ${DL_LINK}" || { echo "ERROR: Failed to Upload the Build!"; }
echo "Mirror: ${MIRROR_LINK}" || { echo "WARNING: Failed to Mirror the Build!"; }
echo "=============================================="

# Remove 
rm -rf out/target/product/lava
