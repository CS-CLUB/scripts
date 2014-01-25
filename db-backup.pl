#!/usr/bin/perl
################################################################################
#
# A simple script which makes backups of the database with the following conditions:
#
# - Daily backups are kept if the new backup is different from the previous backup
# - Weekly backups are made regardless if the db doesn't change at all (nothing new)
# - Backups are kept for up to 6 months, older backups are removed
#
# Copyright (C) 2012 Jonathan Gillett, Computer Science Club at DC & UOIT
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################
use warnings;
use Date::Simple ('date', 'today');
use Log::Log4perl qw(:easy);

# Database access
my $db_user = "";
my $db_pass = "";
my $db_name = "";
my $date = today();
# MUST BE THE FULL PATH NO ENVIRONMENT VARIABLES OR "~"
my $db_backup_dir = "";
my $db_filename = "db-backup-${date}.sql";
my $prev_dbdump;
@backups = <$db_backup_dir/*>;
my $db_file_date;
my $backup_logs = "/var/log/db_backup.log";


# Initialize error logging
Log::Log4perl->easy_init( {
    level => $ERROR,
    file  => ">> /var/log/db_backup_errors.log",
} );

# Initialize general logging
open FH,">>${backup_logs}";

# Make a backup for the day
system("mysqldump -u${db_user} -p${db_pass} ${db_name} --single-transaction > ${db_backup_dir}/${db_filename}");

# Check that the backup was successful
unless (-e $db_backup_dir . "/". $db_filename)
{
	
	ERROR("ERROR! FAILED TO CREATE DUMP OF DATABASE, CHECK MYSQL LOG FILES AND BACKUPS!");
} 

# Delete the database backup if it identical to the previous backup that is stored
# and it is not one of the weekly backups (Sunday) that are kept regardless
for ($i = 1; $i < 7; $i++)
{
    $prev_dbdump = "db-backup-" . (today() - $i) . ".sql";
    
    if (-e $db_backup_dir . "/". $prev_dbdump)
    {
        last;
    }
}

# If no previous file found or it is the mandatory weekly backup (Sunday) keep backup
if ((! -e $db_backup_dir . "/" . $prev_dbdump) || (localtime)[6] == 7)
{
    print FH "${date}: Kept database backup\n";
    exit 0;
}

# Delete the current database backup if it is identical to previous backup 
if (`diff ${db_backup_dir}/${prev_dbdump} ${db_backup_dir}/${db_filename} | grep -v 'Dump completed on' | wc -l` < 3)
{
    unless (system("rm -f ${db_backup_dir}/${db_filename}") == 0)
    {
        ERROR("ERROR! FAILED TO DELETE CURRENT DATABASE DUMP WHICH IS IDENTICAL TO PREVIOUS DUMP!");
    }
    print FH "${date}: Deleted current database backup, it is identical to previous backup!\n";
}

# Delete any database backups that are 6 months or older (180+ days)
foreach $db_backup (@backups)
{
   if ($db_backup =~ /(\d{4}\-\d{2}\-\d{2})/)
   {
       $db_file_date = $1;
       
       if (date($date) - date($db_file_date) > 180)
       {
           # Delete the old backup
           unless ((-e $db_backup) && (system("rm -f ${db_backup}") == 0))
           {
                ERROR("ERROR! FAILED TO DELETE OLD DATABASE DUMP THAT IS SIX MONTHS OR OLDER!");
           }
           else
           {
                print FH "${date}: Deleted database backups six months or older!\n";
           }
       }
   }
}
