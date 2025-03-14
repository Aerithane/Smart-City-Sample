#!/bin/bash

scheme="$1"
case "$scheme" in
street)
    x0=-122.97570389153029
    x1=-122.95002310846972
    y0=45.55110181605918
    y1=45.5331153839408
    ;;
parking)
    x0=-111.95396553338196
    x1=-111.91092046661805
    y0=33.32894143211838
    y1=33.29296856788165
    ;;
stadium)
    x0=-121.98610951561652
    x1=-121.94083448438347
    y0=37.406071432118374
    y1=37.37009856788163
    ;;
*)
    echo "Usage: <sceme> <IMAGE> [DIR]"
    exit 3
    ;;
esac

image="$2"
echo "Image: $image"
image_dir=$(dirname $(readlink -f "$image"))
image=$(basename $(readlink -f "$image"))

GDAL2="geographica/gdal2"
cwd=$(readlink -f "$3")
if test -z "$cwd"; then
    cwd="$(pwd)"
fi
echo "working dir: $cwd"

sudo docker run -v "$image_dir:/home:ro" -v "$cwd:/mnt" --rm -it $GDAL2 sh -c "gdalinfo /home/${image} > /mnt/${image}.info"
height=$(grep "Size is" "$cwd/${image}.info" | cut -f4 -d' ')
width=$(grep "Size is" "$cwd/${image}.info" | cut -f3 -d' ' | cut -f1 -d',')
sudo rm -f "$cwd/${image}.info"
echo "Image size: ${width}x${height}"
if test $width -ne $height; then
    echo "Not a square image."
    exit 3
fi

sudo docker run -v "$image_dir:/home:ro" -v "$cwd:/mnt" --rm -it $GDAL2 gdal_translate -of GTiff -gcp 0 0 $x0 $y0 -gcp 0 $height $x0 $y1 -gcp $width $height $x1 $y1 -gcp $width 0 $x1 $y0 "/home/${image}" "/mnt/${image}.tmp.tif"
sudo rm -f "$cwd/${image}.modified.tif"
sudo docker run -v "$cwd:/home" --rm -it $GDAL2 gdalwarp -r cubic -tps -co COMPRESS=LZW  "/home/${image}.tmp.tif" "/home/${image}.modified.tif"
sudo rm -f "$cwd/${image}.tmp.tif"
sudo rm -rf "$cwd/${scheme}"
mkdir -p "$cwd/${scheme}"
sudo docker run -v "$cwd:/home" --rm -it $GDAL2 gdal2tiles.py -p mercator -z 13-18 -s EPSG:4326 -d -n -w none -r cubic /home/${image}.modified.tif /home/${scheme}
sudo chown -R "$(id -un):$(id -gn)" "$cwd/${scheme}" "$cwd/${image}.modified.tif"
find "$cwd/${scheme}" -name "*.xml" -exec rm -f {} \;
