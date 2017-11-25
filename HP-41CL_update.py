#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2017 Geir Isene (http://isene.com/)
# Lisence: GPL2
# 
# This is my first Python program. I welcome any and all suggestions and improvements.
# I usually program in Ruby. First impression: Ruby is more elegant - even
# though it resembles HyperList (https://isene.me/hyperlist/) with its indenting. 

ver="0.3"

import optparse
import os

desc="""HP-41CL_update.rb takes HP-41 ROM files from a folder named "roms" and adds those to a LIF file that can be mounted by pyILPer. The pyILPer is a Java program that can mount LIF files so that an HP-41 can access that file via a PILbox. The "roms" folder must reside in the same folder as the HP-41CL_update.rb program. The ROM names must be prefixed with the first three hexadecimal numbers of the HP-41CL flash adress where you want the rom to reside. Example: Rename ISENE.ROM to 0C9ISENE.ROM (as the rom should be placed in the address 0C9000 in the HP-41CL flash. 

For pyILPer, see https://github.com/bug400/pyilper
For PILbox, see: http://www.jeffcalc.hp41.eu/hpil/#pilbox. 

Program is copyright 2017, Geir Isene (http://isene.com/) and released under the GPL2 license."""

# Define directory for roms
basedir   = os.path.dirname(os.path.realpath(__file__))
romdir    = basedir + "/roms"
hepax     = False

parser = optparse.OptionParser(version="%prog version: " + ver, description=desc)
parser.add_option('-x', '--hepax', action="store_true", help="Add the ROM(s) into the LIF image as a HEPAX SDATA file. Must be read into the HP-41CL using the HEPAX 'READROM' function.")
parser.add_option('-r', '--romdir', dest="romdir", default=romdir, help="Specify the roms directory/folder for the rom files. Default is the roms folder where the HP-41CL_update.rb resides")
(opts, args) = parser.parse_args()

romdir	  = opts.romdir
hepax     = opts.hepax

# Initialize variables
romscheme = {}
roms1     = ""
roms2     = ""

# Create a function to flatten dictionaries (What? No inbuilt method like in Ruby?)
def flatten(dic):
    dic = '\n'.join('{}{}'.format(key, val) for key, val in sorted(dic.items()))
    dic = dic.replace("'", "")
    dic = dic.replace(",", "")
    dic = dic.replace("]", "")
    dic = dic.replace("[", "\n")
    dic = dic.replace(" ", "\n")
    return dic

# Create and initiate LIF image
os.system("touch " + basedir + "/cl_update.lif")
os.system("lifinit -m hdrive16 " + basedir + "/cl_update.lif 520")

if not os.path.exists(romdir):
    print "No such roms directory:\n", romdir
    exit()

# Run through all ROMs in the "roms" directory and add them to the LIF image
for filename in os.listdir(romdir):
    if filename.upper().endswith(".ROM") and os.path.getsize(romdir + "/" + filename) == 8192:
	romentry = filename.upper()								# e.g. "0C9ISENE.ROM"
	romname = romentry[3:].split(".")[0]							# "ISENE"
	romlocation = romentry[:3]								# "0C9"
	romblock = hex(int(romlocation, 16) / 8 * 8).split("x")[-1].zfill(3).upper()		# "0C8"
	if romblock == "000" or romblock == "1F8":						# Drop updating system or single rom area
	    continue
	romplace = int(romlocation, 16) - int(romblock, 16)					# 1 (0C9 - 0C8)
	romblockname = romblock.ljust(6, '0')							# "0C8000"

	# Create romblock sections and add a "*" to empty rom locations
	if romblockname not in romscheme:
	    romscheme[romblockname] = ["*"] * 8
	romscheme[romblockname][romplace] = romname

	# Convert the ROM and add it to the LIF file with system commands
        if hepax:
            os.system("cat " + romdir + "/" + filename + " | rom41hx " + romname + " > " + romdir + "/" + romname + ".sda")
            os.system("lifput " + basedir + "/cl_update.lif " + romdir + "/" + romname + ".sda")
        else:
	    os.system("cat " + romdir + "/" + filename + " | rom41lif " + romname + " | lifput " + basedir + "/cl_update.lif")
        continue
    else:
        continue

# Split the romlist if it is larger than 256 entries (64 blocks) (includes "empty entries")
# Create and add the romlist as an XM ascii file to the LIF image
if len(romscheme) > 64:
    roms1 = flatten(dict(romscheme.items()[64:]))
    roms2 = flatten(dict(romscheme.items()[:64]))
    file = open(romdir + "/roms2.txt","w") 
    file.write(roms2)
    os.system("cat " + romdir + "/roms2.txt | textlif ROMS2 | lifput " + basedir + "/cl_update.lif")
else:
    roms1 = flatten(romscheme)

file = open(romdir + "/roms1.txt","w")
file.write(roms1)
os.system("cat " + romdir + "/roms1.txt | textlif ROMS1 | lifput " + basedir + "/cl_update.lif")

# Clean up
if hepax:
    os.system("rm " + romdir + "/*.sda")

