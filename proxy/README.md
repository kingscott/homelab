# Proxy setup

Make sure you have the correct firewall rules setup in the primary homelab README. 

Next, generate the Cloudflare key for the DDNS service:

1. Login to the Cloudflare dashboard
2. Go to My Profile > API Tokens
3. Create Token > Edit Zone DNS template
4. Point Specific Zone to kingscott.ca
5. Continue and Save
6. Copy token to docker compose file

## Tailscale

We will want to access the private services outside of the home network. I use Tailscale for this. You can follow the instructions from Tailscale for installing, and authenticating with the service. But while it's running in an LXC, we'll need to give it access to the local `tun` devices from the host. 

Add the following lines to `/etc/pve/lxc/<ctid>.conf` on the **host**:

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry = /dev/net/tun dev/net/tun none bind,create=file
```

Next, reboot the container:

```
pct reboot <ctid>
```

Finally, we'll want to update the A record in Cloudlfare to public from my network's public IP to the IP given by Tailscale. 