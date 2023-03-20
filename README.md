# Mikrotik DuckDNS IPv6 - Using an Advertise Interface's IPv6 Address

## Why does this exists?

My ISP offers IPv6 but I'm unable to use Mikrotik's builtin [Cloud DDNS feature](https://wiki.mikrotik.com/wiki/Manual:IP/Cloud) on my router (`IP` --> `Cloud`).

### Why doesn't Mikrotik Cloud DDNS work?

This is because the initial IPv6 address that's assigned to router via Router Advertisements is an "internal" Global IPv6 address that can only be used to communicate my ISP's DHCPv6 server (I suspect this is due to some obscure security reason I don't understand 🤷‍♂️).

Furthermore once my router has established a DHCPv6 client lease using `Address` & `Prefix` options, the additional IPv6 address that is associated to my router is again isn't able to reach the Internet - Only IPv6 addresses from the assigned prefix block is able to reach the Internet.

So what I need is a way to set a DDNS & DuckDNS is my choice in DDNS (I used to work with the one developers of it 👍 - they have no association to this script/repo/etc.).

## How does it work?

The script uses the IPv6 address that you assigned & advertised to your local network and associates it with your DuckDNS subdomain.

## How to install

Open Winbox and connect to your router...

### 1 - Install script

1) Create a new Script (`System` > `Script`)
2) Name it `duckdns-ipv6`
3) Copy [script.rsc](./script.rsc) into script section
4) Populate the top 3 lines with your subdomain, token & the interface that you have associated your IPv6 prefix too (e.g. `bridge1`, `ether1`, `vlan1`...)
5) Click "Apply" & "Run Script"
6) Open Logs (`Logs`) and verify that it has ran successfully

### 2 - Schedule the script to run every 6 hours

1) Create a new Scheduler (`Syetem` > `Scheduler`)
2) Name it "duckdns-ipv6"
3) Enter the script `/system script run duckdns-ipv6;` (to run the above script)
4) Set your interval e.g. `06:00:00` to run every 6 hours (my ISP doesn't support static IPv6 prefixes and so I could get a new lease at anytime)
5) Click "Apply"

## References

* [@beeyev's](https://github.com/beeyev) [Mikrotik-Duckdns-Dynamic-IP-Updater](https://github.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater) - Thank you for sharing, without your project I would've been stuck 😀!