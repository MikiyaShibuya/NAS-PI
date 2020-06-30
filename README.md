# Samba File Server for TimeMachine

## Preparation

Before the instruction, you should mount any HDD to `/mnt/TimeMachine`.  
This command may be used.  

#### Finding drive
```
sudo fdisk -l
```
#### Mounting found drive

```
sudo mount [drive] /mnt/TimeMachine -t exfat --options=rw
```
#### Install dependencies to utilize exfat format
```
sudo apt install exfat-fuse exfat-utils
```


## Installation
```
cd [working dir]
git clone [this repository]
cd [this repository]
sudo apt install samba avahi-daemon
sudo smbpasswd -a [your username or user for login]
cat smb.conf >> /etc/samba/smb.conf
ln -s $PWD/samba.service /etc/avahi/services/samba.service
sudo systemctl restart smbd
sudo systemctl restart avahi-daemon
```
## Using drive by local network
Connect to the TimeMachine drive
> Finder -> Go -> Connect to Server -> smb://[Raspberry pi ip address] -> Connect -> TimeMachine
