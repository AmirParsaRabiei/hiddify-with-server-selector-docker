#!/bin/sh
# sysctl -w net.ipv4.ip_forward=1
# sysctl -w net.ipv6.ip_forward=1

# ip rule add fwmark 1 table 100 ; 
# ip route add local 0.0.0.0/0 dev lo table 100 

# # CREATE TABLE
# iptables -t mangle -N hiddify

# # RETURN LOCAL AND LANS
# iptables -t mangle -A OUTPUT -j RETURN
# iptables -t nat -A hiddify --dport 2334 -j RETURN

# iptables -t mangle -A hiddify -d 10.0.0.0/8 -j RETURN
# iptables -t mangle -A hiddify -d 127.0.0.0/8 -j RETURN
# iptables -t mangle -A hiddify -d 169.254.0.0/16 -j RETURN
# iptables -t mangle -A hiddify -d 172.16.0.0/12 -j RETURN
# iptables -t mangle -A hiddify -d 192.168.50.0/16 -j RETURN
# iptables -t mangle -A hiddify -d 192.168.9.0/16 -j RETURN
# iptables -t mangle -A hiddify -d 224.0.0.0/4 -j RETURN
# iptables -t mangle -A hiddify -d 240.0.0.0/4 -j RETURN

# iptables -t mangle -A hiddify -p udp -j TPROXY --on-port 2334 --tproxy-mark 1
# iptables -t mangle -A hiddify -p tcp -j TPROXY --on-port 2334 --tproxy-mark 1

# # HIJACK ICMP (untested)
# # iptables -t mangle -A hiddify -p icmp -j DNAT --to-destination 127.0.0.1

# # REDIRECT
# iptables -t mangle -A PREROUTING -j hiddify

restart_count=0

while true; do
    # Kill all running instances of HiddifyCli
    killall HiddifyCli

    # Get the current time in seconds since epoch
    current_time=$(date +%s)
    
    # Calculate the target time 12 hours from now
    target_time=$((current_time + SUBS_UPDATE_INTERVAL * 3600))
    
    # Set restarted to false for the new cycle
    restarted="false"
    
    # Check if the hiddify.json configuration file exists
    if [ -f "/hiddify/data/hiddify.json" ]; then
        /hiddify/HiddifyCli run --config "$CONFIG" --hiddify /hiddify/data/hiddify.json &
    else
        /hiddify/HiddifyCli run --config "$CONFIG" &
    fi
    
    # Sleep until the target time
    while true; do
        sleep 60  # Check every minute
        current_time=$(date +%s)
        
        if [ "$current_time" -ge "$target_time" ]; then
            if [ "$restarted" = "false" ]; then
                restarted="true"
                restart_count=$((restart_count + 1))
                echo "Schedule: Restarting HiddifyCli. Restart count: $restart_count"
                break
            fi
        fi
    done
done

