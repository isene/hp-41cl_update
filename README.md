# hp-41cl_update
A tool to update ROMS on the HP-41CL calculator via HP-IL

NAME
    HP-41CL_update.rb - A tool to update ROMS on the HP-41CL calculator

SYNOPSIS
    HP-41CL_update.rb [ -h ] [long-options]

DESCRIPTION
    HP-41CL_update.rb takes HP-41 ROM files from a folder named "roms"
    and adds those to a LIF file that can be mounted by pyILPer. The
    pyILPer is a Java program that can mount LIF files so that an HP-41
    can access that file via a PILbox. The "roms" folder must reside
    in the same folder as the HP-41CL_update.rb program.

    pyILPer: https://github.com/bug400/pyilper
    PILbox:  http://www.jeffcalc.hp41.eu/hpil/#pilbox

OPTIONS
    -h, --help
    	Show this help text
    -v, --version
        Show the version of HP-41CL_update.rb

EXAMPLE
    No examples as of yet.
    
COPYRIGHT:
    Copyright 2017, Geir Isene (www.isene.com)
    This program is released under the GNU General Public lisence v2
    For the full lisence text see: http://www.gnu.org/copyleft/gpl.html

