#!/bin/bash

### Config options ###
DRIVE="/dev/st0"


### Functions ###

Do_backup()
{
  echo "Doing backup"
  exit 0
}


Check_drive()
{
  if [ ! -e ${DRIVE} ]; then
    echo "No drive connected"
    EXIT_STATE=1

  elif [ -e ${DRIVE} ]; then   
       echo "Drive connected, contiuing"
    EXIT_STATE=0 
  
  else
       echo "Unknown error"
    EXIT_STATE=3
  fi
}


Check_tape()
{
TESTTAPE=`mt -f ${DRIVE} status | grep DR_OPEN`
  if [ $? == 0 ]; then
    echo "No tape in drive, aborting"
    exit 1

  else
    echo "Tape seems to exist"
    exit 0   
  fi
}
  

### Main routine ###

EXIT_STATE=3
while [ ${EXIT_STATE} != 0 ]; do
  Check_drive
    if [ ${EXIT_STATE} != 0 ]; then
      sleep 20
    fi
done
