#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Feeds SSH's known_hosts with a list of hosts. Usage:"
  echo "$0 hosts_file [username]"
  exit 1
fi

HOSTS=$1
shift

if [ $# -lt 1 ]; then
  SSH_USER=$USER
else
  SSH_USER=$1
fi

# Don't wait too long for inaccessible hosts.
SSH_OPTS="-o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=no"

TMP=`mktemp -t -d`
sed -e 's/#.*//' -e '/^[ \t]*$/d' $HOSTS > $TMP/hosts

for H in `cat $TMP/hosts`
do
  (ssh -q $SSH_OPTS -l $SSH_USER $H "true" && echo $H ) > $TMP/$H.result &
done

wait

cat $TMP/*.result | sort

if [ -e $TMP ]; then
	rm -rf $TMP
fi
