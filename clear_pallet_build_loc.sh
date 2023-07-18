#!/usr/bin/perl

#open -a Terminal.app /Users/Shared/Pallet_build_location.command
system `/usr/local/Cellar/mysql/8.0.29/bin/mysql -uroot -e  "DELETE FROM p3.pallet_build_loc WHERE status ='INACTIVE' AND line IN (SELECT line FROM general.modes WHERE clearstatus='Y');"`;
sleep 5;
system `/usr/local/Cellar/mysql/8.0.29/bin/mysql -uroot -e  "UPDATE p3.pallet_build_loc SET status='INACTIVE' WHERE line IN (SELECT line FROM general.modes WHERE clearstatus='Y');"`;
#system `/usr/local/Cellar/mysql/8.0.29/bin/mysql -uroot -e  "UPDATE p3.pallet_build_loc SET status='INACTIVE' WHERE line NOT LIKE 'NL04';"`;