#!/bin/bash

file=("${@:2}")
# I'm not sure why, but the * is the magic sauce to make this work.
keyfinder-cli -n camelot "${file[*]}"