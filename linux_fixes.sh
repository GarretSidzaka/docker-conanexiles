#/bin/bash
# check for root
if [ "$EUID" -ne 0 ]
  then echo "Please run with root privileges"
  exit 1
fi
if [ -f ~/.linuxperf ]
  then echo "You should never run this script twice."
  exit 1
fi

#bug fix as per https://www.reddit.com/r/ConanExiles/comments/1dbuiqd/dedicated_server_on_linux_hangs_and_players/
echo "Setting vm.max_map_count to 1048576" && sleep 1
echo "vm.max_map_count=1048576" | tee /etc/sysctl.d/99-max_map_count.conf

#multiple tweaks from https://www.baeldung.com/linux/optimize-performance-efficiency-speed
echo "Setting cpufreq scaling_governor to performance" && sleep 1
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo "Setting vm.swappiness to 10" && sleep 1
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
echo "Setting hugepages to 1024" && sleep 1
echo 1024 | tee /proc/sys/vm/nr_hugepages
echo "Checking hugepages" && sleep 1
grep Huge /proc/meminfo
echo "Adusting network buffers" && sleep 1
echo 'net.core.rmem_max=16777216' | tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' | tee -a /etc/sysctl.conf


touch ~/.linuxperf
