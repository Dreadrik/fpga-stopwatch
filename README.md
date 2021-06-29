# fpga-stopwatch

A breadboard stopwatch implemented using an iCE40HX8K FPGA.

![alt text](https://github.com/Dreadrik/fpga-stopwatch/blob/main/doc/stopwatch.jpg "Image of the finished project")

## Why?

This project was made by me to learn some FPGA programming and Verilog, using cheap open source hardware and software toolchains.

## What I used

* Olimex [iCE40HX8K-EVB](https://www.olimex.com/Products/FPGA/iCE40/iCE40HX8K-EVB/open-source-hardware) - development board
* Olimex [OLIMEXINO-32U4](https://www.olimex.com/Products/Duino/AVR/OLIMEXINO-32U4/open-source-hardware) - as the board programmer
* Olimex [CABLE-IDC10](https://www.olimex.com/Products/Components/Cables/CABLE-IDC10-15cm) - for connecting programmer to development board
* Olimex [5-volt power supply](https://www.olimex.com/Products/Power/SY0605E-CHINA/)
* 5x XLITX 5611AH - 7-segment LED displays with common cathode
* 1x TI TLC59213A - 8-Bit Parallel In and Out Darlington Source Driver With Latch
* 1x TI TLC59211N - 8-Bit DMOS Sink Driver
* 8x 220 Ohm resistors
* 1x SPST push button
* Breadboard
* Breadboard jumper cable
* 2.54mm Pitch Male to Female Breadboard Jumper Wire

## How it works

![alt text](https://github.com/Dreadrik/fpga-stopwatch/blob/main/doc/schematic.png "Schematic")

### FPGA
The FPGA multiplexes the 5 displays by selecting one digit a time and drives the corresponding display cathode low. At the same time it outputs new 
segment data for the current digit. This means that each display is only lit a 5'th of the time, but the high update speed makes this invisible to the eye.
The button input is debounced and selects between three modes: start/stop and reset.

### Breadboard
+5V VCC, GND and 3.3V data lines comes from the GPIO1 connector on the FPGA dev board.
8 io lines (SEGA-SEGDP) from the FPGA control the same segment for all displays. Segments are driven by a 8-Bit Darlington source through 220 Ohm resistors. The clock input of the Darlington source is driven from a separate io line (SEGCLK). 5 io lines (SEGCAT[0-4]) control the cathode for each display through the sink driver. The drivers are needed because of the low current available from the iCE40HX lines (max 6 mA). A momentary push button drives the BTN io line to ground when pressed.

## How to build

Just hook everything up on the breadboard according to the schematic!

## How to program

I used the [APIO Open source ecosystem for open FPGA boards](https://github.com/FPGAwars/apio) to build this project. APIO makes building, simulating and uploading designs very simple, and is available on Windows, Linux and Mac!
Install APIO according to the instructions in the link. You will need at least the yosys, ice40, nextpnr and scons packages, but iverilog, gtkwave and verilator are also very useful for testing, verification and simulation.

The Olimexino was used as a programmer, and it has to have the programming firmware installed [available from here](https://github.com/OLIMEX/iCE40HX1K-EVB/tree/master/programmer/olimexino-32u4%20firmware).

For programming the FPGA you will have to build and install the [iceprogduino](https://github.com/OLIMEX/iCE40HX1K-EVB/tree/master/programmer/iceprogduino) tool from Olimex. Make sure to change to the serial port used by the Olimexino in iceprogduino.c.

When everything is installed correctly, it should simply be a matter of running one of these:

Simulate:
```
$ cd src
$ apio sim
```

Build:
```
$ cd src
$ apio build
```

Program:
```
$ cd src
$ apio upload
```
