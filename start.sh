#!/bin/sh

root=~/prod/todouat

export PORT=8009


forever start --workingDir ${root} -a -l todouat.log /usr/bin/npm start