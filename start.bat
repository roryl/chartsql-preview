@echo off
echo Downloading zip file...

:: Setting download path
set "downloadPath=./box.zip"
:: Setting URL
set "url=https://www.ortussolutions.com/parent/download/commandbox/type/windows-jre64"

:: Check if the file already exists
IF EXIST "%downloadPath%" (
    echo File already exists. Skipping download.
) ELSE (
    echo Downloading zip file... this may take a couple minutes.
    :: Using PowerShell to download the file
    powershell -Command "Invoke-WebRequest '%url%' -OutFile '%downloadPath%'"
    echo Download complete.
)
echo Download complete.

:: Unzipping the box.zip to the current directory
:: Checking if the unzip target exists before unzipping
set "unzipTarget=./box"  :: Replace with the primary directory or file expected after unzipping

IF NOT EXIST "%unzipTarget%" (
    echo Unzipping file...
    powershell -Command "Expand-Archive -Path '%downloadPath%' -DestinationPath './box' -Force"
    echo Unzip complete.
) ELSE (
    echo Unzip target already exists. Skipping unzip.
)

echo Starting ChartSQL Server. This will take a couple minutes on the first run...
pushd chartsql\studio\wwwroot
..\..\..\box\box.exe start name=chartsql-preview cfengine=lucee@5.4.3+16 rewritesEnable=true heapsize=1024
popd

echo ChartSQL Server started. Your browser should have opened to ChartSQL Studio. You can now close this window
pause