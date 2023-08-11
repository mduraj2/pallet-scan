# pallet_build

This app helps users to sort different parts iat the end of the line.
Unfortunately Perl is not the best tool for it from many different reasons. The biggest is security or its lack. The code in the app can be easily modified to bypass password (and other functions) + the password is visible while typing.
There needs to be a cron job set up in the system that clears the tables in db. This can also be achieved manually by typing CLEAR on the main window.

The serial number needs to be added to:
db: general
table: stations
columns: id, station, serial_number, path, ip_address
WHERE path & ip_address can be set to whatever e.g. 'NA'
AND station needs to have a structure like 'place_line_type' e.g. 'NLDC_NL07_PALLET-BUILD'

user: p3user

db:general
tables(columns)
#1 modes(id,line,mode,product,product_options,mode_options,clearstatus)
#2 passwords(name,password,encryptedpassword)

db:p3
tables(columns):
#1 pallet_build_loc(number,line,mpn,status,vendor)

# version history

1.0 - 10.03.2020 - initial app
6.0 - 31.01.2023 - the logic changed to simplify validation scans