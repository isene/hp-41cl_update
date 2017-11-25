# hp-41cl_update
A tool to update ROMS on the HP-41CL calculator via HP-IL (Linux only)

## DESCRIPTION
There are two alternative programs on the PC side, both doing exactly the same: "HP-41CL_update.rb" is the Ruby version, while "HP-41CL_update.py" is the Python equivalent. There is one FOCAL program on the HP-41CL side, "FUPDATE".

HP-41CL_update.rb (or HP-41CL_update.py) takes HP-41 ROM files from a folder named "roms" and adds those to a LIF file that can be mounted by pyILPer. The pyILPer is a Java program that can mount LIF files so that an HP-41 can access that file via a PILbox. The "roms" folder must reside in the same folder as the HP-41CL_update.rb (or HP-41CL_update.py) program. The file names of the ROMs to be updated must be prefixed with the HP-41CL address so that the FOCAL program knows where in flash to update the ROMs (only the first three hex numbers are inserted at the beginning of the file name).

Example: You want to update the ISENE.ROM on your HP-41CL. The ISENE.ROM should go to the location "0C9", therefore you rename the rom to 0C9ISENE.ROM and drop it into the folder called "roms". You run HP-41CL_update.rb (or HP-41CL_update.py) and you get a LIF imge called cl_update.lif in the same directory as the HP-41CL_update.rb (or HP-41CL_update.py) program. Mount this LIF file in pyILPer and run the FUPDATE program on the HP-41CL. See example rom directory, ROMS1.txt and cl_update.lif.

Included is also a ROM (CLILUP.ROM) that includes two routines from Håkan Thörngren; RDROM16 (to read 16 bits roms from Mass Storage, i.e. LIF files) and WRROM16 (to write 16 bit roms to Mass Storage). These functions are needed to read and write "modern" HP-41CL roms such as the IMDB. Old roms only used 10 bits and HEPAX compressed these roms by stripping the other 6 bits. You can therefore read and write old 10-bit roms to and from Mass Storage LIF files using HEPAX's READROM and WRTROM). The CLILUP rom is such a 10 bit rom and you must use the HEPAX READROM to load this module onto your HP-41CL so that it can be used to load both 10 bit and 16 bit roms. In order to load the CLILUP.ROM, run HP-41CL_update.rb with the option -x (HP-41CL_update.rb -x) to push the rom into the cl_update.lif file as a HEPAX SDATA file (a 10 bit rom where the other 6 bits are stripped). On the HP-41CL you must then plug a HEPAX RAM page onto one of the HP-41 pages and read the rom into that HP-41 page using the HEPAX READROM function. See the HP-41CL manual for how to plug HEPAX RAM pages into an HP-41 page.

pyILPer: https://github.com/bug400/pyilper

PILbox:  http://www.jeffcalc.hp41.eu/hpil/#pilbox

Running the HP-41CL_update.rb will...

![Alt text](docs/2017-11-17-224051_693x136_scrot.png?raw=true "Top Dir")

...take all the ROMs in the "roms" directory, and adds them to the LIF image, "cl_update.lif", including the index file, "roms1.txt" which contains the needed info used by the HP-41 FOCAL program, "FUPDATE.41" to actually update the CL flash. The "roms1.txt" looks like this:

![Alt text](docs/2017-11-17-224116_690x460_scrot.png?raw=true "roms Dir")

If you want to update more than 256 ROMs at a time, the index will split into two files, "roms1.txt" and "roms2.txt" in order for each index file to fit into the HP-41CL's XM memory. The FOCAL program, FUPDATE will run through "roms1.txt" before checking if there is a "roms2.txt" and run that if it exists.


## SYNOPSIS
HP-41CL_update.rb [-hvrx] [--help, --version, --romdir, --hepax]

HP-41CL_update.py [-hrx] [--help, --version, --romdir, --hepax]

## OPTIONS
-h, --help	Show help text.

-v, --version  Show the version of HP-41CL_update.rb

--version  Show the version of HP-41CL_update.py

-r, --romdir  Specify the "roms" directory/folder for the rom files. Default is the "roms" folder where the HP-41CL_update.rb resides.

-x, --hepax  Add the ROM(s) into the LIF image as a HEPAX SDATA file. Must be read into the HP-41CL using the HEPAX "READROM" function.

## COPYRIGHT:
Copyright 2017, Geir Isene (www.isene.com).  This program is released under the GNU General Public lisence v2.  For the full lisence text see: http://www.gnu.org/copyleft/gpl.html.

