# NAS for Apple Time Machine (LAN)
This is an instruction to build Time Machine server in LAN using Raspberry Pi  
Reference： https://stash4.hatenablog.com/entry/2018/06/17/184423

## Disclaimer
Although I have confirmed that the backup data can be restored successfully, please operate at your own risk.

## Requirement

- Rspberry Pi
- HDD storage
- Wired LAN

### My configuration

- [Raspberry Pi 3B](https://www.amazon.co.jp/gp/product/B087R57WJX/ref=ox_sc_act_title_1?smid=A2LEO3SQFLYI2F&psc=1)
- [BUFFALO HDD 1TB](https://www.amazon.co.jp/gp/product/B07D795SV5/ref=ox_sc_act_title_1?smid=AN1VRQENFRJN5&psc=1)

## RPi Basic SSH Setup

Write Raspberry Pi OS 32 bit into micro SD card and turn on the device

Open terminal to find out the ip address of RPi and create ssh directory
> ifconfig | grep 192  
> sudo mkdir -p /boot/ssh

Open Preferences -> Raspberry Pi Configuration  
Enable SSH in Interfaces tab

Reboot the device and check the ssh connection from macbook

## Server Host Setup

### Common

Update package
> sudo apt update

Edit environment setup (anything as you want)
> sudo apt install -y zsh neovim tmux  
> git clone https://github.com/MikiyaShibuya/dotfiles.git  
> cd dotfiles && ./setup.sh

### Fix IP address

Edit /etc/dhcpcd.conf to fix local IP address.  
Uncomment and edit like this according to your environment.  
Make sure routers and DNS server are right to prevent network issues after that.
> \# Example static IP configuration:  
> interface eth0  
> static ip_address=192.168.1.xx/24  
> static routers=192.168.1.1  
> static domain_name_servers=192.168.1.1 8.8.8.8  


### Mount HDD

(using `/mnt/TimeMachine` in this instruction, please edit smb.conf when you using different directory)

Find device and get UUID of HDD
> sudo blkid  
> \# /dev/sda1: LABEL="BUFFALO_HDD" UUID=“9da1c321-xxxx-xxxx-xxxx-xxxxxxxx9da8" TYPE="ext4"

Then, write mount setting and check if the HDD was mounted correctly
> sudo sh -c 'echo "UUID=9da1c321-xxxx-xxxx-xxxx-xxxxxxxx9da8 /mnt/TimeMachine ext4 nofail 0 0" >> /etc/fstab'  
> sudo mount -a

<< CAUTION >>  
If you failed to mount, some message like this
`mount: /mnt/TimeMachine: mount point does not exist.`
will be displayed.
Fix this error BEFORE REBOOTING or your OS will be broken.


#### Trouble Shooting

Some times mounting may be failed like `xxx : Already mounted on yyy`.  
Re-mounting the HDD may fix the issue.

`df` : show mounted devices  
`umount [device name]` : unmount device

### Samba Setup

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

