#!/bin/bash

if [[ -z $1 ]]; then
    echo "usage: $0 <mobile ffmpeg base directory>"
    exit 1
fi

if [[ -z ${ANDROID_NDK} ]]; then
    echo "ANDROID_NDK not defined"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo "ARCH not defined"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo "API not defined"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. $1/build/common.sh

# PREPARING PATHS
android_prepare_toolchain_paths

TARGET_HOST=$(android_get_target_host)
CFLAGS=$(android_get_cflags "libvorbis")
CXXFLAGS=$(android_get_cxxflags)
LDFLAGS=$(android_get_ldflags "libvorbis")

cd $1/src/libvorbis || exit 1

make clean

CFLAGS=${CFLAGS} \
CXXFLAGS=${CXXFLAGS} \
LDFLAGS=${LDFLAGS} \
./configure \
    --prefix=${ANDROID_NDK}/prebuilt/android-${ARCH}/libvorbis \
    --with-pic \
    --with-sysroot=${ANDROID_NDK}/toolchains/mobile-ffmpeg-${ARCH}/sysroot \
    --with-ogg-includes=${ANDROID_NDK}/prebuilt/android-${ARCH}/libogg/include \
    --with-ogg-libraries=${ANDROID_NDK}/prebuilt/android-${ARCH}/libogg/lib \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-docs \
    --disable-examples \
    --disable-oggtest \
    --host=${TARGET_HOST} || exit 1

CFLAGS=${CFLAGS} \
CXXFLAGS=${CXXFLAGS} \
LDFLAGS=${LDFLAGS} \
make -j$(nproc) || exit 1

CFLAGS=${CFLAGS} \
CXXFLAGS=${CXXFLAGS} \
LDFLAGS=${LDFLAGS} \
make install || exit 1
