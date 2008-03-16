#!/bin/bash
usage="Usage: $(basename $0): [-r] [-d] [-l value] [-m value] [-s value] -- command [args]"
rflag=
lflag=
size=30

if test -e  /proc/sys/vm/dirty_writeback_centisecs
then
	centisecs=$(cat /proc/sys/vm/dirty_writeback_centisecs)
	export PAGECACHE_WRITEBACK_SECS=$(($centisecs/100+2))
	#echo $PAGECACHE_WRITEBACK_SECS
else
	echo Could not find /proc/sys/vm/dirty_writeback_centisecs, are we really using a Linux kernel?
fi

export SO_NAME=`echo "$0" | sed s/.sh$/.so/g | sed 's/^[[:alnum:]]/.\/&/g'` 
echo $SO_NAME
while getopts 'rl:m:s:d' OPTION
do
	case "$OPTION" in
	r)	rflag=1 # ignore reads
		;;
	l)	lflag=1 # max # of files to lazy close 
		lval="$OPTARG"
		export PAGECACHE_MAX_LAZY_CLOSE_FDS="$lval"
		;;
	s) 	export PAGECACHE_WRITEBACK_SECS="$OPTARG"
		;;
	m)	size="$OPTARG"
		if test "$size" = "-"
		then 
			echo "s option needs non-negative numeric argument" >&2
			echo "$usage" >&2
		fi
		;;
	d)	DEBUG=1
		;;
	?)	echo "$usage" >&2
		exit 2
		;;
	esac
done
shift $(($OPTIND - 1))

if test -z "$1"
then
	echo "$usage" >&2
	exit 2
fi

if test ! -e "$SO_NAME"
then
	SO_NAME=`echo "$SO_NAME" | sed s/bin/lib/`
fi

if test "$rflag"
then 
	SO_NAME=`echo "$SO_NAME" | sed s/.so$/-ignore-reads.so/`
fi
	
#if test "$lflag"
#then
#	export PAGECACHE_MAX_LAZY_CLOSE_FDS="$lval"
#fi


	
#export LD_PRELOAD=$(which $SO_NAME)
#if test -z $LD_PRELOAD
#then
	if test -e $SO_NAME
	then
		export LD_PRELOAD=$SO_NAME
		if test -z "$PAGECACHE_MAX_BYTES"
		then 
			export PAGECACHE_MAX_BYTES=$((4096 * 256 * $size))
		fi
		if test "$DEBUG"
		then
			gdb "$@"
		else 
			exec "$@"
		fi
		#gprof $*
	else
		echo Could not open $SO_NAME
	fi
#fi

