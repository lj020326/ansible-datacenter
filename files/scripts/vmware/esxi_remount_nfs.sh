#!/bin/sh
ssh root@esx2.johnson.int "esxcfg-nas -r"
ssh root@esx2.johnson.int "vim-cmd vmsvc/power.on 59"
