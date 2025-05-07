# TrueNAS

This is the guide to setup a new VM that manages the bulk storage needed to storage movies and TV shows. This VM itself will expose an NFS share, which is then mounted at the Proxmox host level, and ultimately exposed via the media container. 

## Create VM

(Add steps)

1. Get TrueNAS .iso file
2. Add CD drive to boot VM from .iso
3. Complete installation and reboot VM

## Prepare VM

1. Pass through HBA card (PCI-E)
2. Disable KVM Hardware Configuration
   - I experienced an error when trying to boot the machine without this
3. Start VM
4. It may take 3-4 minutes to start up

*Note:* If you want to assign a static IP, you can assign it in eero and then reboot the machine.

### Create data pool

These steps will create a new ZFS data pool, configured in RAIDZ1 (group of 3 drives; 2 storage drives and 1 parity drive). We'll also make sure to expose the drives via NFS share, so that we can pass it to the primary media container to access for downloading and storing media.

1. Storage > Create Pool
2. Add a name
3. Use RAIDZ1 config
4. Leave all other options as default and save

### Create dataset

It was recommended to use a dataset, just to prevent any weird behaviour with sharing/exposing root vdev setups.

1. Datasets > Add Dataset
2. Give it a name
3. Use the generic preset
4. Save

Once this is created, then edit the dataset permissions, and confirm the following:

- Owner: root
- Group: root

#### Create NFS share

Next, we'll create the share to be exposed to Proxmox. Follow these steps:

1. Shares > NFS Shares > Add

2. Select the dataset created above (`/mnt/storage<n>/lightbox`)

3. Add a network mask to only encapsulate local network on the same-ish subnet: 192.168.5.0/22

4. Next confirm the following:

   - Mapall User -> root

   - Mapall Group -> root

### Mount share on Proxmox host and give container access

Head over to the Proxmox **host** not the media container. Follow these steps:

1. Create a new folder for the mount point and mount the NFS share to it: 

   ```
   $ mkdir -p /mnt/lightbox
   $ mount -t nfs 192.168.x.x:/mnt/storage0/lightbox /mnt/lightbox
   ```

2. This should mount that network share. Create a file to test. Permission issues are likely with the dataset or NFS share itself. 

3. Next make sure to add the entry to `/etc/fstab` to make it permanent:

   ```
   $ echo "192.168.x.x:/mnt/storage0/lightbox /mnt/lightbox nfs defaults 0 0" >> /etc/fstab
   ```

4. Lastly, make sure the media container gets access to the mount point. Edit `/etc/pve/lxc/<id>.conf`:

   ```
   mp2: /mnt/lightbox,mp=/lightbox
   ```

5. Restart that container

6. Make sure that the samba configuration from the initial setup is connected to the correct folder.

