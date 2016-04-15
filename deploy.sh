#!/bin/bash
sudo git stash clear
sudo git stash
sudo rm -rf web/elm/elm-stuff
sudo MIX_ENV=prod mix compile
sudo brunch build --production
sudo MIX_ENV=prod mix phoenix.digest
PID=$(ps -C beam |grep beam | awk '{print $1}')
sudo kill -9 $PID
sudo MIX_ENV=prod PORT=80 elixir --detached -S mix do compile, phoenix.server