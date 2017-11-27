#!/usr/bin/env ruby
# encoding: utf-8

require 'getoptlong'

prgmversion = 0.4

def help
puts <<HELPTEXT

NAME
    HP-41CL_update.rb - A tool to update ROMS on the HP-41CL calculator

SYNOPSIS
    HP-41CL_update.rb [-hv] [long-options]

DESCRIPTION
    HP-41CL_update.rb takes HP-41 ROM files from a folder named "roms"
    and adds those to a LIF file that can be mounted by pyILPer. The
    pyILPer is a Java program that can mount LIF files so that an HP-41
    can access that file via a PILbox. The "roms" folder must reside
    in the same folder as the HP-41CL_update.rb program.

	The ROM names must be prefixed with the first three hexadecimal
	numbers of the HP-41CL flash adress where you want the rom to reside.
	Example: Rename ISENE.ROM to 0C9ISENE.ROM (as the rom should be 
	placed in the address 0C9000 in the HP-41CL flash.

    pyILPer: https://github.com/bug400/pyilper
    PILbox:  http://www.jeffcalc.hp41.eu/hpil/#pilbox

OPTIONS
	-r, --romdir
		Specify the "roms" directory/folder for the rom files
		Default is the "roms" folder where the HP-41CL_update.rb resides
	-x, --hepax
		Add the ROM(s) into the LIF image as a HEPAX SDATA file
		Must be read into the HP-41CL using the HEPAX "READROM" function
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

basedir = File.expand_path(File.dirname(__FILE__))
romdir  = basedir + "/roms"
hepax	= false

opts.each do |opt, arg|
  case opt
	when "--hepax"
	  hepax = true
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

romscheme = Hash.new
roms1 = ""
roms2 = ""

# Create LIF image and initialize
`touch #{basedir}/cl_update.lif`
`lifinit -m hdrive16 #{basedir}/cl_update.lif 520`										# Max ROMS is 512

if not Dir.exists?(romdir)
	puts "No such roms directory:", romdir
	exit
end

Dir.foreach(romdir) do |dir_entry|
	if dir_entry =~ /\.rom$/i and File.size(romdir + "/" + dir_entry) == 8192
		romentry = dir_entry.sub(/\..*$/, '').upcase									# e.g. "0C9ISENE"
		romname = romentry.sub(/^.../, '')												# "ISENE"
		romname = romname.gsub(/[^0-9A-Z]/, '')[0..7]									# Remove non-alphanumerinc characters, max 8 chars
		romlocation = romentry[0..2]													# "0C9"
		romblock = ((romlocation.to_i(16) / 8).to_i * 8).to_s(16).rjust(3, "0").upcase	# "0C8"
		next if romblock == "000" or romblock == "1F8"									# Drop updating system or single rom area
		romplace = romlocation.to_i(16) - romblock.to_i(16)								# 1 (0C9 - 0C8)
		romblockname = romblock.ljust(6, "0")											# "0C8000"

		# Create romblock sections and add a "*" to empty rom locations
		romscheme[romblockname] = Array.new(8, "*") if not romscheme.assoc(romblockname)
		romscheme[romblockname][romplace] = romname

		# Convert the ROM and add it to the LIF file with system commands (using "backticks")
		if hepax
			`cat #{romdir}/#{dir_entry} | rom41hx #{romname} > #{romdir}/#{romname}.sda`
			`lifput #{basedir}/cl_update.lif #{romdir}/#{romname}.sda`
		else
			`cat #{romdir}/#{dir_entry} | rom41lif #{romname} | lifput #{basedir}/cl_update.lif`
		end
	end
end

romscheme = romscheme.sort

# Split the romlist if it is larger than 256 entries (includes "empty entries")
if romscheme.size > 256
	largelist = romscheme.insert(256,"---").flatten.join("\n").split("---\n")
	roms1 = largelist[0]
	roms2 = largelist[1]
else
	roms1 = romscheme.flatten.join("\n")
end

# Create and add the romlist as an XM ascii file to the LIF image
File.write("#{romdir}/roms1.txt", roms1)
`cat #{romdir}/roms1.txt | textlif ROMS1 | lifput #{basedir}/cl_update.lif`
# If the romlist is large and split into two, write and save also the second part
if roms2 != ""
	File.write("#{romdir}/roms2.txt", roms2) 
	`cat #{romdir}/roms2.txt | textlif ROMS2 | lifput #{basedir}/cl_update.lif`
end

# Clean up
`rm #{romdir}/*.sda` if hepax

# End message
puts "ROMs added to cl_update.lif. Check roms1.txt (and roms2.txt if more than 256 roms added) for all entries added."

