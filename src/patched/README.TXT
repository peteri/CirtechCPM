Apple //e Cirtech CP/M Plus build.
==================================

To build a bootable disk on the apple //e first run build.ps1 to create the
binary files, then run buildhdv.ps1 to build the HDV image.

To run the image use mame, AppleWin will not currently work 
see https://github.com/AppleWin/AppleWin/issues/1264 
OR copy the image to a real Apple //e.
A suitable mame command line will be something like:
mame apple2ee -sl1 parallel -sl2 ssc -sl4 softcard -aux ext80 
-sl7 cffa2 -hard1 {PathTo}\DiskImages\buildcpm3.hdv 

To build on the Apple //e boot the image, change user to USER 1
then use BUILDBIN.SUB, BUILDCOM.SUB, LINKBIN.SUB to compile and
linkg the assembly files. The type GENCPM AUTO DISPLAY to 
generate CPM3.SYS. User area 1 has been used so that CPM3.SYS 
is not overwritten. For some reason using BUILD.SUB to call
the indivdiual submit files does not work.

To format a blank floppy hold down closed Apple and press ? which
will open the Cirtech Toolkey (or closed Apple and F)
Use PUTSYS.COM to create a bootable floppy.