#!/bin/sh

# --- SETTINGS ---
WEBHOOK_URL="INSERT DISCORD WEBHOOK_URL HERE"
FRIENDLY_NAME="INSERT DISCORD POST SPEEDTEST TITLE HERE"
DISCORD_USER="INSERT DISCORD POST DISPLAY USERNAME HERE"
LOG_FILE="/root/speedtest.log"
# ----------------------

DATE=$(date "+%Y-%m-%d %H:%M")

# Run Speedtest-go (Single Thread, ICMP Ping)
RAW_JSON=$(/usr/bin/speedtest-go --thread 1 --ping-mode=icmp --json 2>&1)

if echo "$RAW_JSON" | grep -q "dl_speed"; then
    
    # 1. PARSING: Extract and convert all data using JQ
    PARSED=$(echo "$RAW_JSON" | jq -r '
        .servers[0] | 
        [
            (.dl_speed / 125000), 
            (.ul_speed / 125000), 
            (.latency / 1000000), 
            (.min_latency / 1000000), 
            (.max_latency / 1000000), 
            (.jitter / 1000000), 
            .sponsor, 
            .distance,
            .packet_loss.sent,
            .packet_loss.max
        ] | join("|")')

    # 2. ASSIGN: Split values into variables
    IFS="|" read -r DL UL PNG PMIN PMAX JIT SRV DST SENT MAX <<EOF
$PARSED
EOF

    # 3. FORMAT: Rounding
    DL_MBPS=$(printf "%.2f" $DL)
    UL_MBPS=$(printf "%.2f" $UL)
    PNG_MS=$(printf "%.2f" $PNG)
    PMIN_MS=$(printf "%.2f" $PMIN)
    PMAX_MS=$(printf "%.2f" $PMAX)
    JIT_MS=$(printf "%.2f" $JIT)
    DST_KM=$(printf "%.1f" $DST)

    # 4. PACKET LOSS: Your verified logic (diff = sent - max)
    LOSS_VAL=$(awk -v s="$SENT" -v m="$MAX" 'BEGIN { 
        diff = s - m;
        if (diff <= 1 || s == 0) {
            print "0.00"
        } else {
            printf "%.2f", (diff * 100) / s
        }
    }')

    # 5. CONTENT: Build the Discord post
    CONTENT="**$FRIENDLY_NAME**
$DATE
Server: $SRV ($DST_KM km)
\`\`\`
Ping:     $PNG_MS ms [$PMIN_MS-$PMAX_MS]
Download: $DL_MBPS Mbps
Upload:   $UL_MBPS Mbps
Jitter:   $JIT_MS ms
Loss:     $LOSS_VAL%
\`\`\`"

    # Log to file
    echo "$DATE | Ping: $PNG_MS ms Download: $DL_MBPS Mbps Upload: $UL_MBPS Mbps" >> "$LOG_FILE"

else
    CONTENT="**$FRIENDLY_NAME - ERROR**
$DATE
Speedtest failed."
    echo "$DATE | Speedtest Failed" >> "$LOG_FILE"
fi

# 6. SEND: Post to Discord using a safe JQ-generated payload
PAYLOAD=$(jq -n --arg user "$DISCORD_USER" --arg cont "$CONTENT" '{username: $user, content: $cont}')
/usr/bin/curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL" > /dev/null
