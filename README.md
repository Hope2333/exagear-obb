# exagear-obb
A script is used to quickly make exagear ed data files(main.\*.com.eltechs.ed.obb).  Contains the script itself and an Ubuntu rootfs.
The base package(rootfs) will be downloaded automatically when you run the production.

## Preparation
You may be need to install the following dependencies:
### ArchLinux class
```sh
sudo pacman -S tar libarchive xz zip unzip wget git
````
### Debian, Ubuntu class
```sh
sudo apt-get install zip xz unzip wget git
```
### RetHat class
```sh
sudo dnf install tar xz bsdtar zip unzip wget git
```

## First
```sh
git clone https://github.com/Hope2333/exagear-obb.git
cd exagear-obb
```
## Add permissions
For more details, please see Help（--help.
# Add permissions
If the permissions are not enough, then add execution permissions to the file.
```sh
sudo chmod a+x ./build-obb
```
## Usage
```sh
./build-obb <WineHQ version>
```
*The version number format is similar to "6.23"; "7.0~rc1".*
```

