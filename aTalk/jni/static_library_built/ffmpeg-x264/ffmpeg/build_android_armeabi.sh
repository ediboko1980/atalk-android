#!/bin/bash
source ./build_settings.sh

export PLATFORM="android-15"
SYSROOT=$ANDROID_NDK/platforms/$PLATFORM/arch-arm/
TOOLCHAIN=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
rm -f $(pwd)/compat/strtod.o

function build_target
{
./configure \
  $COMMON $CONFIGURATION \
  --prefix=$PREFIX \
  --cross-prefix=$CROSS_PREFIX \
  --nm=${CROSS_PREFIX}nm \
  --sysroot=$SYSROOT \
  --cc=${CROSS_PREFIX}gcc \
  --extra-libs="-lgcc" \
  --target-os=linux \
  --arch=arm \
  --cpu=armv5te \
  --disable-asm \
  --disable-stripping \
  --extra-cflags="-O3 -Wall -pipe -std=c99 -ffast-math -fstrict-aliasing -Werror=strict-aliasing -Wno-psabi -Wa,--noexecstack -DANDROID -DNDEBUG-march=armv5te -mtune=arm9tdmi -msoft-float $ADDI_CFLAGS -I../x264/android/$CPU/include" \
  --extra-ldflags="$ADDI_LDFLAGS -L../x264/android/$CPU/lib"

make clean
make -j4 
make install
}

export CPU=armeabi
PREFIX=./android/$CPU 
CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-

pushd ffmpeg
build_target

# Use AS NDK to build
# python FFmpegParser.py -d $PROJECT_JNI
# cd $PROJECT_JNI
# export ABI=$CPU
# $ANDROID_NDK/ndk-build
# cp -r "$PROJECT_LIBS/$CPU" "$PROJECT_LIBS/../out" 
# cd $DIR

popd
echo "=== Android ffmpeg for $CPU builds completed ==="