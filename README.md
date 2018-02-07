# lindy16SocketIPPowerBarControl
# Author: Chris Get
# A simple perl script to control the Lindy 16 socket power bar

Required software for use:

	wget		Linux command line web navigation tool. Install with your packagage manager.
				"apt-get install wget" for Debian/Ubuntu.

	ping		Linux command line tool for network device discovery. Install with your packagage manager.
				"apt-get install iputils-ping" for Debian/Ubuntu.

	Getopt::Long	Perl module to parse the input arguments. Install with the CPAN shell.

Input Arguments:

	--ip		Defines the IP address or hostname of the Lindy device to be controlled (Required).

	--option	Defines the action you want to perform. Valid option is currently only "switch".
				"switch" -> Switch socket(s) on the device on or off (use with --state [on|off]).
	
	--socket	Defines the socket(s) you want to target for the action. You can use letters or numbers to identify the sockets.
				separate with a comma for multiple sockets e.g. "A,3,D".

	--state		Defines the state you want to change the socket(s) to ("on" or "off"). Use with "--option switch"

	--username	Defines the username for accessing the web interface of the device.

	--password	Defines the password for accessing the web interface of the device.

	--help		Display this help text.
