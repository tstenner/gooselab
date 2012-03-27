#lsof /dev/video0;  kill -9 <running process>
export F="/home/msumpf/Trial2.avi"
cvlc v4l2:// :v4l-vdev="/dev/video0" :v4l-norm=3 :v4l-frequency=-1 :v4l-caching=300 :v4l-chroma="" :v4l-fps=-1.000000 :v4l-channel=0 :v4l-tuner=-1 :v4l-brightness=-1 :v4l-colour=-1 :v4l-hue=-1 :v4l-contrast=-1 :no-v4l-mjpeg :v4l-decimation=1 :v4l-quality=100 --sout "#duplicate{dst=display,dst=std{access=file,mux=avi,dst=/tmp/tmp.avi}}"
ffmpeg -i /tmp/tmp.avi -vcodec rawvideo $F
rm /tmp/tmp.avi #record, convert and save video
