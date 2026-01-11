#!/bin/sh

ghdl -a clock_counter.vhdl
ghdl -e testbench
ghdl -r testbench --wave=waveform.ghw

# gtkwave waveform.ghw
