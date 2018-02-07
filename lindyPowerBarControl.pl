#!/usr/bin/perl -w

use strict;
use Getopt::Long;

my ($ip,$option,$socket,$state,$user,$pass,$help);

GetOptions(	'ip=s' => \$ip,
		'option=s' => \$option,
		'socket=s' => \$socket,
		'state=s' => \$state,
		'username=s' => \$user,
		'password=s' => \$pass,
		'help' => \$help,
);

my %options = (	'switch' => \&switch,
	);

helpText() and exit if ($help);

die "ERROR: No device IP provided. Please use \"--ip [<device_ip_address>]\"\n" if (!$ip);
die "ERROR: No option given. Please use \"--option [switch]\" --socket [<socket_number>]\n" if (!$option);
die "ERROR: No device username given. Please use \"--username [<device_username>]\"\n" if (!$user);
die "ERROR: No device password given. Please use \"--password [<device_password>]\". If there is no password for the device, use a space inside double quotes e.g. \"--password \" \"\"\n" if (!$pass);
$option = lc($option);

if (!exists $options{$option}) {
	die "ERROR: Invalid option \"$option\". Valid option is only \"switch\" for now\n";
}

if ($option =~ /switch/i and !$socket) {
	die "ERROR: No socket given for switch option. Please use \"--socket [<socket_number>]\" (Separate multiple sockets with a comma \',\')\n";
}

$ip =~ s/\s+//g;
chomp(my $ping = `ping -c 3 -t 2 $ip 2>&1` || '');
if ($ping) {
	if ($ping !~ m/\s+(0|0\.0)\%\s*packet\s*loss/) {
		warn "WARNING: Ping to the device on IP \"$ip\" failed. Is the IP correct?\n";
	}
} else {
	warn "WARNING: Failed to ping the device. Is the IP \"$ip\" correct?\n";
}

my $socketstring = processSocket(\$socket);

$options{$option}->();

sub switch {
	die "ERROR: No socket given for switch option. Please use --socket [<socket_number>]" if (!$socket);
	die "ERROR: No state given for switch option against socket \"$socket\". Please use --state [on|off]" if (!$state);
	die "ERROR: Invalid state \"$state\". Please use \"on\" or \"off\"\n" if ($state !~ /on|off/i); 
	my $script = $state . 's.cgi';		# Script will then either be "ons.cgi" or "offs.cgi"
	system("wget -q http://$user:$pass\@$ip/$script\?led=$socketstring -O /dev/null");
}

sub processSocket {
	my ($in) = @_;
	my %l2n;
	my $num = 1;
	for ('A' .. 'Z') {
		$l2n{$_} = $num;
		$num++;
	}
	
	my @numsin = split(',',$$in);
	my %converted;
	
	foreach my $numin (@numsin) {
		if ($numin =~ /^[0-9]+$/) {
			$converted{$numin} = 1;
		} elsif ($numin =~ /^[a-zA-Z]$/) {
			$numin = uc($numin);
			$converted{$l2n{$numin}} = 1;
		}
	}

	#return %converted;
	my $string;
	for (1 .. 16) {
		my $num = '0';
		if (exists $converted{$_}) {
			$num = '1';
		}
		$string .= $num;
	}
	
	return $string;
	
}

sub helpText {
print <<HELP;
Lindy 16 Socket Power Bar Control
Author: Chris Get

Required software for use:
	wget		Linux command line web navigation tool. Install with your packagage manager.
				"apt-get install wget" for Debian/Ubuntu.

	ping		Linux command line tool for network device discovery. Install with your packagage manager.
				"apt-get install iputils-ping" for Debian/Ubuntu.

Input Arguments:
	--ip		Defines the IP address or hostname of the Lindy device to be controlled (Required).

	--option	Defines the action you want to perform. Valid option is only "switch" for now.
				"switch" -> Switch socket(s) on the device on or off (use with --state [on|off]).
	
	--socket	Defines the socket(s) you want to target for the action. You can use letters or numbers to identify the sockets.
				separate with a comma for multiple sockets e.g. "A,3,D".

	--state		Defines the state you want to change the socket(s) to ("on" or "off"). Use with "--option switch"

	--username	Defines the username for accessing the web interface of the device.

	--password	Defines the password for accessing the web interface of the device.

	--help		Display this help text. 

HELP
}
