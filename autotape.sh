#!/bin/bash

### Config options ###
BACKUP_DIRS="/home/jake/Documents/wallpaper"
DRIVE="/dev/st0"
RECHECK_WAIT=60
MT="/bin/mt"
TAR="/bin/tar"


### Functions ###

Do_backup()
{
  echo "Doing backup..."
  ${TAR} -cf ${DRIVE} ${BACKUP_DIRS}
  exit 0
}

Check_drive()
{
  if [ ! -e ${DRIVE} ]; then
    echo "No drive connected" >&2
    EXIT_STATE=1

  elif [ -e ${DRIVE} ]; then   
       echo "Drive connected, contiuing"
    EXIT_STATE=0 
  
  else
       echo "Unknown error" >&2
    EXIT_STATE=3
  fi
}

Check_tape()
{
TESTTAPE=`${MT} -f ${DRIVE} status | grep DR_OPEN`
  if [ $? == 0 ]; then
    echo "No tape in drive" >&2
    EXIT_STATE=1

  else
    echo "Tape seems to be in drive, contiuing"
    EXIT_STATE=0   
  fi
}

Check_utils()
{
if [ ! -x ${MT} ]; then
  echo "Program ${MT} dosen't seem to exist..." >&2
  exit 1
fi

if [ ! -x ${TAR} ]; then
  echo "Program ${TAR} doesn't seem to exist..." >&2
  exit 1
fi
}
  

### Main routine ###

# Check if the utils/programs exists
Check_utils

# Check and repeat until the tape drive is on
EXIT_STATE=3
while [ ${EXIT_STATE} != 0 ]; do
  Check_drive
    if [ ${EXIT_STATE} != 0 ]; then
      sleep ${RECHECK_WAIT}
    fi
done

# Check and repeat until a tape is inserted
EXIT_STATE=3
while [ ${EXIT_STATE} != 0 ]; do
  Check_tape
    if [ ${EXIT_STATE} != 0 ]; then
      sleep ${RECHECK_WAIT}
    fi
done

Do_backup

