#!/bin/sh

programme="$0"

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
BLUE='\033[01;34m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
BLINK='\033[5m'
UNDERLINE='\033[4m'
NC='\033[0m'

DEVICE="0"
VIDEO=""

Help() {
    cat <<EOM

    Creates a "fake web-cam" using ffmpeg for mocked video output

    usage:
    $programme [-i input video] [-o output device number]

    options:
    -i  path for input video
    -o  video device number. Default is 0

EOM

    exit
}

ParseArgs() {
    while getopts ":h:i:o:" option; do
        case $option in
        i) # set input video
            VIDEO=$OPTARG
            ;;
        o) # set output device
            DEVICE=$OPTARG
            ;;
        h) # display Help
            Help
            ;;
        \?) # incorrect option
            Help
            ;;
        *) # incorrect option
            Help
            ;;
        esac
    done

    if [ -z "$VIDEO" ]; then
        Help
    fi

    if [ -e "$VIDEO" ]; then
        echo "Video input file at $VIDEO"
    else
        echo "No such file at $VIDEO"
        exit
    fi
}

CheckPakcages() {

    V4L2_PKG_OK=$(dpkg-query -W --showformat='${Status}\n v4l2loopback-dkms' | grep -q "install ok installed")
    echo " Checking for v4l2loopback-dkms"
    if [ "" = V4L2_PKG_OK ]; then
        echo "${RED}v4l2loopback-dkms missing${NC}. Installing v4l2loopback-dkms"
        sudo apt-get install v4l2loopback-dkms -y
    else
        echo "---> v4l2loopback-dkms ${GREEN}ok${NC}"
    fi

    FFMPEG_PKG_OK=$(dpkg-query -W --showformat='${Status}\n ffmpeg' | grep -q "install ok installed")
    echo " Checking for ffmpeg"
    if [ "" = FFMPEG_PKG_OK ]; then
        echo "${RED}ffmpeg missing${NC}. Installing ffmpeg"
        sudo apt-get install ffmpeg -y
    else
        echo "---> ffmpeg ${GREEN}ok${NC}"
    fi

}

StartV4L2KernelModule() {
    sudo modprobe v4l2loopback card_label="Fake Webcam" exclusive_caps=1
}

InitiateStream() {
    ffplay /dev/video$DEVICE
    ffmpeg -stream_loop -1 -re -i $VIDEO -vcodec rawvideo -threads 0 -f v4l2 /dev/video$DEVICE
}

RemoveV4L2KernelModule() {
    sudo modprobe --remove v4l2loopback
}

ParseArgs "$@"
CheckPakcages
StartV4L2KernelModule
InitiateStream
RemoveV4L2KernelModule