# hp-41cl_update
A tool to update ROMS on the HP-41CL calculator via HP-IL (Linux only)

## DESCRIPTION
There are two alternative programs on the PC side, both doing exactly the same: "HP-41CL_update.rb" is the Ruby version, while "HP-41CL_update.py" is the Python equivalent. There is one FOCAL program on the HP-41CL side, "FUPDATE".

HP-41CL_update.rb (or HP-41CL_update.py) takes HP-41 ROM files from a folder named "roms" and adds those to a LIF file that can be mounted by pyILPer. The pyILPer is a Java program that can mount LIF files so that an HP-41 can access that file via a PILbox. The "roms" folder must reside in the same folder as the HP-41CL_update.rb (or HP-41CL_update.py) program. The file names of the ROMs to be updated must be prefixed with the HP-41CL address so that the FOCAL program knows where in flash to update the ROMs (only the first three hex numbers are inserted at the beginning of the file name).

Example: You want to update the ISENE.ROM on your HP-41CL. The ISENE.ROM should go to the location "0C9", therefore you rename the rom to 0C9ISENE.ROM and drop it into the folder called "roms". You run HP-41CL_update.rb (or HP-41CL_update.py) and you get a LIF imge called cl_update.lif in the same directory as the HP-41CL_update.rb (or HP-41CL_update.py) program. Mount this LIF file in pyILPer and run the FUPDATE program on the HP-41CL.

pyILPer: https://github.com/bug400/pyilper

PILbox:  http://www.jeffcalc.hp41.eu/hpil/#pilbox

Running the HP-41CL_update.rb will...

![Alt text](docs/2017-11-17-224051_693x136_scrot.png?raw=true "Top Dir")

...take all the ROMs in the "roms" directory, and adds them to the LIF image, "cl_update.lif", including the index file, "roms1.txt" which contains the needed info used by the HP-41 FOCAL program, "FUPDATE.41" to actually update the CL flash. The "roms1.txt" looks like this:

![Alt text](docs/2017-11-17-224116_690x460_scrot.png?raw=true "roms Dir")

If you want to update more than 256 ROMs at a time, the index will split into two files, "roms1.txt" and "roms2.txt" in order for each index file to fit into the HP-41CL's XM memory. The FOCAL program, FUPDATE will run through "roms1.txt" before checking if there is a "roms2.txt" and run that if it exists.


## SYNOPSIS
HP-41CL_update.rb [-hv] [--help, --version]

HP-41CL_update.py [-h] [--help, --version]

## OPTIONS
-h, --help	Show this help text

-v, --version  Show the version of HP-41CL_update.rb

--version  Show the version of HP-41CL_update.py

## COPYRIGHT:
Copyright 2017, Geir Isene (www.isene.com).  This program is released under the GNU General Public lisence v2.  For the full lisence text see: http://www.gnu.org/copyleft/gpl.html.

