#!/usr/bin/env ruby
# encoding: utf-8

require 'getoptlong'

prgmversion = 1.3

def help
puts <<HELPTEXT

NAME
    HP-41CL_update.rb - A tool to update ROMS on the HP-41CL calculator

SYNOPSIS
    HP-41CL_update.rb [-rxvh] [long-options]

DESCRIPTION
	HP-41CL_update.rb takes HP-41 ROM files from a folder named "roms" and
	adds those to a LIF file that can be mounted by pyILPer. The pyILPer
	is a Java program that can mount LIF files so that an HP-41 can access
	that file via a PILbox. The "roms" folder must reside in the same
	folder as the HP-41CL_update.rb program unless you specify another "roms"
	folder via the -r (or --romdir) option..

	The ROM names must be prefixed with the first three hexadecimal
	numbers of the HP-41CL flash adress where you want the rom to reside.
	Example: Rename ISENE.ROM to 0C9ISENE.ROM (as the rom should be placed
	in the address 0C9000 in the HP-41CL flash.

	HP-41CL_update.rb creates a file, "cl_update.lif" in the "roms" folder
	that you mount in pyILPer and connect to the HP-41CL via the PILbox.

	Use FUPDATE from the CLILUP rom to read the roms into your HP-41CL flash memory.

    pyILPer: https://github.com/bug400/pyilper
    PILbox:  http://www.jeffcalc.hp41.eu/hpil/#pilbox

OPTIONS
	-r, --romdir
		Specify the "roms" directory/folder for the rom files
		Default is the "roms" folder where the HP-41CL_update.rb resides
	-x, --hepax
		Add the ROM(s) into the LIF image as a HEPAX SDATA file
		Use HFUPDAT from the CLILUP rom to read the roms into your HP-41CL flash memory
    -h, --help
    	Show this help text
    -v, --version
        Show the version of HP-41CL_update.rb

COPYRIGHT:
    Copyright 2017, Geir Isene (www.isene.com)
    This program is released under the GNU General Public lisence v2
    For the full lisence text see: http://www.gnu.org/copyleft/gpl.html

HELPTEXT
end

opts = GetoptLong.new(
    [ "--hepax",    "-x", GetoptLong::NO_ARGUMENT ],
    [ "--romdir",   "-r", GetoptLong::NO_ARGUMENT ],
    [ "--help",     "-h", GetoptLong::NO_ARGUMENT ],
    [ "--version",  "-v", GetoptLong::NO_ARGUMENT ]
)

romdir   = File.join(File.expand_path(File.dirname(__FILE__)), "roms")
lifpgm	 = "rom41lif"

opts.each do |opt, arg|
  case opt
		when "--hepax"
			lifpgm = "rom41hx"
    when "--romdir"
			if not ARGV[0]
				puts "No roms dir specified."
				exit
			end
			romdir = ARGV[0]
    when "--help"
      help
      exit
    when "--version"
			puts "\nHP-41CL_update.rb version: " + prgmversion.to_s + "\n\n"
      exit
  end
end

if not Dir.exist?(romdir)
	puts "No such roms directory:", romdir
	exit
end

lifimage = File.join(romdir, "cl_update.lif")

romscheme = Hash.new
index = ""
z	  = ""

# Create LIF image and initialize - max ROMS is 496
`lifinit -m hdrive16 #{lifimage} 520`

Dir.foreach(romdir) do |dir_entry|
	if dir_entry =~ /\.rom$/i and File.size(File.join(romdir, dir_entry)) == 8192
		romfile     = File.join(romdir, dir_entry)											# Full path to rom
		romentry    = dir_entry.sub(/\..*$/, '').upcase										# e.g. "0C9ISENE"
		romname     = romentry.sub(/^.../, '')												# "ISENE"
		romname     = romname.gsub(/[^0-9A-Z]/, '')[0..7]									# Remove non-alphanumerinc characters, max 8 chars
		romname		= "R" + romname if romname =~ /^\d/										# Lifutils can't handle file names starting with a digit
		romlocation = romentry[0..2]														# "0C9"
		romblock    = ((romlocation.to_i(16) / 8).to_i * 8).to_s(16).rjust(3, "0").upcase	# "0C8"
		next if romblock.to_i(16) == 0 or romblock.to_i(16) >= 504							# Drop bogus files. And no updating system or single rom area
		romplace = romlocation.to_i(16) - romblock.to_i(16)									# 1 (0C9 - 0C8)
		romblockname = romblock.ljust(6, "0")												# "0C8000"

		# Create romblock sections and add a "*" to empty rom locations
		romscheme[romblockname] = Array.new(8, "*") if not romscheme.assoc(romblockname)
		romscheme[romblockname][romplace] = romname

		# Convert the ROM and add it to the LIF file with system commands (using "backticks")
		`#{lifpgm} #{romname} < #{romfile} | lifput #{lifimage}`
	end
end

romscheme = romscheme.sort
index	  = romscheme.flatten.join("\n")

# Create and add the romlist as an XM ascii file to the LIF image (called "INDEX")
File.write(File.join(romdir, "index.txt"), index)
`textlif -r 0 INDEX < #{File.join(romdir, "index.txt")} | lifput #{lifimage}`

# Create a tiny file, "Z" that contains the size of INDEX in # of XM regs
z = ((index.length + 2) / 7 + 1).to_i.to_s
File.write(File.join(romdir, "z.txt"), z)
`textlif -r 0 Z < #{File.join(romdir, "z.txt")} | lifput #{lifimage}`

# End message
puts "ROMs added to cl_update.lif. Check index.txt for all entries added.\n\n"

