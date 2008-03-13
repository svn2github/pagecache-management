#!/bin/bash
usage="Usage: $(basename $0): [-r] [-l value] command [args]"
rflag=
lflag=
export SO_NAME=`echo "$0" | sed s/.sh$/.so/g` 
echo $SO_NAME
while getopts 'rl:' OPTION
do
	case "$OPTION" in
	r)	rflag=1
		;;
	l)	lflag=1
		lval="$OPTARG"
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
	
if test "$lflag"
then
	export PAGECACHE_MAX_LAZY_CLOSE_FDS="$lval"
fi

#export LD_PRELOAD=$(which $SO_NAME)
#if test -z $LD_PRELOAD
#then
	if test -e $SO_NAME
	then
		export LD_PRELOAD=$SO_NAME
		if test -z "$PAGECACHE_MAX_BYTES"
		then 
			export PAGECACHE_MAX_BYTES=$((4096 * 512))
		fi
		exec "$@"
		#gprof $*
	else
		echo Could not open $SO_NAME
	fi
#fi

