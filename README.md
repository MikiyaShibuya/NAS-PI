# NAS for Apple Time Machine
This is an instruction to build Time Machine server  
Reference
 - https://stash4.hatenablog.com/entry/2018/06/17/184423
 - https://github.com/dperson/samba/blob/master/docker-compose.yml

## Requirement

- Raspberry Pi
- HDD storage
- LAN (recommend wired)

## SSH Setup for raspberry pi

Write Raspberry Pi OS 32 bit into micro SD card and turn on the device  

Open terminal to find out the ip address of RPi and create ssh directory  
> ifconfig | grep 192  
> sudo mkdir -p /boot/ssh

Open Preferences -> Raspberry Pi Configuration  
Enable SSH in Interfaces tab  

Reboot the device and check the ssh connection  

## Server Host Setup

### Fix IP address

Write bellow contents into /etc/netplan/99-fix-ip.yaml  

```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp86s0:
      dhcp4: no
      addresses: [192.168.11.35/24]
      routes:
        - to: default
          via: 192.168.11.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

### Mount HDD

(using `/mnt/TimeMachine` in this instruction, please edit smb.conf when you using different directory)  

Find device and get UUID of HDD  
```
sudo blkid
```  
> output example:  /dev/sda1: LABEL="BUFFALO_HDD" UUID=“xxxx-yyyy-zzzz" TYPE="ext4"

Then, write mount setting and check if the HDD was mounted correctly  
```
sudo sh -c 'echo "UUID=xxxx-yyyy-zzzz /mnt/TimeMachine ext4 nofail 0 0" >> /etc/fstab'  
sudo mkdir /mnt/TimeMachine 
sudo mount -a
```

<< CAUTION >>  
If you failed to mount, some message like this  
`mount: /mnt/TimeMachine: mount point does not exist.`  
will be displayed.  
Fix this error BEFORE REBOOTING or your OS will be broken.


#### Trouble Shooting

Some times mounting may be failed like  
`xxx : Already mounted on yyy`.  
Re-mounting the HDD may fix the issue.

`df` : show mounted devices  
`umount /mnt/TimeMachine` : unmount device  

When above /etc/fstab setting doesn't work (for exfat storage?), try this  
```
sudo sh -c 'echo "UUID=xxxx-yyyy-zzzz /mnt/TimeMachine exfat rw,user,exec,umask=000 0 0" >> /etc/fstab'  
```

### Setup Samba server using docker (recommended)

```
cp _env .env
vim .env # Change user, password and timezone as you like
docker compose up
```

### Setup Samba server

Install samba and avahi-daemon (for enabling mDNS)  
This password will be required when setting up Time Machine  
> sudo apt install -y samba avahi-daemon \# select NO when asked to generate config  
> sudo smbpasswd -a $USER

Configure smb daemon
> mkdir ~/work && cd work  
> git clone https://github.com/MikiyaShibuya/NAS-PI.git  
> cd NAS-PI  
> sudo sh -c 'cat smb.conf >> /etc/samba/smb.conf'  
> sudo ln -s $PWD/samba.service /etc/avahi/services/samba.service  

Start samba daemon  
> sudo systemctl start smbd  
> sudo systemctl start avahi-daemon  

Check if the samba was launched correctly  
> sudo systemctl status smbd  
> sudo systemctl status avahi-daemon  


## Connect to NAS from mac

Mount NAS drive  
> Finder → ⌘K → smb://192.168.1.xx (RPi' address) → connect → input your smb ID  

`TimeMachine` should be displayed in the list  

Setting TimeMachine Backup  
> System Preference → Time Machine → Select Backup Disk → Time Machine 192.168.1.xx → Use disk → input your smb ID  

