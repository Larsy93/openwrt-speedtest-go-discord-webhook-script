# OpenWrt Speedtest-go to Discord Webhook

[![OpenWrt](https://img.shields.io/badge/Router-OpenWrt-blue.svg)](https://openwrt.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, resource-optimized shell script for routers running **OpenWrt**.
It executes a network speed test using `speedtest-go` and sends a detailed, formatted report to a Discord channel via Webhooks.

---

## 🚀 Key Features

- **Ultra-Low CPU Usage**  
  Uses a single-pass `awk` parser to process JSON data.  
  Unlike scripts that spawn multiple `grep`, `cut`, and `sed` processes, this script handles everything in one stream, making it ideal for low-power router CPUs.

- **ICMP Precision**  
  Uses ICMP ping mode for more accurate latency measurements, avoiding the overhead of HTTP/TCP handshakes.

- **Smart Formatting**  
  Reports Download, Upload, Ping (Min/Avg/Max), Jitter, and Packet Loss in a clean, code-blocked Discord message.

- **Universal Compatibility**  
  Works on any OpenWrt-based router (GL.iNet, TP-Link, Linksys, etc.) with `speedtest-go` installed.

---

## 🛠 Prerequisites

Before installing, ensure the following packages are installed on your router:

```bash
opkg update
opkg install speedtest-go curl
```

---

## 📦 Installation

1. Download the script and place `speedtest.sh` in the `/root/` directory.

2. Make the script executable:

```bash
chmod +x /root/speedtest.sh
```

3. Open the script and configure the following variables:

- `WEBHOOK_URL` – Your Discord Webhook URL  
- `FRIENDLY_NAME` – Name of your router or location (e.g. Home Router)  
- `DISCORD_USER` – Username displayed by the Discord bot  

---

## ⏱ Automation (Cron)

To run the speed test automatically every hour, add the following scheduled task via LuCI or `crontab -e`:

```bash
0 * * * * /root/speedtest.sh
```

---

## 🛠 Why this script?

Many shell-based speed test scripts pipe data through multiple processes:

```
grep | cut | sed | awk | grep | sed
```

Each pipe spawns a new process. On resource-constrained routers, this results in unnecessary CPU usage and load spikes.

This script parses the entire JSON output from `speedtest-go` in a single `awk` loop, handling:

- JSON parsing  
- Unit conversion  
- Mathematical calculations  
- Output formatting  

All in one pass, keeping CPU usage low and performance consistent.

---

## 📜 Credits

This script relies on the excellent **speedtest-go** tool developed by **showwin**.
All speed measurement logic is handled by their Go-based Speedtest CLI implementation.

https://github.com/showwin/speedtest-go

---

Created with a focus on performance, accuracy, and OpenWrt-friendly design.
