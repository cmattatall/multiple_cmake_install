#!/bin/bash
################################################################################
# bash script to install multiple versions of cmake and configure them
# using update-alternatives
#
#
################################################################################
#
# Note: RUN AS SUDO
#
################################################################################
#
# Tested on Ubuntu 18.04
#
################################################################################

set -e

# clean up old cmake alternatives
#rm /etc/alternatives/cmake
#rm /etc/alternatives/ctest
#rm /etc/alternatives/cpack
#rm -r /var/lib/dpkg/alternatives/cmake

declare -a CMAKE_VERSIONS=("3.16.5" "3.21.1" "3.10.3")

CMAKE_INSTALL_DIR_ABSOLUTE="/usr/cmake"

if [ -d "${CMAKE_INSTALL_DIR_ABSOLUTE}" ]; then
    echo ""
else
	mkdir -p ${CMAKE_INSTALL_DIR_ABSOLUTE} 
fi
pushd ${CMAKE_INSTALL_DIR_ABSOLUTE} > /dev/null


TMP_BUILD_DIR="build"
if [ -d "${TMP_BUILD_DIR}" ]; then
    rm -r ${TMP_BUILD_DIR} && mkdir "${TMP_BUILD_DIR}"
else 
    mkdir "${TMP_BUILD_DIR}"
fi
pushd ${TMP_BUILD_DIR} > /dev/null

for version in "${CMAKE_VERSIONS[@]}"; do
    update-alternatives --list cmake | grep ${version} > /dev/null
    if [ "$?" -ne 0 ]; then
	wget "https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}.tar.gz"
    	tar -xvf cmake-${version}.tar.gz
	rm cmake-${version}.tar.gz

	# cmake-${version} will already exist from untarring the archive
    	pushd cmake-${version} > /dev/null
        CURRENT_CMAKE_VERSION_INSTALL_DIR="${CMAKE_INSTALL_DIR_ABSOLUTE}/cmake-${version}"
        if [ -d "${CURRENT_CMAKE_VERSION_INSTALL_DIR}" ]; then
            echo ""
        else 
            mkdir -p "${CURRENT_CMAKE_VERSION_INSTALL_DIR}"
        fi
        ./bootstrap --prefix="${CURRENT_CMAKE_VERSION_INSTALL_DIR}"
        make -j$(nproc) install

        ALT_PRIO=$(echo "$version" | sed 's/\.//g' | awk -F. '{print $1}')
        update-alternatives --force \
        --install /usr/bin/cmake cmake "${CURRENT_CMAKE_VERSION_INSTALL_DIR}"/bin/cmake ${ALT_PRIO} \
        --slave   /usr/bin/ctest ctest "${CURRENT_CMAKE_VERSION_INSTALL_DIR}"/bin/ctest \
        --slave   /usr/bin/cpack cpack "${CURRENT_CMAKE_VERSION_INSTALL_DIR}"/bin/cpack
        
	popd > /dev/null
    else 
	echo "cmake ${version} is already registered as an alternative"
    fi
done

popd > /dev/null # leave TMP_BUILD_DIR

# remove temporary build directory
rm -r "${CMAKE_INSTALL_DIR_ABSOLUTE}"/"${TMP_BUILD_DIR}"

popd > /dev/null # leave CMAKE_INSTALL_DIR_ABSOLUTE
