#!/bin/sh

# properties
ROOT_DIR="$(cd $(dirname ${0}); pwd)"
BUILD_DIR="${ROOT_DIR}/_builds"
TOOLCHAIN=ios-nocodesign-11-2-dep-8-0-wo-armv7s-bitcode-cxx11
INSTALL_DIR="${ROOT_DIR}/_install/${TOOLCHAIN}"
DEST_DIR="${ROOT_DIR}/../tesseract-objc/Libraries"

# download submodules
git submodule update --init

# patch submodules
patch -d "${ROOT_DIR}/leptonica" -i "${ROOT_DIR}/patches/leptonica.patch" -p1
patch -d "${ROOT_DIR}/tesseract" -i "${ROOT_DIR}/patches/tesseract.patch" -p1

# build leptonica
"${ROOT_DIR}/polly/bin/build.py" --home "${ROOT_DIR}/leptonica" --toolchain ${TOOLCHAIN} --config Release --ios-multiarch --ios-combined --clear --install

# clear intermediates
rm -r "${BUILD_DIR}"

# set pkg-config
export PKG_CONFIG_PATH="${ROOT_DIR}/_install/${TOOLCHAIN}/lib/pkgconfig"

# build tesseract
"${ROOT_DIR}/polly/bin/build.py" --home "${ROOT_DIR}/tesseract" --toolchain ${TOOLCHAIN} --config Release --ios-multiarch --ios-combined --install

# copy libraries
rm -r "${DEST_DIR}/include" "${DEST_DIR}/lib/ios"
mkdir -p "${DEST_DIR}/include" "${DEST_DIR}/lib/ios" 
cp -R "${INSTALL_DIR}/include/leptonica" "${INSTALL_DIR}/include/tesseract" "${DEST_DIR}/include"
cp -f "${INSTALL_DIR}/lib/libleptonica.a" "${DEST_DIR}/lib/ios"
cp -f "${INSTALL_DIR}/lib/liblibtesseract.a" "${DEST_DIR}/lib/ios/libtesseract.a"

# wipe timestamps
"${ROOT_DIR}/lib-timestamp-wiper/fatlib-timestamp-wiper.sh" "${DEST_DIR}/lib/ios/libleptonica.a"
"${ROOT_DIR}/lib-timestamp-wiper/fatlib-timestamp-wiper.sh" "${DEST_DIR}/lib/ios/libtesseract.a"

# clean patches
pushd leptonica
git checkout -- .
popd

pushd tesseract
git checkout -- .
popd

# clean builds
rm -r _*
