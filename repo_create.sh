#!/bin/bash
### INFO
## TO BE USED ONLY ON A REDHAT-BASED SYSTEM
## It will create a portable repository archive which you can transport to server that do not have a direct connection to the repositories

### VARS
##
remote_repo=$1
local_data=$2


createrepo_installed=`rpm -qa | grep createrepo |wc -l`
wget_installed=`rpm -qa | grep wget|wc -l`

### CHECKS
##

# print HELP text if no parameters given
if [[ $# -eq 0 ]]; then
        echo "USAGE: ./data-pull.sh \$REMOTE_REPO \$LOCALDATA"
        exit 1
fi

# check if local_data dir exists
if [[ ! -d $2 ]]; then
  echo "local directory $2 does not exist, creating!"
  mkdir -p $2
fi

### FUNCTIONS
##

check_repoutils() {
# Check that we have the right tools installed first.

	echo "checking package dependencies.."
	if [[ $createrepo_installed = '0' ]]; then
	  echo "createrepo not installed.. installing"
	  yum install createrepo -y >/dev/null 2>&1
	elif [[ $wget_installed = '0' ]]; then
	  echo "wget not installed.. installing"
	  yum install wget -y >/dev/null 2>&1
	else
      echo "[OK]"
    fi
}


pull_data() {
# sync the remote data

	echo "syncing data from $remote_repo"
	echo "..this may take a while"
      cd $local_data ; wget -N -r -nH --cut-dirs=2 --no-parent \
	  --reject="index.html*" $remote_repo >/dev/null 2>&1
	echo "data pull complete!"
	  if [[ -d $local_data/repodata ]]; then
        echo "removing old repodata"
        rm -rf $local_data/repodata
		echo "creating new repo structure in $local_data"
	  else
        echo "creating new repo structure in $local_data"
	  fi

	cd $local_data ; createrepo . >/dev/null 2>&1
	echo -e "Job's done!\n"

	filecount=`find $local_data -type f |wc -l`
	echo "Total Files: $filecount"
	echo "FROM: $remote_repo"
	echo "SYNC: $local_data"
}

check_repoutils
pull_data