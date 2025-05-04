# Homelab

Heavily, *heavily* influenced from TechHut: https://github.com/TechHutTV/homelab

## Proxmox as a NAS

My current setup is on my old AMD Threadripper 2950X, with 32GB of memory. I have a few different drives that are configured with ZFS: SSD for base install, SSD for Roon music collection, NVME SSD disk for running the software, a bunch of hard drives passed through with an LSI HBA card. (Coming soon)

1. Disable Secure Boot on machine
   - Enable virtualization too (or Watchdog)

2. Setup local account for Proxmox
   - Password and my personal email
   - Hostname: `ahs.local`
3. Install to 240GB SSD
4. Capture IP address to configure Proxmox via web
   - Make sure subnet is the same as computer you're accessing with 

### Post Install Steps (optional)

#### Removing Proxmox Subscription Notice
(not currently working)

#### Disable Enterprise Repositories
1. Navigate to _Node > Repositories_ Disable the enterprise repositories.
2. Now click Add and enable the no subscription repository. Finally, go _Updates > Refresh_.
3. Upgrade your system by clicking _Upgrade_ above the repository setting page.

#### Notes

- Tower needed to disable ipv6 in order for this to work 
- Needed to make sure the bridge was working and that the gateway was correctly configured in /etc/network/interfaces
- I also assigned a static IP via the eero app to make things easier

#### Delete local-lvm and Resize local (fresh install)
⚠️ Notice: This assumes a fresh installation without advanced storage settings during the installation.** See this [issue](https://github.com/TechHutTV/homelab/issues/19). ⚠️

My boot drive is small and I run all my containers and virtual machine disks on a seperate storage pool. So the lvm paritiion is not nessesary for me and goes unused. If you're running everything off the same boot drive for fast storage skips this. Also you should check out this [video](https://www.youtube.com/watch?v=czQuRgoBrmM) to learn more about LVM before doing anything.
1. Delete local-lvm manually from web interface under _Datacenter > Storage_.
2. Run the following commands within _Node > Shell_.
```
lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root
```
3. Check to ensure your local storage partition is using all avalible space. Reassign storage for containers and VM if needed.

#### Ensure IOMMU is enabled
Enable IOMMU on in grub configuration within _Node > Shell_.
```
nano /etc/default/grub
```
You will see the line with `GRUB_CMDLINE_LINUX_DEFAULT="quiet"`, all you need to do is add `intel_iommu=on` or amd_iommu=on` depending on your system.
```
# Should look like this
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"
```

Next run the following commands and reboot your system.
```
update-grub
```
Now check to make sure everything is enabled.
```
dmesg | grep -e DMAR -e IOMMU
dmesg | grep 'remapping'
```
Learn about enabling PCI Passthrough [here](https://pve.proxmox.com/wiki/PCI_Passthrough)

### 2. Create ZFS Pools

First, we are going to setup two ZFS Pools. A _tank_ pool which is used for larger stored data sets such as media, images and archives. We also will make a _flash_ pool which is used for virtual machine and container root file systems. This is what I name them for my setup. You can name these however you'd like.

First, checkout you disks and make sure that they're all there. Find this under _Node > Disks_. Make sure you whipe all the disks you plan on using and do note this will whipe any data on the disks, so make sure there is no important data on them and back up if needed.

Now, on the Proxmox sidebar for your datacenter, go to _Disks > ZFS > Create: ZFS_. This will pop up the screen to create a ZFS pool.

From this screen, it should show all of your drives, so select the ones you want in your pool, and select your RAID level (in my case RAIDZ for my vault pool and mirror for my flash pool) and compression, (in my case I keep it at on). Make sure you check the box that says __Add to Storage__. This will make the pools immiatily avalible and will prevent using .raw files as obsosed to my previous setup when I added directorties. 

### 3. Creating Containers using ZFS Pools

Now time to put these new storage pools in use. For this, we are going to create our first LXC. In this example the LXC is going to be in charge of managing our media server. First we need a operating system image. Click on your local storage in the sidebar and click on CT Templates then the Templates button. From there search for Ubuntu and download the ubuntu-22.04-standard template.

Now in the top right click on Create CT. The "Create: LXC Container" prompt should show up. On the general tab I set my CT ID to 100 (later I will match this to a local IP for organization) and I set the hostname to "sanscreen". Set your password, keep the container and unprivileged and click Next. Select your downloaded Ubuntu template and click next. Under disk you can select your storage location. If you created the flash pool like we did eariler select it, otherwise local is fine. For storage I picked 128GB. Click next as we will add the data and docker directory later. Give it:

- Give the container 30/32 cores and 28/31GB  of memory
- Assign a static IP address within your network (1 after the main server IP)

Under network we will leave most everything, but I like to give it a static IP here. If you want to manage this with your router select DHCP. Under IPv4 I set the IPv4/CIDR to `192.168.5.100/24` and the gateway to `192.168.4.1` your local IP may be different. Keep DNS as is and confirm the installation. 

### 4. Adding Mount Points

Now that our container is created I want to add some storage and mount the data and docker directories on my system. Click on your newly created LXC and then click on Resources. From there click the Add button and select mount point. The first one I'll add is going to be for music. For path, I will set this too /music and uncheck backup. I dedicate the entire 500GB SSD for it. I keep everything else as is and click create. For the docker mount I repeated all these steps, but set the storage to flash, mount point to /docker, and gave it about 128gb of space.

### 5. Creating SMB Shares

In our new LXC we first need to run some general updates and user creation.

1. Update your system
  ```
  sudo apt update && sudo apt upgrade -y
  ```

2. Create your user

  ```
  adduser kingscott
  adduser kingscott sudo
  ```

Great video resource by KeepItTechie: [https://www.youtube.com/watch?v=2gW4rWhurUs](https://www.youtube.com/watch?v=2gW4rWhurUs)
[source](https://gist.github.com/pjobson/3811b73740a3a09597511c18be845a6c)

3. Set permissions of mount points created eariler.
```
sudo chown -R kingscott:kingscott /music
sudo chown -R kingscott:kingscott /docker
```
4. Install Samba
```
sudo apt install samba
```
5. Create a backup of the default configuration
```
cd /etc/samba
sudo mv smb.conf smb.conf.bak
```
6. Edit the samba config
```
sudo nano smb.conf
```
This is my configuration:

*Note: Need to add configuration for large media mount.*

```
[global]
   server string = sanscreen
   workgroup = WORKGROUP
   security = user
   map to guest = Bad User
   name resolve order = bcast host
   hosts allow = 192.168.0.0/22
   hosts deny = 0.0.0.0/0
[music]
   path = /music
   force user = kingscott
   force group = kingscott
   create mask = 0774
   force create mode = 0774
   directory mask = 0775
   force directory mode = 0775
   browseable = yes
   writable = yes
   read only = no
   guest ok = no
[docker]
   path = /docker
   force user = kingscott
   force group = kingscott
   create mask = 0774
   force create mode = 0774
   directory mask = 0775
   force directory mode = 0775
   browseable = yes
   writable = yes
   read only = no
   guest ok = no
```
7. Add your samba user
```
sudo smbpasswd -a [username]
```
8. Set services to auto start on reboot
```
sudo systemctl enable smbd
sudo systemctl enable nmbd
sudo systemctl restart smbd
sudo systemctl restart nmbd
```
9. Allow samba on firewall if you run into any issues.
```
sudo ufw enable
sudo ufw allow Samba
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp                # For ssh
sudo ufw allow 80/tcp                # For nginx (http)
sudo ufw allow 443/tcp               # For nginx (https)
sudo ufw allow from 192.168.5.0/22   # For roon server locally
sudo ufw allow 55000/tcp             # Open port for roon arc
sudo ufw reload
sudo ufw status numbered
```
10. Install wsdd for Windows discorvery
```
sudo apt install wsdd
```
# Backups
Work in Progress