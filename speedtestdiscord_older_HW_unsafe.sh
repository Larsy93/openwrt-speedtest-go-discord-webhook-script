#!/bin/sh

# --- SETTINGS ---
WEBHOOK_URL="INSERT DISCORD WEBHOOK_URL HERE"
FRIENDLY_NAME="INSERT DISCORD POST SPEEDTEST TITLE HERE"
DISCORD_USER="INSERT DISCORD POST DISPLAY USERNAME HERE"
LOG_FILE="/root/speedtest.log"
# ----------------------

DATE=$(date "+%Y-%m-%d %H:%M")

# Run Speedtest-go SINGLE THREAD ICMP PING
RAW_JSON=$(/usr/bin/speedtest-go --thread 1 --ping-mode=icmp --json 2>&1)

if echo "$RAW_JSON" | grep -q "dl_speed"; then
    
    # Read and Parse JSON
    eval $(echo "$RAW_JSON" | awk -F'[:,]' '{
        for(i=1;i<=NF;i++){
            if($i ~ /"dl_speed"/) dl=$(i+1)
            if($i ~ /"ul_speed"/) ul=$(i+1)
            if($i ~ /"latency"/) png=$(i+1)
            if($i ~ /"min_latency"/) pmin=$(i+1)
            if($i ~ /"max_latency"/) pmax=$(i+1)
            if($i ~ /"jitter"/) jit=$(i+1)
            if($i ~ /"distance"/) dst=$(i+1)
            if($i ~ /"sent"/) sent=$(i+1)
            if($i ~ /"max"/) max=$(i+1)
            if($i ~ /"sponsor"/) spon=$(i+1)
        }
        # Unit conversions (Bytes->Mbps, Nano->Milli)
        printf "DL_MBPS=%.2f\n", dl/125000
        printf "UL_MBPS=%.2f\n", ul/125000
        printf "PNG_MS=%.2f\n", png/1000000
        printf "PMIN_MS=%.2f\n", pmin/1000000
        printf "PMAX_MS=%.2f\n", pmax/1000000
        printf "JIT_MS=%.2f\n", jit/1000000
        printf "DST_KM=%.1f\n", dst
        printf "SRV=%s\n", spon
        
        # Packet loss logic
        diff = sent - max
        if (diff <= 1) printf "LOSS_VAL=0.00\n"
        else printf "LOSS_VAL=%.2f\n", (diff * 100) / sent
    }')

    # Create Content (Using variable FRIENDLY_NAME)
    CONTENT="**$FRIENDLY_NAME**\\n$DATE\\nServer: ${SRV//\"/} ($DST_KM km)\`\`\`\\nPing:     $PNG_MS ms [$PMIN_MS-$PMAX_MS]\\nDownload: $DL_MBPS Mbps\\nUpload:   $UL_MBPS Mbps\\nJitter:   $JIT_MS ms\\nLoss:     $LOSS_VAL%\\n\`\`\`"

    # Log locally
    echo "$DATE | Ping: $PNG_MS ms Download: $DL_MBPS Mbit/s Upload: $UL_MBPS Mbit/s" >> $LOG_FILE

else
    CONTENT="**$FRIENDLY_NAME - ERROR**\\n$DATE\\nSpeedtest failed."
    echo "$DATE | Speedtest Failed" >> $LOG_FILE
fi

# Send to Discord
/usr/bin/curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"username\": \"$DISCORD_USER\", \"content\": \"$CONTENT\"}" \
     $WEBHOOK_URL > /dev/null
