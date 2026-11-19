#! /bin/bash

# script to check connectivity
# defining website / IP / port that will be checked
TARGET_DNS="comptia.org"
TARGET_URL="https://comptia.org"
KALI_IP="100.89.232.93"

#define colors for  visible output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # no color

# function to run quietly commands and print success/fail message

function check {
  # Extract message (last argument)
  local msg="${@: -1}"
  # Extract command (all except last argument)
  local cmd=("${@:1:$#-1}")

  "${cmd[@]}" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN} success:${NC} $msg"
   else
    echo -e "${RED} failed:${NC} $msg"
   fi
}


echo " ==Network Connectivity Check Script== "

echo -e "\n checking local IP configuration..."
ip -4 -o addr show | awk '{print $2": "$4}' | cut -d/ -f1

echo -e "\n checking DNS resolution"
check dig +short "$TARGET_DNS" "DNS resolution for $TARGET_DNS completed succesfully"

echo -e "\n checking ping..."
check ping -c 3 "$TARGET_DNS" "Ping to $TARGET_DNS completed successfully."

echo -e "\n checking traceroute..."
check traceroute -m 5 "$TARGET_DNS" "Traceroute to $TARGET_DNS completed successfully."

echo -e "\n checking HTTPS service availability..."
check curl -Is --max-time 5 "$TARGET_URL" "HTTPS service at $TARGET_URL is reachable."

echo -e "\n checking TCP port $TARGET_PORT (SSH)..."
check nc -z -w2 "$KALI_IP" 22 "Port 22 (SSH) on Kali machine ($KALI_IP) is open."

echo -e "\n checking TCP port 80 (HTTP)..."
check nc -z -w2 "$TARGET_DNS" 80 "Port 80 (HTTP) on $TARGET_DNS is open."

echo -e "\n checking TCP port 443 (HTTPS)..."
check nc -z -w2 "$TARGET_DNS" 443 "Port 443 (HTTPS) on $TARGET_DNS is open."

echo -e "\n  running mtr report (5 packets)..."
check mtr -c 5 --report "$TARGET_DNS" "mtr to $TARGET_DNS completed successfully."

echo -e "\n All checks complete." 

