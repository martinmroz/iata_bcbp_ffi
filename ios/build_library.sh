#!/usr/bin/env bash -l -e

TOOL="cargo lipo"
HEADER_NAME="iata_bcbp_ffi.h"
LIBRARY_NAME="libiata_bcbp_ffi.a"
CARGO_BUILD_ROOT="../target"
CARGO_BUILT_HEADER_PATH="${CARGO_BUILD_ROOT}/${HEADER_NAME}"

# Derive the output build library path.
if [ -n "${BUILT_PRODUCTS_DIR}" ]
then
    CARGO_HEADER_INSTALL_PATH="${BUILT_PRODUCTS_DIR}/iata_bcbp_ffi/include"
    CARGO_LIBRARY_INSTALL_PATH="${BUILT_PRODUCTS_DIR}/iata_bcbp_ffi/lib"
else
    echo -e "error: No Xcode build products directory specified"
    exit 1
fi

# Derive the build configuration flag.
if [ -n "${CONFIGURATION}" ]
then
    if [ "${CONFIGURATION}" == "Debug" ]
    then
        echo -e "note: Running in Debug configuration"
        CARGO_BUILD_CONFIGURATION_FLAG=""
        CARGO_BUILT_LIBRARY_PATH="${CARGO_BUILD_ROOT}/universal/debug/${LIBRARY_NAME}"
    elif [ "$CONFIGURATION" == "Release" ]
    then
        echo -e "note: Running in Release configuration"
        CARGO_BUILD_CONFIGURATION_FLAG="--release"
        CARGO_BUILT_LIBRARY_PATH="${CARGO_BUILD_ROOT}/universal/release/${LIBRARY_NAME}"
    else
        echo -e "error: Invalid build configuration: '${CONFIGURATION}'"
        exit 1
    fi
else
    echo -e "error: No build configuration specified"
    exit 1
fi

# Build the artifact for all targets in the specified mode.
echo "note: Building Rust project"
(cd ../ ; ${TOOL} ${CARGO_BUILD_CONFIGURATION_FLAG})

# Copy the built artifacts into the destination path.
mkdir -p ${CARGO_HEADER_INSTALL_PATH}
mkdir -p ${CARGO_LIBRARY_INSTALL_PATH}
echo "note: Copying ${CARGO_BUILT_HEADER_PATH}"
cp ${CARGO_BUILT_HEADER_PATH} ${CARGO_HEADER_INSTALL_PATH}
echo "note: Copying ${CARGO_BUILT_LIBRARY_PATH}"
cp ${CARGO_BUILT_LIBRARY_PATH} ${CARGO_LIBRARY_INSTALL_PATH}
