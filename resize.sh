#!/bin/bash

# Set or unset values of shell options and positional parameters.
# Exit immediately if a command exits with a non-zero status.
set -e

# Check that what we need is installed
for command in parted fdisk expr mkfs.ext4 e2label resize2fs; do
  which $command 2>&1 >/dev/null
  if (( $? != 0 )); then
    echo "ERROR: $command is not installed."
    exit -4
  fi
done

# Since we know what partition it is already
DEVICE="/dev/mmcblk0"
PARTNR="3"

# create the full dev path for that specific partition
DEVPART="$DEVICE"
DEVPART+="p$PARTNR"

# Just checking to see if the partition is available
fdisk -l $DEVPART >> /dev/null 2>&1 || (echo "could not find device $DEVPART - please check the name" && exit 1)

CURRENTSIZEB=`fdisk -l $DEVPART | grep "Disk $DEVPART" | cut -d' ' -f5`
CURRENTSIZE=`expr $CURRENTSIZEB / 1024 / 1024`
# So get the disk-informations of our device in question printf %s\\n 'unit MB print list' | parted | grep "Disk /dev/sda we use printf %s\\n 'unit MB print list' to ensure the units are displayed as MB, since otherwise it will vary by disk size ( MB, G, T ) and there is no better way to do this with parted 3 or 4 yet
# then use the 3rd column of the output (disk size) cut -d' ' -f3 (divided by space)
# and finally cut off the unit 'MB' with blanc using tr -d MB
MAXSIZEMB=`printf %s\\n 'unit MB print list' | parted | grep "Disk ${DEVICE}" | cut -d' ' -f3 | tr -d MB`

# Calculate the size of the partition for resize2fs to use (Partition has to be at the end)
PARTSTARTMB=$(parted $DEVICE -ms unit MB p | grep "^${PARTNR}" | cut -f 2 -d: | sed 's/[^0-9]//g')
RESIZEFSMB=`expr $MAXSIZEMB - $PARTSTARTMB`
RESIZEFSMB+="M"

echo "[ok] resizing from ${CURRENTSIZE}MB to ${MAXSIZEMB}MB "

echo "[ok] parted: resizing partition.."
parted ${DEVICE} resizepart ${PARTNR} ${MAXSIZEMB}

echo "[ok] mkfs: making new ext4 fs.."
mkfs.ext4 $DEVPART

echo "[ok] resize2fs: setting new fs for usage.."
resize2fs -p $DEVPART $RESIZEFSMB

echo "[ok] e2label: relabeling partition to workspace.."
e2label /dev/mmcblk0p3 workspace

echo "[ok] creating workspace folder in root.."
mkdir /workspace && chmod 775 /workspace

echo "[ok] fstab: adding workspace partition to mount on boot.."
echo "LABEL=workspace     /workspace   ext4   defaults 0 0" | tee -a /etc/fstab >/dev/null

echo "[Done]"