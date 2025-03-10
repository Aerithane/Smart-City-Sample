#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))
CLIPS=(https://www.pexels.com/video/1388383/download,1388383.mp4,https://www.pexels.com/photo-license)

for clip in "${CLIPS[@]}"; do
    url=$(echo "$clip" | cut -f1 -d',')
    clip_name=$(echo "$clip" | cut -f2 -d',')
    clip_mp4="${clip_name/\.*/}.mp4"
    license=$(echo "$clip" | cut -f3 -d',')

    if test ! -f "$DIR/$clip_mp4"; then
        printf "\n\n\nThe Smart City sample requires you to have a dataset to simulate camera, please accept downloading dataset for camera simulation:\n\nDataset: $url\nLicense: $license\n\nThe terms and conditions of the data set license apply. Intel does not grant any rights to the data files.\n\n\nPlease type \"accept\" or anything else to skip the download.\n"
        read reply
        if test "$reply" = "accept"; then
            echo "Downloading..."
            tmp="tmp_$clip_name"
            wget -q -O "$DIR/$tmp" "$url"
            sudo docker run --rm -u $(id -u):$(id -g) -v "$DIR:/mnt:rw" -it openvisualcloud/xeon-centos76-media-ffmpeg ffmpeg -i /mnt/$tmp -c:v libx264 -profile:v baseline -x264-params keyint=30:bframes=0 -c:a aac -ss 0 /mnt/$clip_mp4
            rm -f "$DIR/$tmp"
        else
            echo "Skipping..."
        fi
    fi
done

if test "$(find $DIR -name '*.mp4' -print | wc -l)" -eq 0; then
    printf "\n\nNo clip is detected for camera simulation.\n\nYou can use your own video dataset. The database must be stored under sensor/simulation and must contain MP4 files encoded with H.264 (baseline, closed-GOP and no-B-frames) and AAC.\n\nIf unsure, it is recommended that you transcode your dataset with FFmpeg:\n\nffmpeg -i <source>.mp4 -c:v libx264 -profile:v baseline -x264-params keyint=30:bframes=0 -c:a aac -ss 0 <target>.mp4.\n\n"
    exit -1
fi
