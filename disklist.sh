#!/bin/bash
# This script is executed upon PreLaunch of the apple2driver service or can be run manually
# It makes use of the Ciderpress mdc command to get the volume label of the disk images.
# https://github.com/fadden/ciderpress/tree/master/linux
# Get a list of disk images in /home/pi/disks folder
ls -1 /home/pi/a2io-rpi-menu/disks/*.po | xargs -n 1 basename > /home/pi/Apple2-IO-RPi/RaspberryPi/driveimage/disklist.txt
# create array of these filenames
readarray -t a < /home/pi/Apple2-IO-RPi/RaspberryPi/driveimage/disklist.txt
ITER=0
# iterate over the array and extract volume name from each prodos disk using cidertools for linux
for f in "${a[@]}"
do
  #echo $f
  pdl=$(/home/pi/ciderpress/mdc /home/pi/a2io-rpi-menu/disks/$f | grep "Disk:" )
  vol=$(echo "${pdl}" | sed -e 's/.*\/\(.*\) (.*/\1/')
  echo "VOL NAME: $vol "  
  vn[${ITER}]=$vol
  ITER=$(expr $ITER + 1)
done
# bulid the Startup.bas file that will run upon boot from usb attached Linux box
cat > /home/pi/Apple2-IO-RPi/RaspberryPi/driveimage/Startup.bas <<EOF
100 REM Author: Dan Brownlee
101 REM https://github.com/DanBrownleeOps/A2IO-RPI-Menu
102 REM Present list of disks to boot from Apple2-IO-RPi Linux server 
104 PRINT CHR\$ (4)"-clock.driver"
106 PRINT CHR\$ (4)"-rpi.command"
110 HOME
120 DIM VN\$(20)
140 DIM BF\$(20)
160 DIM DF\$(20)
180 REM THESE ARE THE PRODOS DISK IMAGES BY FILENAME
200 DATA "${a[0]}", "${a[1]}", "${a[2]}", "${a[3]}", "${a[4]}"
220 DATA "${a[5]}", "${a[6]}", "${a[7]}", "${a[8]}", "${a[9]}"
240 DATA "${a[10]}", "${a[11]}", "${a[12]}", "${a[13]}", "${a[14]}"
260 DATA "${a[15]}", "${a[16]}", "${a[17]}", "${a[18]}", "${a[19]}"
280 REM SET THESE TO PRODOS UNLESS YOU KNOW BETTER
300 DATA "PRODOS", "LAUNCHER.SYSTEM", "PRODOS", "PRODOS", "PRODOS"
320 DATA "PRODOS", "PRODOS", "PRODOS", "PRODOS", "PRODOS"
340 DATA "PRODOS", "PRODOS", "PRODOS", "PRODOS", "PRODOS"
360 DATA "PRODOS", "PRODOS", "PRODOS", "PRODOS", "PRODOS"
380 REM THESE ARE THE VOLUME NAMES FOR PRETTIER OUTPUT ON THE MENU
400 DATA "${vn[0]}", "${vn[1]}", "${vn[2]}", "${vn[3]}", "${vn[4]}"
420 DATA "${vn[5]}", "${vn[6]}", "${vn[7]}", "${vn[8]}", "${vn[9]}"
440 DATA "${vn[10]}", "${vn[11]}", "${vn[12]}", "${vn[13]}", "${vn[14]}"
460 DATA "${vn[15]}", "${vn[16]}", "${vn[17]}", "${vn[18]}", "${vn[19]}"
480 REM SIMPLE MENU SELECTOR
500 PRINT "Select disk to run from list:"
520 FOR I = 0 TO 19
540 READ DF\$(I)
560 NEXT I
580 FOR B = 0 TO 19
600 READ BF\$(B)
620 NEXT B
640 FOR V = 0 TO 19
660 READ VN\$(V)
680 PRINT VN\$(V)
700 NEXT V
702 VL = 2
704 VTAB VL
706 INVERSE
708 PRINT VN\$ (VL - 2)
710 NORMAL
714 VTAB 22
720 PRINT "Use up/down arrow keys or ESC to quit or  "
722 PRINT "OA-F, firmware. OA-D, A2IO Default. :"; : GET CH\$
730 HTAB 1
740 IF ASC (CH\$) = 11 THEN VTAB VL : PRINT VN\$ (VL - 2) : VL = VL - 1: IF VL < 2 THEN VL = 2
750 IF ASC (CH\$) = 10 THEN VTAB VL : PRINT VN\$ (VL - 2) : VL = VL + 1: IF VL > 22 THEN VL = 22
745 IF ASC (CH\$) = 100 OR ASC (CH\$) = 68 THEN DF\$(SD) = "DEFAULT.HDV" : GOTO 820
747 IF ASC (CH\$) = 102 OR ASC (CH\$) = 70 THEN DF\$(SD) = "FIRMWARE.HDV" : GOTO 820
760 IF ASC (CH\$) = 13 THEN SD = VL - 2 : GOTO 820
770 IF ASC (CH\$) = 27 THEN HOME : END
780 GOTO 704
790 SD = VAL ( C\$ ) - 1
800 REM LOAD THE SELECTED IMAGE INTO DRIVE TWO AND LOAD AND RUN
810 REM PRINT CHR\$ (4)"-rpi.command"
820 PRINT "Loading selected disk: /home/pi/a2io-rpi-menu/disks/" + DF\$(SD)
830 PRINT CHR\$ (4)"rpi a2drive 2 load /home/pi/a2io-rpi-menu/disks/" + DF\$(SD)
840 PRINT CHR\$ (4)"PREFIX,S7,D2"
850 PRINT "ProDos loading image: " + BF\$(SD)
860 PRINT CHR\$ (4)"-" + BF\$(SD)
870 END
EOF
