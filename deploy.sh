#!/bin/env bash

GODOT="$HOME/dev/Godot_v4.4.1-stable_linux.x86_64"
BUTLER="$HOME/dev/build/butler"

if [ ! -f $GODOT ]; then
	echo "Godot executable not found. Nothing has been changed."
	exit
fi

if [ ! -f $BUTLER ]; then
	echo "Butler executable not found. Nothing has been changed."
	exit
fi

read -p "This will delete all current builds. Are you sure you want to continue? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Make backups and try again."
	exit
fi

rm windows/*
rm linux/*

VERSION=$( cat ../project.godot | grep config/version | sed 's/config\/version="//' | sed 's/"//' )

PROJECT_PATH=$( pwd )/../

$GODOT --headless --path $PROJECT_PATH --export-release "Windows" build/windows/maproller-${VERSION}.exe
$GODOT --headless --path $PROJECT_PATH --export-release "Linux" build/linux/maproller-${VERSION}.x86_64

$BUTLER push windows/ scarzehd/maproller:windows --userversion $VERSION
$BUTLER push linux/ scarzehd/maproller:linux --userversion $VERSION
