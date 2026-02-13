#!/bin/bash
#
# stop_all_instances.sh
# Stops all running Audio Toggle instances on macOS/Linux
# Only targets scripts from known installation paths with verified identifiers
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
DARKGRAY='\033[0;37m'
NC='\033[0m' # No Color

# Unique identifier to verify legitimate Audio Toggle scripts
AUDIO_TOGGLE_ID="AudioToggle-pechavarriaa-CrossPlatformAudioToggle-v1.0"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    SCRIPT_NAME="audio_toggle_mac.py"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    SCRIPT_NAME="audio_toggle_linux.py"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

# Expected installation paths
CURRENT_DIR_SCRIPT="$(cd "$(dirname "$0")" && pwd)/$SCRIPT_NAME"
# Note: Standard installation path would be set during install, for now check current dir

echo -e "${CYAN}Searching for Audio Toggle instances on $OS...${NC}"
echo -e "${GRAY}Expected script: $CURRENT_DIR_SCRIPT${NC}"
echo ""

# Find all Python processes
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use ps with different options
    ALL_PYTHON_PROCS=$(ps -Ao pid,command | grep -E "python.*$SCRIPT_NAME" | grep -v grep || true)
else
    # Linux: Standard ps
    ALL_PYTHON_PROCS=$(ps aux | grep -E "python.*$SCRIPT_NAME" | grep -v grep || true)
fi

if [ -z "$ALL_PYTHON_PROCS" ]; then
    echo -e "${GREEN}No Python processes running $SCRIPT_NAME found.${NC}"

    # Check for stale lockfile
    LOCKFILE="$HOME/.config/audio_toggle/.audio_toggle.lock"
    if [ -f "$LOCKFILE" ]; then
        echo -e "${YELLOW}Found stale lockfile at: $LOCKFILE${NC}"
        read -p "Remove it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$LOCKFILE"
            echo -e "${GREEN}✓ Lockfile removed${NC}"
        fi
    fi
    exit 0
fi

# Array to store verified Audio Toggle processes
declare -a VERIFIED_PIDS
declare -a VERIFIED_PATHS
declare -a SKIPPED_PIDS

# Check each process
while IFS= read -r line; do
    # Extract PID (first field)
    PID=$(echo "$line" | awk '{print $1}')

    # Extract full command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CMD=$(echo "$line" | cut -d' ' -f2-)
    else
        CMD=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=""; print $0}' | sed 's/^ *//')
    fi

    # Try to extract script path from command line
    SCRIPT_PATH=""

    # Pattern 1: python3 /full/path/script.py
    if [[ "$CMD" =~ python[0-9.]*[[:space:]]+(/[^[:space:]]+$SCRIPT_NAME) ]]; then
        SCRIPT_PATH="${BASH_REMATCH[1]}"
    # Pattern 2: python3 script.py (relative path)
    elif [[ "$CMD" =~ python[0-9.]*[[:space:]]+([^/][^[:space:]]*$SCRIPT_NAME) ]]; then
        # Try to resolve relative path using lsof
        if command -v lsof &> /dev/null; then
            SCRIPT_PATH=$(lsof -p "$PID" 2>/dev/null | grep "$SCRIPT_NAME" | awk '{print $NF}' | head -1)
        fi
    fi

    # Verify the script if we found a path
    IS_VALID=false
    if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
        # Check if script contains the unique identifier
        if grep -q "$AUDIO_TOGGLE_ID" "$SCRIPT_PATH" 2>/dev/null; then
            IS_VALID=true
            VERIFIED_PIDS+=("$PID")
            VERIFIED_PATHS+=("$SCRIPT_PATH")
        else
            echo -e "${DARKGRAY}Skipping process $PID: Script doesn't contain Audio Toggle identifier${NC}"
            echo -e "${DARKGRAY}  Path: $SCRIPT_PATH${NC}"
            SKIPPED_PIDS+=("$PID")
        fi
    else
        echo -e "${DARKGRAY}Skipping process $PID: Could not verify script path${NC}"
        SKIPPED_PIDS+=("$PID")
    fi

done <<< "$ALL_PYTHON_PROCS"

# Show results
if [ ${#VERIFIED_PIDS[@]} -eq 0 ]; then
    echo -e "${GREEN}No verified Audio Toggle instances found running.${NC}"

    if [ ${#SKIPPED_PIDS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Skipped ${#SKIPPED_PIDS[@]} unverified process(es) to protect your other scripts.${NC}"
    fi

    # Check for stale lockfile
    LOCKFILE="$HOME/.config/audio_toggle/.audio_toggle.lock"
    if [ -f "$LOCKFILE" ]; then
        echo ""
        echo -e "${YELLOW}Found stale lockfile at: $LOCKFILE${NC}"
        read -p "Remove it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$LOCKFILE"
            echo -e "${GREEN}✓ Lockfile removed${NC}"
        fi
    fi
    exit 0
fi

echo -e "${YELLOW}Found ${#VERIFIED_PIDS[@]} verified Audio Toggle instance(s):${NC}"
echo ""

# Show verified processes
for i in "${!VERIFIED_PIDS[@]}"; do
    echo -e "  - PID ${VERIFIED_PIDS[$i]}: ${GRAY}${VERIFIED_PATHS[$i]}${NC}"
done

if [ ${#SKIPPED_PIDS[@]} -gt 0 ]; then
    echo ""
    echo -e "${DARKGRAY}Skipped ${#SKIPPED_PIDS[@]} unverified process(es) for safety.${NC}"
fi

echo ""

# Confirmation prompt
read -p "Stop these verified processes? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Stop the verified processes
for PID in "${VERIFIED_PIDS[@]}"; do
    if kill "$PID" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Stopped PID $PID${NC}"
    else
        echo -e "  ${RED}✗ Failed to stop PID $PID (may require sudo)${NC}"
    fi
done

# Clean up lockfile
LOCKFILE="$HOME/.config/audio_toggle/.audio_toggle.lock"
if [ -f "$LOCKFILE" ]; then
    rm -f "$LOCKFILE"
    echo -e "${GREEN}✓ Cleaned up lockfile${NC}"
fi

echo ""
echo -e "${GREEN}✓ Done.${NC}"
echo -e "You can now run ${CYAN}python3 $SCRIPT_NAME${NC} again."
echo ""
