# exagear-obb
A script is used to quickly make exagear ed data files(main.\*.com.eltechs.ed.obb).  Contains the script itself and an Ubuntu rootfs.
The base package(rootfs) will be downloaded automatically when you run the production.
# Add permissions
If the permissions are not enough, then add execution permissions to the file.
```sh
sudo chmod a+x ./build-obb
```
# Usage
```sh
./build-obb <WineHQ version>
```
*The version number format is similar to "6.23"; "7.0~rc1".*

# Archlinux
You may be need to install the following dependencies:
```sh
sudo pacman -S tar bsdtar zip unzip wget
```
