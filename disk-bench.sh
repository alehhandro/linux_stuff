#!/bin/bash
### INFO
##
##

### VARS
##
REPORT_FILE=fio_report_`date +"%m-%d-%Y"`.txt

### HELPER FUNCTIONS
##
touch ${REPORT_FILE} 

### FUNCTIONS
##

am_i_root(){
## Check if the user is root

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
else
  echo "Script is run using 'root' account, will continue..."
fi
}

fio_install(){
## Check if the 'fio' utility is installed

  dpkg -s fio&> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "'fio' utility is installed, will continue..."
  else
    echo "Proceeding with the installation of the 'fio' utility..."
    apt-get install fio -y
    if [[ $? -eq 0 ]]; then
      echo "'fio' utility was installed succesfully, will continue..."
    else
      echo "Installation was not finished succesfully, run again with 'bash -x $0'"
    fi
  fi
}

fio_random_r(){
  echo -e "Random read >>>\n"
  echo -e "\nRandom read operation\n" >> ${REPORT_FILE}

  fio --randrepeat=1\
	  --ioengine=libaio\
	  --direct=1\
	  --gtod_reduce=1\
	  --name=blk-tst\
	  --filename=blk-tst\
	  --bs=4k\
	  --iodepth=64\
	  --size=40M\
	  --readwrite=randread >> ${REPORT_FILE}
  printf '=%.0s' {1..30} >> ${REPORT_FILE}
  rm -rf blk-tst
}

fio_random_w(){
  echo -e "Random write >>> \n"
  echo -e "\nRandom write operation\n" >> ${REPORT_FILE}  
  fio --randrepeat=1\
	  --ioengine=libaio\
	  --direct=1\
	  --gtod_reduce=1\
	  --name=blk-tst\
	  --filename=blk-tst\
	  --bs=4k\
	  --iodepth=64\
	  --size=40M\
	  --readwrite=randwrite >> ${REPORT_FILE}
  printf '=%.0s' {1..30} >> ${REPORT_FILE}
}

fio_random_rw(){
  echo -e "Random read-write\n"
  echo -e "\nRandom read and write operations (mixed)\n" >> ${REPORT_FILE}
  fio --randrepeat=1\
	  --ioengine=libaio\
	  --direct=1\
	  --gtod_reduce=1\
	  --name=blk-tst\
	  --filename=blk-tst\
	  --bs=4k\
	  --iodepth=64\
	  --size=40M\
	  --readwrite=randrw\
	  --rwmixread=75 >> ${REPORT_FILE}
  printf '=%.0s' {1..30} >> ${REPORT_FILE}
  rm -rf blk-tst
}

end_of_script(){
  echo "The script has been executed succesfully"
  echo "You can find the details in the report file > ${REPORT_FILE}"
}

### SCRIPT START
##

am_i_root
fio_install
fio_random_r
fio_random_w
fio_random_rw
end_of_script
