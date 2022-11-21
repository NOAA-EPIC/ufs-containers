#!/bin/bash

set -ex

usage() {
  set +x
  echo
  echo "Usage: $0 -f <branch> | -u <gitrepo> | -e <expdir> "
  echo
  echo "  -f  feature branch name to clone"
  echo "  -u  git repository url"
  echo "  -e  rt setup directory"
  echo
  set -x
  exit 1
}

[[ $# -eq 0 ]] && usage

while getopts f:u:e: flag
do
        case "${flag}" in
                f) BR=${OPTARG}
                        ;;
                u) FORK=${OPTARG}
                        ;;
                e) REPO=${OPTARG}
                        ;;
                *) echo "Invalid options: -$flag";
		        ;;
        esac
done

echo "feature branch to clone: $BR";
echo "forked branch URL: $FORK";
echo "rt setup directory name: $REPO";
echo "current path" $(pwd);

CUR_PWD=$(pwd);

git clone -b $BR $FORK $REPO
cd $REPO
git submodule update --init --recursive
cd $CUR_PWD
cp $CUR_PWD/$REPO/tests/rt.sh $CUR_PWD/$REPO/tests/rt.sh.org

sed -i '350 a \  ACCNR=SCSG0002\' $CUR_PWD/$REPO/tests/rt.sh;
sed -i 's|dprefix=/glade/scratch|dprefix=/glade/scratch/${USER}/USEREXPNAME|g' $CUR_PWD/$REPO/tests/rt.sh;
sed -i "s|USEREXPNAME|${REPO}|g" $CUR_PWD/$REPO/tests/rt.sh;

cd $CUR_PWD/$REPO/tests
export RT_COMPILER=gnu
nohup ./rt.sh -e -l rt_gnu.conf &

cd $CUR_PWD
