#!/bin/bash

echo "Downloading zip file..."

# Setting download path
downloadPath="./box.zip"
# Setting URL
url="https://downloads.ortussolutions.com/ortussolutions/commandbox/6.0.0/commandbox-jre-darwin64-6.0.0.zip"

# Check if the file already exists
if [ -f "$downloadPath" ]; then
    echo "File already exists. Skipping download."
else
    echo "Downloading zip file... this may take a couple minutes."
    # Using curl to download the file
    curl -o "$downloadPath" "$url"
    echo "Download complete."
fi

# Unzipping the box.zip to the current directory
# Checking if the unzip target exists before unzipping
unzipTarget="./box"  # Replace with the primary directory or file expected after unzipping

if [ ! -d "$unzipTarget" ]; then
    echo "Unzipping file..."
    unzip -o "$downloadPath" -d "./box"
    echo "Unzip complete."
else
    echo "Unzip target already exists. Skipping unzip."
fi

echo "Starting ChartSQL Server. This will take a couple minutes on the first run..."
cd chartsql/studio/wwwroot || exit
../../../box/box start name=chartsql-preview cfengine=lucee@5.4.3+16 rewritesEnable=true heapsize=1024
cd ../../..
echo "ChartSQL Server started. Your browser should have opened to ChartSQL Studio. You can now close this window"
read -rp "Press Enter to exit..."