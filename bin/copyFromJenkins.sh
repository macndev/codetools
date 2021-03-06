#!/bin/bash
#
#
# Ray Culbertson
#

usage()
{
    echo "
 Pull an Offline release build from Jenkins build machine
 \$1 = git release tag, like v5_2_1
 \$2,\$3 = select subsets.

  Should be run in the directory where the verison listing
  will appear (for example: cd /cvmfs/mu2e.opensciencegrid.org/Offline).

"
}

#  If \"SLF6\" then do SLF6, prof and debug.  
#   If \"debug\" then do SLF6 and 7, for debug. If \"SLF6 debug\" then
#   only do SLF6 debug.

export TAG=$1

if [ "$TAG" == "" ]; then
  usage
  exit 1
fi

OSLIST="SLF7"
BBLIST=""
shift
for AA in $*
do
#  [ $AA == "SLF7" ] && OSLIST="$OSLIST $AA"
#  [ $AA == "SLF6" ] && OSLIST="$OSLIST $AA"
  [ $AA == "prof"  ] && BBLIST="$BBLIST $AA"
  [ $AA == "debug" ] && BBLIST="$BBLIST $AA"
done
[ -z "$OSLIST" ] && OSLIST="SLF7"
[ -z "$BBLIST" ] && BBLIST="prof debug"
echo OSLIST=$OSLIST
echo BBLIST=$BBLIST

export BDIR=$PWD

for OS in $OSLIST
do
  for TYPE in $BBLIST
  do
    cd $BDIR
    echo "Creating and filling $PWD/${TAG}/${OS}/${TYPE}"
    mkdir -p ${TAG}/${OS}/${TYPE}
    cd ${TAG}/${OS}/${TYPE}
    export TBALL=Offline_${TAG}_${OS}_${TYPE}.tgz
    export URL="https://buildmaster.fnal.gov/buildmaster/view/mu2e/job/mu2e-offline-build/BUILDTYPE=${TYPE},label=${OS}/lastSuccessfulBuild/artifact/copyBack/$TBALL"
    wget --no-check-certificate $URL
    RC=$?
    if [ $RC -ne 0 ];then
      echo "ERROR - wget failed on $TBALL"
      echo "skipping this build"
      break
    fi
    tar -xzf $TBALL
    rm -f $TBALL
    SIZE=`du -ms Offline | awk '{print $1}'`
    FILES=`find Offline -type f | wc -l`
    echo "Unrolled $SIZE MB for $FILES files"
    echo ""

  done
done

exit

