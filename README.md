# Parted Auto Resize

`resize a partition non-interactive to its maximum size`

## Long Story

Since using fdisk in this case is pretty complicated due to the case that non-interactive ways are probably not possible or very complicated using printf, I want to use `parted resizepart` for resizing a partition to its maximum size.

This can be used in scenarios like disk-resizes ( hypervisor / virtualization ). Now you need to adjust your logical volume / pv to the new size (LVM case) or you want to adjust the partition size of a normal partition.

So lets assume I want to resize partition /dev/sda1 on disk /dev/sda to its maximum possible size - how would I do this without getting asked any questions at all.

Even though `parted /dev/sda resizepart 1` exists, it needs **me to calculate** and enter the maximum disk size - so how to automate this would be the next question - and the answer was the reason `parted auto resize` has been written.

## Dependencies

- parted 3.0 or higher (otherwise probably rename `parted resizepart` to `parted resize`)

## Usage

Script modified to run in conjunction with Drewsif/PiShrink

Will place this script in rc.local of a raspberry pi to boot on first boot.

Just define the very last partition on the SD card. It will expand to the maximum size of the card.

NOTE: will expand the partition from the start of that partition to the end of the card, so if there is a partition in between that block, might break.

## Scenarios / Motivation

Made the OS part of Raspbian to be read only, but want to be able to utilize the unused portion of a SD card to write data to it.

Script helped auto expand the writable portion of the card.

## Special Thanks

To the original author [eugenmayer](https://github.com/EugenMayer/parted-auto-resize)
