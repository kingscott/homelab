# Jellyfin installation

The first thing I need to do install Nvidia (non-free) drivers on the host, as we'll need to pass the card through to the LXC running Jellyfin. The easiest way to do it all is to use the Proxmox helper script to install Jellyfin, and then patch the Nvidia drivers with the keylase/patch.

### Install Nvidia drivers

Using the table [found in the repo README](https://github.com/keylase/nvidia-patch?tab=readme-ov-file#version-table), download the appropriate driver that can be patched. At the time of writing, I used version `570.153.02`. Starting on the host, simply get the link for the driver and then:

```
wget <link>
chmod +x ./NVIDIA...
./NVIDIA...
```

As always, reboot the machine. Verify that you can run the command `nvidia-smi`.

Next run the same procedure on the LXC, except when you install using the `--no-kernel-module` flag. Then reboot the LXC.

Finally, wget and run the patch bash script on both the host and LXC. Finally, verify that `nvidia-smi` runs on both machines. 

### Troubleshooting

After a major or kernel upgrade, the Nvidia driver may need to be reinstalled/repatched for the latest kernel version. Try to install the driver as noted above. You may need to use dkms to rebuild the driver:

```
dkms install nvidia/570.153.02 -k $(uname -r)
```

