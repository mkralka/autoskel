#!/bin/sh
##
##	Prepare the package for configuring/building using autotools
##

self=`basename $0`

if [ $# -eq 1 -a "x$1" = "x--help" ]; then
	echo "usage: $self"
	echo "       $self subdir1 subdir2 subdir3 ..."
	echo "       $self --help"
	echo ""
	echo "By default autotools is initialized for the entire project. However, individual"
	echo "sudbirectories can be specified."
	exit 0;
fi

rootdir=`dirname $0`
rootdir=`cd $rootdir; echo $PWD`
configure_ac="$rootdir/configure.ac"

if [ "x$LIBTOOL" != "x" ]; then
	libtool="$LIBTOOL"
else
	# Look for GNU libtool. On Mac OS X, this is often installed as
	# glibtool.
	for exe in libtool glibtool; do
		if $exe --version 2>&1 | grep -q 'GNU libtool'; then
			libtool="$exe"
			break
		fi
	done
	if [ "x$libtool" = "x" ]; then
		echo "libtool not found" >&2
		exit 1
	fi
fi
if [ "x$LIBTOOLIZE" != "x" ]; then
	libtoolize="$LIBTOOLIZE"
else
	# Look for libtoolize. On Mac OS X, this is often installed as
	# glibtoolize.
	for exe in libtoolize glibtoolize; do
		if $exe --version 2>&1 | grep -q 'GNU libtool'; then
			libtoolize="$exe"
			break
		fi
	done
	if [ "x$libtoolize" = "x" ]; then
		echo "libtoolize not found" >&2
		exit 1
	fi
fi

if [ $# -eq 0 ]; then
	# No directories were specified, the defaults depend on the configuration.
	if egrep -q '^[[:space:]]*AC_CONFIG_SUBDIRS[[:space:]]*\(' "$configure_ac"; then
		# There are sub-projects, if we are in a subproject directory,
		# only configure that directory, otherwise configure them all.
		if [ "$PWD" != "$rootdir" ]; then
			subdirs="$PWD"
		else
			subdirs=". `egrep '^[[:space:]]*AC_CONFIG_SUBDIRS[[:space:]]*\(' "$configure_ac" | sed 's/^[[:space:]]*AC_CONFIG_SUBDIRS[[:space:]]*(\[\{0,1\}\([^]]*\)\]\{0,1\})[[:space:]]*$/\1/'`"
		fi
	else
		# There are no subprojects, just run it in the root directory.
		subdirs="$rootdir"
	fi
else
	subdirs="$*";
fi

for dir in $subdirs; do
	dir=`echo "$dir" | sed -e 's|//*|/|' -e 's|/$||'`
	(
		cd "$dir" || exit
		if [ "$PWD" = "$rootdir" ]; then
			location="project root";
		else
			location="subdirectory ($dir)";
		fi

		if egrep -q '^[[:space:]]*AC_PROG_LIBTOOL\>' "$configure_ac"; then
			echo "Running libtoolize in $location ..."
			$libtoolize --force --copy > /dev/null || exit;
		fi

		echo "Running aclocal in $location ..."
		aclocal -I .autoconf --force > /dev/null || exit;

		config_h=`egrep '^[[:space:]]*AC_CONFIG_HEADERS[[:space:]]*\(' "$configure_ac" | sed 's/^[[:space:]]*AC_CONFIG_HEADERS[[:space:]]*(\[\{0,1\}\([^]]*\)\]\{0,1\})[[:space:]]*$/\1/'`
		if [ -n "$config_h" ]; then
			echo "Running acheader in $location ..."
			rm -f "$config_h" || exit;
			autoheader --force > /dev/null || exit;
		fi

		echo "Running autoconf in $location ..."
		autoconf --force > /dev/null || exit;

		echo "Running automake in project root ..."
		automake --add-missing --copy > /dev/null || exit;
	)
	rc=$?

	if [ $rc -ne 0 ]; then
		echo "Initialization of autotools failed!" >&2
		exit $rc
	fi
done
