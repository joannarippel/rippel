# --- Final, Robust DoS Protection for Metasploitable 2 ---
# These commands create the rules using custom chains to bypass old shell/iptables issues.

# 1. Clear any previous broken rules
sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# 2. Create Custom Chains for Rate Limiting
sudo iptables -N DOS_SYN
sudo iptables -N DOS_HTTP

# 3. CRITICAL SAFETY RULES (Allow Loopback, Established/Related, SSH)
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 4. RULE INJECTION: JUMP TO CUSTOM CHAINS
# New TCP connections (SYNs) go to DOS_SYN
sudo iptables -A INPUT -p tcp --syn -j DOS_SYN
# Web traffic goes to DOS_HTTP (Port 80)
sudo iptables -A INPUT -p tcp --dport 80 -j DOS_HTTP
# Web traffic goes to DOS_HTTP (Port 8180)
sudo iptables -A INPUT -p tcp --dport 8180 -j DOS_HTTP

# 5. DEFINE DOS_SYN CHAIN (Mitigates hping3 SYN Flood)
# Rule 1: ACCEPT packets under the rate limit (5/sec)
sudo iptables -A DOS_SYN -m limit --limit 5/sec --limit-burst 10 -j ACCEPT
# Rule 2: DROP packets over the limit
sudo iptables -A DOS_SYN -j DROP

# 6. DEFINE DOS_HTTP CHAIN (Mitigates GoldenEye HTTP Flood)
# Rule 1: ACCEPT packets under the rate limit (50/min)
sudo iptables -A DOS_HTTP -m limit --limit 50/min --limit-burst 100 -j ACCEPT
# Rule 2: DROP packets over the limit
sudo iptables -A DOS_HTTP -j DROP

# 7. Set final default policy to DROP
sudo iptables -P INPUT DROP

# 8. Verification (Shows the rules are active)
sudo iptables -L INPUT -n --line-numbers
