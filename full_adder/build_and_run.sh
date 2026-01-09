#!/bin/sh

ghdl -a full_adder.vhdl
ghdl -e testbench
ghdl -r testbench --wave=waveform.ghw

# gtkwave waveform.ghw
