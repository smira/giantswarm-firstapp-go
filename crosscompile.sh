#!/bin/bash

set -u
set -e

RELEASE_DIR=$1
if [ ! -n "$RELEASE_DIR" ]; then
  echo "ERROR: need release directory as first parameter to proceed"
  exit 1
fi

BASE_DIR=$(pwd)
VERSION=$(cat VERSION)
BIN_NAME="currentweather"

function build_version () {
  local GOOS=$1
  local GOARCH=$2
  local BIN=$BIN_NAME-$GOOS-$GOARCH

  make BIN=${BIN} GOOS=${GOOS} GOARCH=${GOARCH} ${BIN}
}

function package_version() {
  local GOOS=$1
  local GOARCH=$2
  local TAR=$BIN_NAME-$VERSION-$GOOS-$GOARCH

  cd $GOOS-$GOARCH
  tar --verbose --create --gzip --file ../$TAR.tar.gz *
  cd ..
}

function move_bin_to_version_dir () {
  local GOOS=$1
  local GOARCH=$2
  local BIN=$BIN_NAME-$GOOS-$GOARCH

  mv $BIN $RELEASE_DIR/$GOOS-$GOARCH/$BIN_NAME
}

function clean_release_dir {
  rm -rf $RELEASE_DIR/*
}

function goto_release_dir {
  cd $RELEASE_DIR
}

function goto_base_dir {
  cd $BASE_DIR
}

function create_version_dir () {
  local GOOS=$1
  local GOARCH=$2

  mkdir $RELEASE_DIR/$GOOS-$GOARCH
}

# -----------------------------------------------------------------------------------

clean_release_dir

for GOOS in darwin linux; do
  for GOARCH in 386 amd64; do
    goto_base_dir

    echo "Building version for os ${GOOS} and architecture ${GOARCH}"
    build_version $GOOS $GOARCH
    create_version_dir $GOOS $GOARCH
    move_bin_to_version_dir $GOOS $GOARCH

    goto_release_dir
    package_version $GOOS $GOARCH
    echo
  done
done