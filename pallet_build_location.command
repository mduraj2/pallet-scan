#!/usr/bin/env perl

# Name: Pallet build location
# Purpose: Displaying a pallet number to user instead of a need of reading the part number from the box
# Author: Miroslaw Duraj
# Date: 10/Mar/2020
$project = 'pallet-build';
$version = '-6.0';

#use strict;
use Term::ANSIColor;
#use warnings;
use v5.10; # for say() function
use Time::Piece;
use File::Basename ();
use Digest::SHA qw(sha256_hex);

$dir = File::Basename::dirname($0);
$logfile = "$0.log";
$time = localtime->datetime;
 
use DBI;
say "Perl MySQL Connect Database";
# MySQL database configuration
#'dsn0' is only used for checking if the SN of the machine exists in db
$dsn0 = "DBI:mysql:general:172.30.1.199";

$dsn = "DBI:mysql:p3:172.30.1.199";

$username = 'p3user';
$password = 'p3user';

#######
#######
#######

$stn = substr(`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`,30,12);

system ("echo '$time\tPallet build location tool started\n' >> $logfile");

system "clear";
$dbh = DBI->connect($dsn0,$username,$password, \%attr) or handle_error (DBI::errstr);

#Getting ip address
$ip_address = `ipconfig getifaddr en0`;
$ip_address =~ s/^\s*(.*?)\s*$/$1/;

if ($ip_address eq '') {

	$ip_address = `ipconfig getifaddr en1`;
	$ip_address =~ s/^\s*(.*?)\s*$/$1/;
	
	if ($ip_address eq '') {
		$ip_address = "TBA";
	}
}

commands();

check_sn($dbh);

if ($station eq '')
	{
		my $station = $stn;
		print ("Station: $stn\n");
		system ("echo '$time\t$stn\tNo location set up in db\n' >> $logfile");
		print color('bold red');
		print "$command1";
		print color('reset');
		print "$command0";
		<>;
		exit;
	} 
	else 
	{
		$stn = $station;
		print ("Station: $stn\n");
	}
##########END

# disconnect from the MySQL database
$dbh->disconnect();

###################################################################### SCAN START

RESET:

$line = '';

check_line();

	if ($line eq '')
	{
		system ("afplay '$dir/redalert.wav' &");
		system ("echo '$time\tWrong format of station setup\n' >> $logfile");
		print color('bold red');
		print "$command2"; print color('reset');
		print "$command0";
		<>;
		exit;
	}


system clear;

if (index($stn, "PALLETBUILD") != -1)
	{
		goto SCANPART;
	}
else
	{
		system ("afplay '$dir/redalert.wav' &");
		system ("echo '$time\t$stn\tStation not set up for this process\n' >> $logfile");
		print color('bold red');
		print "Station has not been set up for this process. Contact Supervisor!\n";
		print color('reset');
		print "Press Enter to close...";
		<>;
		exit;
	}

SCANPART:

$mpn = '';
$first_3_mpn = '';
$routing = "SCANPART";

while (1)
{
	system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');

	print("Scan MPN: ");

	chomp ($mpn = <>);
	$mpn = uc($mpn);
	$mpn =~ s/[\n\r\s]+//g;

	if ($mpn eq 'Q')
	{
		print "Exiting...\n";
		exit;
	}
	elsif (uc($mpn) eq 'CHECK')
	{
		goto CHECK;
	}

	elsif (uc($mpn) eq 'SEARCH')
	{
		goto SEARCH;
	}
	elsif (uc($mpn) eq 'CLEAR')
	{
		goto CLEAR;
	}
	elsif (uc($mpn) eq 'STATUS')
	{
		goto STATUS;
	}
	else {
	$validatedString = $mpn;
	checkFormat();
	}

	$mpn = $validatedString;
	
	$dbh = DBI->connect($dsn,$username,$password, \%attr) or handle_error (DBI::errstr);
	check_pallet_build_loc($dbh);
	
	print color('bold blue');
    print "This box belongs to pallet: "; print color('reset'); print "$location_pallet_build\n";
    
	sleep 2;
	
	check_version();
	
	goto SCANPART;
	
}

CHECK:
$routing = "CHECK";
while (1)
{
	print "#################################################\n";
	$dbh = DBI->connect($dsn,$username,$password, \%attr) or handle_error (DBI::errstr);
	checkLine($dbh);
	print "#################################################\n";
	print "Press Enter to continue...\n";
	<>;
	goto SCANPART;
}

SEARCH:
$routing = "SEARCH";
while (1)
{
	system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');
	print "Enter the searching MPN or type COMPLETE to go back: ";
	chomp ($searchMPN = <>);
	$searchMPN = uc($searchMPN);
	$searchMPN =~ s/[\n\r\s]+//g;
	if (uc($searchMPN) eq 'COMPLETE')
		{ goto SCANPART
	}
	$validatedString = $searchMPN;
	checkFormat();
	$searchMPN = $validatedString;
	print "#################################################\n";
	$dbh = DBI->connect($dsn,$username,$password, \%attr) or handle_error (DBI::errstr);
	checkMPN($dbh);
	print "MPN $returnedMPN belongs to pallet: ";print color('bold green');print "$returnedPalletID\n";print color('reset');
	print "#################################################\n";
	print "Press Enter to continue...\n";
	<>;
	check_version();
}

CLEAR:
$routing = "CLEAR";
while (1)
{
	$dbh = DBI->connect($dsn0,$username,$password, \%attr) or handle_error (DBI::errstr);
	checkPassword($dbh);
	system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');
	print "Are you sure you want to clear the sortation (type 'Y')? ";
	chomp ($confirmation = <>);
	$confirmation = uc($confirmation);
	$confirmation =~ s/[\n\r\s]+//g;

	if ($confirmation ne 'Y') {
		goto SCANPART;
	}

print "Enter password: ";

chomp ($pass = <>);
$pass = sha256_hex($pass);
system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');
if ($key ne $pass) {
	print color('bold red');
	system ("afplay '$dir/sounds/wrongansr.wav'");
	print "Incorrect password...going back to beginning...\n";
	print color('reset');
	sleep 3;
	goto SCANPART;
}
	$dbh = DBI->connect($dsn,$username,$password, \%attr) or handle_error (DBI::errstr);
	clearSortation($dbh);
	print color('bold yellow');
	print "Pallet build sortation for line $line has been cleared.\n";
	print color('reset');
	print "Press Enter to continue...\n";
	<>;
	goto SCANPART;
}

STATUS:
$routing="STATUS";
$clearStatus = '';
while (1)
{
	$dbh = DBI->connect($dsn0,$username,$password, \%attr) or handle_error (DBI::errstr);
	checkPassword($dbh);

	checkStatus($dbh);
	$clearStatus = $resultCheckStatus;

	system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');
	if (uc($clearStatus) eq "N") {
		print "Automatic clearing for ";print color('bold blue');print "$line";print color('reset');print " is currently ";print color('bold red');print "disabled\n";
		print color('reset');
		$newClearStatus='Y';
		$newClearStatusMessage = 'enabled';
	} else {
		print "Automatic clearing for ";print color('bold blue');print "$line";print color('reset');print " is currently ";print color('bold green'); print "enabled\n";
		print color('reset');
		$newClearStatus='N';
		$newClearStatusMessage = 'disabled';
	}
	print "Are you sure you want to change it (type 'Y')? ";
	chomp ($confirmation = <>);
	$confirmation = uc($confirmation);
	$confirmation =~ s/[\n\r\s]+//g;

	if ($confirmation ne 'Y') {
		goto SCANPART;
	}

print "Enter password: ";

chomp ($pass = <>);
$pass = sha256_hex($pass);
system clear;
	print color('bold green');
	print "Pallet build location$version - $stn\n";
	print color('reset');
if ($key ne $pass) {
	print color('bold red');
	system ("afplay '$dir/sounds/wrongansr.wav'");
	print "Incorrect password...going back to beginning...\n";
	print color('reset');
	sleep 3;
	goto SCANPART;
}

$dbh = DBI->connect($dsn0,$username,$password, \%attr) or handle_error (DBI::errstr);
changeStatus($dbh);
	print "Clearing status for $line has been ";
	if (uc($newClearStatus) eq 'Y') {print color('bold green')} else { print color('bold red')}; print "$newClearStatusMessage.\n";
	print color('reset');
	print "Press Enter to continue...\n";
	<>;
	goto SCANPART;
}
#sub routines
##############################################################################
sub commands{
	$command0 = "Contact Supervisor! Press Enter to continue...";
	$command1 = "Station has not been set up yet!\n";
	$command2 = "Wrong format of station setup.\n";
}

sub changeStatus {
	($dbh) = @_;
    $sql = "SELECT id FROM modes WHERE line='$line'";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();

	my $ref;
    
    $ref = $sth->fetchall_arrayref([]);

if ((0 + @{$ref}) > 0)
    {
    $sql = "UPDATE modes SET clearstatus='$newClearStatus' WHERE line='$line'";
    $sth = $dbh->prepare($sql);
 
    # execute the query
    $sth->execute();
    } else {
    $sql = "INSERT INTO modes VALUES (NULL,'$line','NA','NA','NA','NA',DEFAULT)";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();

    }
    $sth->finish;
}

sub checkStatus {
	($dbh) = @_;
    $sql = "SELECT clearstatus FROM modes WHERE line='$line'";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();

	my $ref;
    
    $ref = $sth->fetchall_arrayref([]);

if ((0 + @{$ref}) > 0)
    {
        foreach $data (@$ref)
        {
            ($resultCheckStatus) = @$data;
        }

    } else {
    	$resultCheckStatus = "";
    }
    $sth->finish;
}

sub clearSortation {
	($dbh) = @_;
    $sql = "DELETE FROM pallet_build_loc WHERE line = '$line'";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
    $sth->finish;
}
sub checkPassword{
# query from the links table
    ($dbh) = @_;
    $sql = "SELECT encryptedpassword FROM passwords WHERE name = '$project'";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
    
	my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
	if ((0 + @{$ref}) eq 0) {
		system ("afplay '$dir/sounds/redalert.wav'");
		print color('bold red');
		print "No passwords found in db...Contact TE\n";
		print color('reset');
		exit;
	} else {
		foreach $data (@$ref)
            {
                ($key) = @$data;
            }
	}
    $sth->finish;
}

sub checkFormat(){
	$first1 = substr($validatedString,0,1);
	$first3 = substr($validatedString,0,3);
	$first4 = substr($validatedString,0,4);
	$lengthValidatedString = length $validatedString;
	$substring = "/A";

	if ($lengthValidatedString > 15 && $lengthValidatedString < 27 && index($validatedString, "/A") != -1 )
	{
		#print "1";
		$validatedString = substr($validatedString,16);
		$first1 = substr($validatedString,0,1);
	}
	elsif ($first3 eq '240')
	{
		#print "2";
		$validatedString = substr($validatedString,3);
		$first1 = substr($validatedString,0,1);
	}
	elsif ($first3 eq 'V3,')
	{
		#print "3";
		mpn_from_gs1();
		$validatedString = substr($validatedString,3);
		$first1 = substr($validatedString,0,1);
	}
	elsif ($first3 eq '1PM')
	{
		#print "4";
		$validatedString = substr($validatedString,2);
		$first1 = substr($validatedString,0,1);
		
	}
	elsif ($first4 eq '1PZ1')
	{
		$validatedString = substr($validatedString,2);
		$first2 = substr($validatedString,0,2);
	}
	$lengthValidatedString = length $validatedString;
	if (not (((index($validatedString, $substring) != -1) && ($lengthValidatedString eq 8 || $lengthValidatedString eq 9) && $first1 eq "M")|| ($lengthValidatedString eq 9 && $first2 eq "Z1"))){
		print "String: $validatedString does not match criteria (8-9 characters & starts with 'M' & includes '/A' or 9 characters & starts with 'Z')\n";
		system "clear";
		system ("afplay '$dir/redalert.wav' &");
		print color('bold red');
		print "Format not found. Try again.\n";
		sleep 3;
		goto $routing;
	} else {
		print color('bold green');print "Format looks good. Searching in database now...\n";print color('reset');;
	}
}
sub mpn_from_gs1{

	my ($str_begin ,$str_end , $nth_begin, $nth_end, $find, $p_begin, $p_end, $p);

	$str_begin = $validatedString;
	$str_end = $validatedString;
	$nth_begin = 4; $find = ','; $nth_end = $nth_begin+1;
	
	$str_begin =~ m/(?:.*?$find){$nth_begin}/g;
	
	$str_end =~ m/(?:.*?$find){$nth_end}/g;
	
	$p_begin = pos($str_begin) - length($find) +1;
	
	$p_end = pos($str_end) - length($find);
	
	$p = ($p_end - $p_begin);
	
	$validatedString = substr($str_begin, $p_begin, $p) if $p_begin>-1;
	}

sub check_line{

	my ($str_begin ,$str_end , $nth_begin, $nth_end, $find, $p_begin, $p_end, $p);

	$str_begin = $stn;
	$str_end = $stn;
	$nth_begin = 1; $find = '_'; $nth_end = $nth_begin+1;

	$str_begin =~ m/(?:.*?$find){$nth_begin}/g;
	$str_end =~ m/(?:.*?$find){$nth_end}/g;
	$p_begin = pos($str_begin) - length($find) +1;
	$p_end = pos($str_end) - length($find);
	$p = ($p_end - $p_begin);

	$line = substr($str_begin, $p_begin, 4) if $p_begin>-1;

}

sub checkMPN {
	($dbh) = @_;
    $sql = "SELECT mpn, number FROM pallet_build_loc
	WHERE line='$line' and mpn='$searchMPN'";

    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
	
	my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    if ((0 + @{$ref}) > 0)
	{
	 foreach $data (@$ref)
            {
                ($returnedMPN, $returnedPalletID) = @$data;
            }
	} else {
		print color('bold red');
    	print "No MPN available on this line\n";
		print color('reset');
		print "#################################################\n";
		print "Press Enter to continue...";
		<>;
    	goto SEARCH;
	}
	
    $sth->finish;
}

sub checkLine {
	($dbh) = @_;
    $sql = "SELECT line,mpn,status,number FROM pallet_build_loc
	WHERE line='$line'";

    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
	
	my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
    #print "Number of rows returned is ", 0 + @{$ref}, "\n";    
    if ((0 + @{$ref}) > 0)
    {
    	print "|  LINE\tMPN\t\tSTATUS\t\tNUMBER  |\n";
        foreach $data (@$ref)
        {
            ($lineDb,$mpnDb,$statusDb,$numberDb) = @$data;
			if ($statusDb eq 'ACTIVE') {
				print "|  $lineDb\t$mpnDb\t$statusDb\t\t$numberDb\t|\n";
			} else {
            	print "|  $lineDb\t$mpnDb\t$statusDb\t$numberDb\t|\n";
			}
        }

    } else {
    	print color('bold red');
    	print "No locations available\n";
		print color('reset');
		system ("afplay '$dir/wrongansr.wav'");
		print "Press Enter to continue...";
		<>;
    	goto SCANPART;
    }
	
    $sth->finish;
}
sub check_pallet_build_loc{
	$number = '1';
	# query from the links table
    ($dbh) = @_;
    $sql = "SELECT number,status FROM pallet_build_loc
	WHERE mpn='$mpn' AND line='$line'";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
    
    my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
    if ((0 + @{$ref}) == 0)
    {
    	($dbh) = @_;
   		$sql = "SELECT number FROM pallet_build_loc
		WHERE line='$line' ORDER BY number";
    	$sth = $dbh->prepare($sql);
    
    	# execute the query
    	$sth->execute();
    
    	my $ref;
    	$ref = $sth->fetchall_arrayref([]);
    
    	if ((0 + @{$ref}) != 0)
    	{
    		foreach $item (@$ref)
    		{
    			($result) = @$item;
    			if ($number != $result)
    			{
    				last;
    			}
    			$number++;
    		}
    	}

    	($dbh) = @_;
    	$sql = "INSERT INTO pallet_build_loc (number, line, mpn, status, vendor)
		VALUES ('$number','$line','$mpn','ACTIVE','$vendor')";
    	$sth = $dbh->prepare($sql);
    
    	# execute the query
    	$sth->execute();
    	sleep 1;
    	$sth->finish;
    	
    	$dbh = DBI->connect($dsn,$username,$password, \%attr) or handle_error (DBI::errstr);
    	check_pallet_build_loc($dbh);
    	
    }     
    	
    foreach $data (@$ref)
    {
    	($location_pallet_build,$status) = @$data;
    }
    	
    if ($status eq "INACTIVE")
    {
    	($dbh) = @_;
    	$sql = "UPDATE pallet_build_loc SET status='ACTIVE'
		WHERE mpn='$mpn' AND line='$line'";
   		$sth = $dbh->prepare($sql);
    
    	# execute the query
   		$sth->execute();
   	}    

	$sth->finish;

}

sub check_sn{
    # query from the links table
    ($dbh) = @_;
    $sql = "SELECT * FROM stations
	WHERE serial_number =('$stn')";
    $sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
   
    my $ref;
    
    $ref = $sth->fetchall_arrayref([]);
    
    #print "Number of rows returned is ", 0 + @{$ref}, "\n";    
            foreach $data (@$ref)
            {
                ($serial, $station,) = @$data;
            }
            
      
	if ((0 + @{$ref}) > 0){
		$sql = "UPDATE stations
	SET ip_address =('$ip_address') WHERE serial_number =('$stn')";
	$sth = $dbh->prepare($sql);
    
    # execute the query
    $sth->execute();
	}
	  $sth->finish;
}

sub handle_error{
	print color('bold red');
	$time = localtime->datetime;
	system ("echo '$time\tUnable to connect to database\n' >> $logfile");
	print "Unable to connect to database. Contact your Supervisor\n";
	system ("afplay '$dir/wrongansr.wav'");
	print "Press Enter to close...\n";
	print color('reset');
	<>;
	exit;
}

sub check_version{

	my $file = "$dir/pallet_build_location.command";

	open(FH, $file) or die $!;

	while(my $string = <FH>)
	{
		if($string =~ /.version.[=]./)
		{
			print "$string";
			$len_string = (length $string) - 15;
			$new_ver = substr($string,12,$len_string);
			#print "\nNew version: $new_ver\n";
			#print "Current version: $version\n";
			if ($new_ver eq $version)
			{
				print "Found a match. Doing nothing...\n";
			}
			else
			{
				print "Updating the current version to the latest one...\n";
			
				system("$dir/Launch_pallet_build_location.command $arg1");
				#exit;
			}
		}	
	}
}