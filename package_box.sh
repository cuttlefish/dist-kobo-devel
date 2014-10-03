#!/bin/sh

export BOX_NAME="kobo-box-$(date '+%m%d').box"
mkdir -p ~/share/boxes
vagrant package --output=~/share/boxes/$BOX_NAME