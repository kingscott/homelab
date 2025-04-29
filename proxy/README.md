# Proxy setup

Make sure you have the correct firewall rules setup in the primary homelab README. 

Next, generate the Cloudflare key for the DDNS service:

1. Login to the Cloudflare dashboard
2. Go to My Profile > API Tokens
3. Create Token > Edit Zone DNS template
4. Point Specific Zone to kingscott.ca
5. Continue and Save
6. Copy token to docker compose file