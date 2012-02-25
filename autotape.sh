#!/bin/bash

### Config options ###
BACKUP_DIRS="/mnt/raid1/backups/weekly"
DRIVE="/dev/st0"
RECHECK_WAIT=1200
MT="/bin/mt"
TAR="/bin/tar"


### Functions ###

Do_backup()
{
  sleep 15 # Wait for the tape to get ready...
  echo "Doing backup..."
  ${TAR} -cf ${DRIVE} ${BACKUP_DIRS}
  echo "Backup done!"
  sleep 120 #Just in case wait for the tape drive
  ${MT} -f ${DRIVE} offline
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
    echo "Tape seems to be in the drive, contiuing"
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

Check_backupdir()
{
for dirtest in ${BACKUP_DIRS}; do
  if [ ! -d $dirtest ]; then
  echo "${dirtest} does not exist" >&2
  exit 1
  fi
done
}
  

### Main routine ###

# Check if the utils/programs exists
Check_utils

# Check if the dirs we want to backup exists
Check_backupdir

# Check and repeat until the tape drive is on/connected
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

# Finally, begin with the backup!
Do_backup

