#!/bin/sh

panel_name=$(kscreen-doctor --outputs | grep 'Panel' -B 4 | grep 'Output:' | awk '{print $3}')
kscreen-doctor "output.${panel_name}.mode.3200x2000@60"
