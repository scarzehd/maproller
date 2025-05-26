#!/bin/env bash

GODOT="$HOME/dev/Godot_v4.4.1-stable_linux.x86_64"
BUTLER="$HOME/dev/maproller/build/butler"
PROJECT_PATH="$HOME/dev/maproller"
BUILD_PATH="$PROJECT_PATH/build"

if [ ! -f $GODOT ]; then
	echo "Godot executable not found. Nothing has been changed."
	exit
fi

if [ ! -f $BUTLER ]; then
	echo "Butler executable not found. Nothing has been changed."
	exit
fi

read -p "Your build directory is set to ${BUILD_PATH}. Is that correct? [y/N]" -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Modify this script to set your build path and try again."
	exit
fi

read -p "This will delete all current builds. Are you sure you want to continue? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Make backups and try again."
	exit
fi

rm $BUILD_PATH/windows/*
rm $BUILD_PATH/linux/*

VERSION=$( cat $PROJECT_PATH/project.godot | grep config/version | sed 's/config\/version="//' | sed 's/"//' )

$GODOT --headless --path $PROJECT_PATH --export-release "Windows" $BUILD_PATH/windows/maproller-${VERSION}.exe
$GODOT --headless --path $PROJECT_PATH --export-release "Linux" $BUILD_PATH/linux/maproller-${VERSION}.x86_64

$BUTLER push $BUILD_PATH/windows/ scarzehd/maproller:windows --userversion $VERSION
$BUTLER push $BUILD_PATH/linux/ scarzehd/maproller:linux --userversion $VERSION
