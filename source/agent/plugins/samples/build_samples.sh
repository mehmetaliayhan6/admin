
#!/bin/bash
# Copyright (C) <2019> Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

error() {
    local code="${3:-1}"
    if [[ -n "$2" ]];then
        echo "Error on or near line $1: $2; exiting with status ${code}"
    else
        echo "Error on or near line $1; exiting with status ${code}"
    fi
    exit "${code}" 
}
trap 'error ${LINENO}' ERR

SAMPLES_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${InferenceEngine_DIR}" ]]; then
    printf "\nInferenceEngine_DIR environment variable is not set. Trying to find setupvars.sh to set it. \n"
    
    setvars_path="/opt/intel/computer_vision_sdk"
    if [ -e "$setvars_path/inference_engine/bin/setvars.sh" ]; then # for Intel Deep Learning Deployment Toolkit package
        setvars_path="$setvars_path/inference_engine/bin/setvars.sh"
    elif [ -e "$setvars_path/bin/setupvars.sh" ]; then # for OpenVINO package
        setvars_path="$setvars_path/bin/setupvars.sh"
    elif [ -e "$setvars_path/../setupvars.sh" ]; then
        setvars_path="$setvars_path/../setupvars.sh"
    else
        printf "Error: setupvars.sh is not found in hardcoded paths. \n\n"
        exit 1
    fi 
    if ! source $setvars_path ; then
        printf "Unable to run ./setupvars.sh. Please check its presence. \n\n"
        exit 1
    fi
fi

if ! command -v cmake &>/dev/null; then
    printf "\n\nCMAKE is not installed. It is required to build Inference Engine samples. Please install it. \n\n"
    exit 1
fi

build_dir=$PWD/build
mkdir -p $build_dir
cd $build_dir
cmake -DCMAKE_BUILD_TYPE=Release $SAMPLES_PATH
make

printf "\nBuild completed, you can find binaries for all samples in the $PWD/build/intel64/Release subfolder, and copy \nall of them over to analytics_agent/lib directory, or analytics_agent/pluginlibs by default.\n\n"
