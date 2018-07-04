#!/bin/bash

multipass launch \
  --disk $DISK_SIZE \
  --mem $MEM_SIZE \
  --cpus $CPU_COUNT \
  -n $VM_NAME \
  --cloud-init $CLOUD_INIT_FILE \
  bionic

multipass exec $VM_NAME -- mkdir -p /home/multipass/bcm

multipass mount ~/git/github/bitcoincachemachine $VM_NAME:/home/multipass/bcm

multipass exec $VM_NAME -- bcm/lxc_up.sh
