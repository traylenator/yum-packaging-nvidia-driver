#!/bin/sh
set -e

VERSION=${VERSION:-430.14}
DL_SITE=${DL_SITE:-http://us.download.nvidia.com/XFree86}
TEMP_UNPACK=${TEMP_UNPACK:-temp}

RUN_FILE=${RUN_FILE:-NVIDIA-${PLATFORM}-${VERSION}.run}

printf "Downloading installer ${RUN_FILE}... "
[[ -f $RUN_FILE ]] || wget -c -q ${DL_SITE}/${PLATFORM}/${VERSION}/$RUN_FILE
printf "OK\n"

sh ${RUN_FILE} --extract-only --target ${TEMP_UNPACK}

printf "Cleaning up binaries... "

cd ${TEMP_UNPACK}

# Compiled from source
rm -f \
    nvidia-xconfig* \
    nvidia-persistenced* \
    nvidia-modprobe* \
    libnvidia-gtk* nvidia-settings* \
    libGLESv1_CM.so.* libGLESv2.so.* libGL.la libGLdispatch.so.* libOpenGL.so.* libGLX.so.* libGL.so.1* libEGL.so.1* \
    libnvidia-egl-wayland.so.* \
    libnvidia-egl-gbm.so.* \
    libnvidia-vulkan-producer.so.* \
    libOpenCL.so.1* \
    32/libGLESv1_CM.so.* 32/libGLESv2.so.* 32/libGL.la 32/libGLdispatch.so.* 32/libOpenGL.so.* 32/libGLX.so.* 32/libGL.so.1* 32/libEGL.so.1* \
    32/libOpenCL.so.1*

# Non GLVND libraries
rm -f \
    libGL.so.${VERSION} libEGL.so.${VERSION} \
    32/libGL.so.${VERSION} 32/libEGL.so.${VERSION}

# Useless with packages
rm -f nvidia-installer* .manifest make* mk* tls_test*

# useless on modern distributions
rm -f libnvidia-wfb*

# Add json files in both architectures
cp -f *.json* 32/

cd ..

KMOD=nvidia-kmod-${VERSION}-x86_64
USR_64=nvidia-driver-${VERSION}-x86_64
USR_32=nvidia-driver-${VERSION}-i386

mkdir ${KMOD} ${USR_64} ${USR_32}
mv ${TEMP_UNPACK}/kernel ${KMOD}/
mv ${TEMP_UNPACK}/32/* ${USR_32}/
mv ${TEMP_UNPACK}/* ${USR_64}/

rm -fr ${TEMP_UNPACK}

printf "OK\n"

for tarball in ${KMOD} ${USR_32} ${USR_64}; do

    printf "Creating tarball $tarball... "

    tar --remove-files -cJf $tarball.tar.xz $tarball

    printf "OK\n"

done
