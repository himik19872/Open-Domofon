#!/bin/sh
#===============================================================================
# OpenIPC Doorphone - Temporary Keys Expiry Checker
# Runs every hour via cron to remove expired temporary keys
#===============================================================================

# Configuration
KEYS_FILE="/etc/door_keys.conf"
TEMP_FILE="/tmp/keys.tmp"
LOG_FILE="/var/log/door_monitor.log"

# Function for logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - CLEANUP - $1" >> "$LOG_FILE"
}

# Check if keys file exists
if [ ! -f "$KEYS_FILE" ]; then
    log "Keys file not found: $KEYS_FILE"
    exit 1
fi

# Get current Unix timestamp
CURRENT_TIME=$(date +%s)
log "Starting cleanup. Current time: $(date)"

# Counter for removed keys
REMOVED=0
TOTAL=0

# Process each line in keys file
while IFS='|' read -r key owner expiry; do
    # Skip empty lines
    [ -z "$key" ] && continue
    
    TOTAL=$((TOTAL + 1))
    
    # Check if this is a temporary key (has expiry timestamp)
    if [ -n "$expiry" ] && [ "$expiry" -eq "$expiry" ] 2>/dev/null; then
        # This is a temporary key with numeric expiry
        if [ "$expiry" -lt "$CURRENT_TIME" ]; then
            # Key expired - add to temp file (inverse grep)
            log "REMOVED: Expired key $key for $owner (expired: $(date -d @$expiry '+%Y-%m-%d %H:%M:%S'))"
            REMOVED=$((REMOVED + 1))
        else
            # Key still valid - keep it
            echo "$key|$owner|$expiry" >> "$TEMP_FILE"
        fi
    else
        # Permanent key (no expiry) - keep it
        echo "$key|$owner|$expiry" >> "$TEMP_FILE"
    fi
done < "$KEYS_FILE"

# If we removed any keys, replace the file
if [ $REMOVED -gt 0 ]; then
    mv "$TEMP_FILE" "$KEYS_FILE"
    chmod 666 "$KEYS_FILE"
    log "Cleanup complete: removed $REMOVED expired keys, kept $((TOTAL - REMOVED)) keys"
else
    # No changes needed
    rm -f "$TEMP_FILE"
    log "Cleanup complete: no expired keys found"
fi

exit 0