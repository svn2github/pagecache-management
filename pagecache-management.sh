#!/bin/sh
SO_NAME=`echo "$0" | sed s/.sh$/.so/g` 
if test ! -e "$SONAME"
	SO_NAME=`echo "$SONAME" | sed s/bin/lib/`\
fi
#export LD_PRELOAD=$(which $SO_NAME)
#if test -z $LD_PRELOAD
#then
	if test -e $SO_NAME
	then
		export LD_PRELOAD=$SO_NAME
		export PAGECACHE_MAX_BYTES=$((4096 * 5120))
		exec $*
		#gprof $*
	else
		echo Could not open $SO_NAME
	fi
#fi

