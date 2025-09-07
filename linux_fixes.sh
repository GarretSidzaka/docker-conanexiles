#/bin/bash

echo "vm.max_map_count=1048576" | sudo tee /etc/sysctl.d/99-max_map_count.conf
