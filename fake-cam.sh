sudo apt install v4l2loopback-dkms
sudo apt install ffmpeg

sudo modprobe v4l2loopback card_label="Fake Webcam" exclusive_caps=1

ffmpeg -stream_loop -1 -re -i /path/to/video -vcodec rawvideo -threads 0 -f v4l2 /dev/video0

sudo modprobe --remove v4l2loopback

