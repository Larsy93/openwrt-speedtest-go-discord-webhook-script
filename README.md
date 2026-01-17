# OpenWrt Speedtest-go to Discord Webhook (v2.0)

[![OpenWrt](https://img.shields.io/badge/Router-OpenWrt-blue.svg)](https://openwrt.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, resource-optimized shell script for routers running **OpenWrt**.
It executes a network speed test using `speedtest-go` and sends a detailed, formatted report to a Discord channel via Webhooks.

---

## 🚀 Key Features

- **Robust JQ Parsing (v2.0)** Now uses `jq` for reliable JSON processing. This ensures that special characters in server names or ISP data don't break the script, while maintaining high performance.

- **Improved Packet Loss Logic** Uses custom logic to handle `speedtest-go` specific quirks (Sent vs Max packets), providing accurate 0.00% reporting even when extra control packets are sent.

- **ICMP Precision** Uses ICMP ping mode for more accurate latency measurements, avoiding the overhead of HTTP/TCP handshakes.

- **Smart Formatting** Reports Download, Upload, Ping (Min/Avg/Max), Jitter, and Packet Loss in a clean, code-blocked Discord message.

---

## 🛠 Prerequisites

Before installing, ensure the following packages are installed on your router:

    opkg update
    opkg install speedtest-go curl jq

---

## 📦 Installation

1. Download the script and place `speedtestdiscord.sh` in the `/root/` directory.

2. Make the script executable:

    chmod +x /root/speedtestdiscord.sh

3. Edit the script and configure the following variables:

- `WEBHOOK_URL` – Your Discord Webhook URL  
- `FRIENDLY_NAME` – Name of your router or location (e.g. Home Router)  
- `DISCORD_USER` – Username displayed by the Discord bot  

---

## ⏱ Automation (Cron)

To run the speed test automatically every hour, add the following scheduled task via LuCI or `crontab -e`:

    0 * * * * /root/speedtest.sh

---

## 🛠 Why this script?

Version 2.0 moves away from `eval` and manual string manipulation. By leveraging `jq`, we achieve:

1. **Security:** No use of `eval`, eliminating potential shell injection risks.
2. **Reliability:** Proper JSON handling regardless of the input data format.
3. **Efficiency:** Data is parsed in a single stream, keeping CPU overhead minimal even on budget routers.

The script is specifically tuned for the **speedtest-go** implementation, ensuring that unit conversions (Bytes to Mbps) and latency (Nanoseconds to Milliseconds) are calculated with high precision.

---

## 📜 Credits

This script relies on the excellent **speedtest-go** tool developed by **showwin**.  
All speed measurement logic is handled by their Go-based Speedtest CLI implementation.

https://github.com/showwin/speedtest-go

---

Created with a focus on performance, accuracy, and OpenWrt-friendly design.
