#!/bin/sh
make CONFIG=Rocket64x1 vivado-tcl
cd  vivado_workspace
rm -r Rocket64x1
cp -r ../workspace/Rocket64x1 .
git add  .
git commit -m "vivado-workspace"
git push
cd ..
git add vivado_workspace
git commit -m "bump"
git push