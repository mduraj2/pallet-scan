#!/usr/bin/env perl

use File::Basename ();
$dir = File::Basename::dirname($0);

$job = `ps aux | grep pallet_build_location | grep -v "perl $dir/Launch_pallet" | grep -v "grep pa" | awk {'print\$2'}`;
system `kill $job`;
sleep 2;
system "open -a Terminal.app $dir/pallet_build_location.command";

exit;