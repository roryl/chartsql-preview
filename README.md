# ChartSQL Studio Developer Preview
Welcome to the ChartSQL Developer Preview Repo. The purpose of this repo is to allow you access to the development build of ChartSQL Studio. We are providing access to this repo so that you can easily update from development changes pushed to this repo.

# Uses & Limitations
ChartSQL is currently in pre-alpha status. Access to this repo is for demonstration and for you to provide development feedback. We do not recommend reliying on this version for any production purpose. See our [Roadmap](https://docs.chartsql.com/product-and-community/roadmap) for future plans.

# Documentation
Full ChartSQL documentation can be found at the [ChartSQL Git Book](https://docs.chartsql.com/)

# Installation Overview
See full instructions at [Installing Studio Desktop](https://docs.chartsql.com/chartsql-studio/installing-studio-desktop)

### Clone the Repo
Clone the repo to any location on your file system. Cloning the repo will allow you to git-pull to obtain updates.

You may also download a zip file but you will need to re-download for every release.

### Run ChartSQL Server
Within the root directory, you will see start.bat (Windows) or start.sh (Mac) which will run the ChartSQL server

### ChartSQL Studio will launch in your Browser
On first run, it may take a couple minutes to start the embedded Java web server and launch the application. When it is complete, your browser will open to the ChartSQL Studio editor.

# Getting Started
See the [ChartSQL Studio Overview](https://docs.chartsql.com/chartsql-studio/overview) for how to use the ChartSQL Studio Editor. Many [Examples](https://docs.chartsql.com/charts/example-charts) are available for inspiration.

# Updating
When a new release is available it will be pushed to this repo. You can simply git pull the repo and ChartSQL should auto update. If necessary, you can restart the server from your system tray.

There is also a stop.bat/sh and start.bat/sh that you can use to top and restart the server.

# System Resources
ChartSQL Studio Developer Preview runs a full copy of the ChartSQL server and client. It contains multiple copies of Windows, Linux and Mac distribution and the Java Runtime. Eventual production builds will be a smaller footprint and packaged with Electron.

* OS: Windows, Mac or Linux
* CPU: Any 64bit CPU
* Disk Space to clone: 1GB
* RAM: By default it reserves 1GB of RAM for the server
* HTTP: The Server will start on http://127.0.0.1:5****/

# Support
Support is provided in our [ChartSQL Discord Community](https://discord.gg/UbHYA6nyTg). Please join us there if you run into any issues.