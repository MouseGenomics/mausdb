####################################################################
# Backup-Script for MausDB                                         #
####################################################################

use strict;
use Mail::Sendmail;
use CGI qw(:standard);

my %backup_data;

$backup_data{0}{'db_username'}               = '<db-username>';
$backup_data{0}{'db_password'}               = '<password>';
$backup_data{0}{'bin_log_path'}              = '/mysql_binlogs/';
$backup_data{0}{'bin_log_index_file'}        = 'mysql-bin.index';
$backup_data{0}{'bin_log_backup_path'}       = '/path/to/your/backup/';
$backup_data{0}{'admin_mail'}                = 'admin@your.institution.com';
$backup_data{0}{'admins_mail'}               = 'admin1@your.institution.com; admin2@your.institution.com';
$backup_data{0}{'database'}                  = 'all databases';
$backup_data{0}{'host'}                      = '<mausdb_hostname>';            # if mausdb.uni-abc.de is your MausDB server, enter "mausdb" here

$backup_data{1}{'database'}                  = 'mausdb_1';
$backup_data{1}{'db_username'}               = '<db-username>';
$backup_data{1}{'db_password'}               = '<password>';
$backup_data{1}{'db_dump_path'}              = '/home/admin/backup/daten/mausdb_1/';
$backup_data{1}{'db_dump_2nd_path'}          = '/path/to/your/backup/mausdb/daten/mausdb_1/';
$backup_data{1}{'db_dump_prefix'}            = 'mausdb_1_';
$backup_data{1}{'error_log_path'}            = '/home/admin/backup/daten/mausdb_1/';
$backup_data{1}{'error_log_prefix'}          = 'error_mausdb_1_';
$backup_data{1}{'audit_log_path'}            = '/usr/lib/cgi-bin/mausdb_1/logs/';
$backup_data{1}{'audit_log_backup_path'}     = '/home/admin/backup/logs/mausdb_1/';
$backup_data{1}{'audit_log_backup_2nd_path'} = '/path/to/your/backup/mausdb/logs/mausdb_1/';
$backup_data{1}{'audit_log_backup_prefix'}   = 'mausdb_1_audit_logs_';
$backup_data{1}{'maustmp_tempdir'}           = '/var/www/mausdb_1/maustmp/';
$backup_data{1}{'download_files_tempdir'}    = '/usr/lib/cgi-bin/mausdb_1/files/';
$backup_data{1}{'session_tempdir'}           = '/usr/lib/cgi-bin/mausdb_1/sessions/';
$backup_data{1}{'admin_mail'}                = 'admin1@your.institution.com';
$backup_data{1}{'admins_mail'}               = 'admin1@your.institution.com; admin2@your.institution.com';
$backup_data{1}{'do_backup_test'}            = 'yes';
$backup_data{1}{'backup_database'}           = 'mausdb_1_backup';
$backup_data{1}{'backup_host'}               = '<mausdb_backup_hostname>';     # if mausdb_backup.uni-abc.de is your MausDB backup server, enter "mausdb_backup" here
$backup_data{1}{'backup_db_username'}        = 'mausdb_1_backup';
$backup_data{1}{'backup_db_password'}        = '<mausdb_1_backup_password>';

$backup_data{2}{'database'}                  = 'mausdb_2';
$backup_data{2}{'db_username'}               = '<db-username>';
$backup_data{2}{'db_password'}               = '<password>';
$backup_data{2}{'db_dump_path'}              = '/home/admin/backup/daten/mausdb_2/';
$backup_data{2}{'db_dump_2nd_path'}          = '/path/to/your/backup/mausdb/daten/mausdb_2/';
$backup_data{2}{'db_dump_prefix'}            = 'mausdb_2_';
$backup_data{2}{'error_log_path'}            = '/home/admin/backup/daten/mausdb_2/';
$backup_data{2}{'error_log_prefix'}          = 'error_mausdb_2_';
$backup_data{2}{'audit_log_path'}            = '/usr/lib/cgi-bin/mausdb_2/logs/';
$backup_data{2}{'audit_log_backup_path'}     = '/home/admin/backup/logs/mausdb_2/';
$backup_data{2}{'audit_log_backup_2nd_path'} = '/path/to/your/backup/mausdb/logs/mausdb_2/';
$backup_data{2}{'audit_log_backup_prefix'}   = 'mausdb_2_audit_logs_';
$backup_data{2}{'maustmp_tempdir'}           = '/var/www/mausdb_2/maustmp/';
$backup_data{2}{'download_files_tempdir'}    = '/usr/lib/cgi-bin/mausdb_2/files/';
$backup_data{2}{'session_tempdir'}           = '/usr/lib/cgi-bin/mausdb_2/sessions/';
$backup_data{2}{'admin_mail'}                = 'admin1@your.institution.com';
$backup_data{2}{'admins_mail'}               = 'admin1@your.institution.com; admin2@your.institution.com';
$backup_data{2}{'do_backup_test'}            = 'yes';
$backup_data{2}{'backup_database'}           = 'mausdb_2_backup';
$backup_data{2}{'backup_host'}               = '<mausdb_backup_hostname>';
$backup_data{2}{'backup_db_username'}        = 'mausdb_2_backup';
$backup_data{2}{'backup_db_password'}        = '<mausdb_1_backup_password>';


# backup MausDB-1
if (defined(param('do_backup')) && param('do_backup') eq 'yes') {
   do_backup(1);
}

# backup MausDB-2
if (defined(param('do_backup')) && param('do_backup') eq 'yes') {
   do_backup(2);
}

# flush the bin-logs
if (defined(param('flush_bin_logs')) && param('flush_bin_logs') eq 'yes') {
   flush_bin_logs(0);
}

# no parameters given: short help on usage
if (!defined(param('do_backup')) && !defined(param('flush_bin_logs'))) {
   print "Usage: #> (sudo) perl backup.pl do_backup=yes      (to do the full dumps)\n"
       . "       #> (sudo) perl backup.pl flush_bin_logs=yes (to flush and backup the binary logs)\n\n";
}


#-------------------------------------------------------------------------------
#  do_backup():                    do the backup
sub do_backup {
  my $backup = shift;
  my ($command_line, $system_message, $ls_l);
  my $mailbody = '';
  my $datetime = current_datetime();
  my $error_counter = 0;
  my ($errors, $mice_alive_1, $mice_alive_2, $occupied_cages_1, $occupied_cages_2);
  my %mail_to_admin = ();
  my $current_datetime = current_datetime();
  my $previous_log;


  ###########################################################################################
  # Full dump
  $mailbody .= "####################################################################\n"
               . "1a) Starting full dump of $backup_data{$backup}{'database'} on $backup_data{$backup}{'host'} at $current_datetime\n\n";

  print STDOUT "####################################################################\n"
               . "1a) Starting full dump of $backup_data{$backup}{'database'} on $backup_data{$backup}{'host'} at $current_datetime\n\n";

  # do the full dump (and flush the bin-log)
  $command_line =   'mysqldump --opt --flush-logs --master-data=2 -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'}
                  . ' > ' . $backup_data{$backup}{'db_dump_path'}   . $backup_data{$backup}{'db_dump_prefix'}   . $datetime . '.sql'
                  . ' 2>' . $backup_data{$backup}{'error_log_path'} . $backup_data{$backup}{'error_log_prefix'} . $datetime . '.log';

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'db_dump_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Full dump finished at $current_datetime: \n\n";
  print STDOUT "Full dump finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of backup directory ($backup_data{$backup}{'db_dump_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";

  print STDOUT "Listing of backup directory ($backup_data{$backup}{'db_dump_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";



  ###########################################################################################
  # copy bin-log from host to backup path
  $current_datetime = current_datetime();

  $mailbody .= "####################################################################\n"
               . "1b) Copy bin-log to $backup_data{0}{'bin_log_backup_path'} at $current_datetime\n\n";

  print STDOUT "####################################################################\n"
               . "1b) Copy bin-log to $backup_data{0}{'bin_log_backup_path'} at $current_datetime\n\n";

  # get the name of the previous log: "tail -2 /var/log/mysql/mysql-bin.index | head -n 1" (show the last but one entry)
  $command_line =  'tail -2 ' . $backup_data{0}{'bin_log_path'} . $backup_data{0}{'bin_log_index_file'} . ' | head -n 1';
  $previous_log = `$command_line`;
  chomp($previous_log);           # remove the newline

  # now copy the previous log to the backup dir
  $command_line =  'cp ' . $previous_log . ' ' . $backup_data{0}{'bin_log_backup_path'};
  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{0}{'bin_log_backup_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "copy previous bin-log finished at $current_datetime: \n\n";
  print STDOUT "copy previous bin-log finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of bin-log backup directory ($backup_data{0}{'bin_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";

  print STDOUT "Listing of bin-log backup directory ($backup_data{0}{'bin_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";
	       
	       
  ###########################################################################################
  # Compression of full dump
  $current_datetime = current_datetime();

  $mailbody .= "2a) Starting compression of $backup_data{$backup}{'database'} at $current_datetime\n\n";
  print STDOUT "2a) Starting compression of $backup_data{$backup}{'database'} at $current_datetime\n\n";

  $command_line = 'tar -cvzf ' . $backup_data{$backup}{'db_dump_path'} . $backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql.tar.gz' . ' '
                               . $backup_data{$backup}{'db_dump_path'} . $backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql';

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'db_dump_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Compression finished at $current_datetime: \n\n";
  print STDOUT "Compression finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of backup directory ($backup_data{$backup}{'db_dump_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of backup directory ($backup_data{$backup}{'db_dump_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # Copy dump to backup path
  $current_datetime = current_datetime();

  $mailbody .= "2b) Copy compressed dump file (" . $backup_data{$backup}{'db_dump_path'} . $backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql.tar.gz' .
               ") to NAS ($backup_data{$backup}{'db_dump_2nd_path'}) at $current_datetime\n\n";
  print STDOUT "2b) Copy compressed dump file (" . $backup_data{$backup}{'db_dump_path'} . $backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql.tar.gz' .
               ") to NAS ($backup_data{$backup}{'db_dump_2nd_path'}) at $current_datetime\n\n";

  $command_line = 'cp ' . $backup_data{$backup}{'db_dump_path'} . $backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql.tar.gz' . ' '
                        . $backup_data{$backup}{'db_dump_2nd_path'};

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'db_dump_2nd_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Copy finished at $current_datetime: \n\n";
  print STDOUT "Copy finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of 2nd backup directory ($backup_data{$backup}{'db_dump_2nd_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of 2nd backup directory ($backup_data{$backup}{'db_dump_2nd_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # Backup of audit-log - files
  $current_datetime = current_datetime();

  $mailbody .= "3a) Starting backup of audit-log files (in $backup_data{$backup}{'audit_log_path'}) at $current_datetime\n\n";
  print STDOUT "3a) Starting backup of audit-log files (in $backup_data{$backup}{'audit_log_path'}) at $current_datetime\n\n";

  $command_line = 'tar -cvzf ' . $backup_data{$backup}{'audit_log_backup_path'} . $backup_data{$backup}{'audit_log_backup_prefix'} . $datetime . '.tar.gz' . ' '
                               . $backup_data{$backup}{'audit_log_path'};

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'audit_log_backup_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Backup of audit-log files finished at $current_datetime: \n\n";
  print STDOUT "Backup of audit-log files finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of audit log backup directory ($backup_data{$backup}{'audit_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of audit log backup directory ($backup_data{$backup}{'audit_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # copy audit-log - files to backup path
  $current_datetime = current_datetime();

  $mailbody .= "3b) Copy compressed audit log files (" . $backup_data{$backup}{'audit_log_backup_path'} . $backup_data{$backup}{'audit_log_backup_prefix'} . 
$datetime . '.sql.tar.gz' .
               ") to NAS ($backup_data{$backup}{'audit_log_backup_2nd_path'}) at $current_datetime\n\n";
  print STDOUT "3b) Copy compressed audit log files (" . $backup_data{$backup}{'audit_log_backup_path'} . $backup_data{$backup}{'audit_log_backup_prefix'} . 
$datetime . '.sql.tar.gz' .
               ") to NAS ($backup_data{$backup}{'audit_log_backup_2nd_path'}) at $current_datetime\n\n";

  $command_line = 'cp  ' . $backup_data{$backup}{'audit_log_backup_path'} . $backup_data{$backup}{'audit_log_backup_prefix'} . $datetime . '.tar.gz' . ' '
                         . $backup_data{$backup}{'audit_log_backup_2nd_path'};

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'audit_log_backup_2nd_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Copy of audit-log files finished at $current_datetime: \n\n";
  print STDOUT "Copy of audit-log files finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of 2nd audit log backup directory ($backup_data{$backup}{'audit_log_backup_2nd_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of 2nd audit log backup directory ($backup_data{$backup}{'audit_log_backup_2nd_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # delete temporary data (e.g. Barcode-PNGs)
  $current_datetime = current_datetime();

  $mailbody .= "4) Deleting temporary image files (in $backup_data{$backup}{'maustmp_tempdir'}) at $current_datetime\n\n";
  print STDOUT "4) Deleting temporary image files (in $backup_data{$backup}{'maustmp_tempdir'}) at $current_datetime\n\n";

  $command_line = 'rm -f ' . $backup_data{$backup}{'maustmp_tempdir'} . '*.png';

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'maustmp_tempdir'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Deleting of temporary image files finished at $current_datetime: \n\n";
  print STDOUT "Deleting of temporary image files finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of temporary image directory ($backup_data{$backup}{'maustmp_tempdir'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of temporary image directory ($backup_data{$backup}{'maustmp_tempdir'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # delete temporary data (e.g. Excel files)
  $current_datetime = current_datetime();

  $mailbody .= "5) Deleting temporary download files (in $backup_data{$backup}{'download_files_tempdir'}) at $current_datetime\n\n";
  print STDOUT "5) Deleting temporary download files (in $backup_data{$backup}{'download_files_tempdir'}) at $current_datetime\n\n";

  $command_line = 'rm -f ' . $backup_data{$backup}{'download_files_tempdir'} . '*.xls';

  $system_message = system($command_line);

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'download_files_tempdir'}`;

  $current_datetime = current_datetime();

  $mailbody .= "Deleting of temporary download files finished at $current_datetime: \n\n";
  print STDOUT "Deleting of temporary download files finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of temporary download directory ($backup_data{$backup}{'download_files_tempdir'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";

  print STDOUT "Listing of temporary download directory ($backup_data{$backup}{'download_files_tempdir'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # check number of alive animals
  $current_datetime = current_datetime();

  $mailbody .= "6) Checking number of alive animals at $current_datetime\n\n";
  print STDOUT "6) Checking number of alive animals at $current_datetime\n\n";

  $command_line = "echo 'select count(*) as mice_alive from mice where mouse_deathorexport_datetime is null;' "
                  . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'};

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $mice_alive_1 = `$command_line`;

  $mailbody .= "Number of alive animals (method 1):\n$mice_alive_1";
  print STDOUT "Number of alive animals (method 1):\n$mice_alive_1";

  $command_line = "echo 'select count(*) as mice_alive from mice2cages where m2c_datetime_to is null and m2c_cage_id > 0;' "
                  . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'};

  $mice_alive_2 = `$command_line`;

  $mailbody .= "Number of alive animals (method 2):\n$mice_alive_2";
  print STDOUT "Number of alive animals (method 2):\n$mice_alive_2";

  if ($mice_alive_1 eq $mice_alive_2) {
     $mailbody .= "\nNO ERRORS\n\n";
     print STDOUT "\nNO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "\nTHERE WHERE ERRORS!\n\n";
     print STDOUT "\nTHERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";
  print STDOUT "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # check number of occupied cages
  $current_datetime = current_datetime();

  $mailbody .= "7) Checking number of occupied cages at $current_datetime\n\n";
  print STDOUT "7) Checking number of occupied cages at $current_datetime\n\n";

  $command_line = qq(echo "select count(*) from cages where cage_id > 0 and cage_occupied = 'y';")
                  . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'};

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $occupied_cages_1 = `$command_line`;

  $mailbody .= "Number of occupied cages (method 1):\n$occupied_cages_1";
  print STDOUT "Number of occupied cages (method 1):\n$occupied_cages_1";

  $command_line = "echo 'select count(*) from cages2locations where c2l_datetime_to is null and c2l_cage_id > 0' "
                  . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'};

  $occupied_cages_2 = `$command_line`;

  $mailbody .= "Number of occupied cages (method 2):\n$occupied_cages_2";
  print STDOUT "Number of occupied cages (method 2):\n$occupied_cages_2";

  if ($occupied_cages_1 eq $occupied_cages_2) {
     $mailbody .= "\nNO ERRORS\n\n";
     print STDOUT "\nNO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "\nTHERE WHERE ERRORS!\n\n";
     print STDOUT "\nTHERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";
  print STDOUT "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # check tables
  $current_datetime = current_datetime();

  $mailbody .= "8) Checking tables of database $backup_data{$backup}{'database'} on $backup_data{$backup}{'host'} at $current_datetime\n\n";
  print STDOUT "8) Checking tables of database $backup_data{$backup}{'database'} on $backup_data{$backup}{'host'} at $current_datetime\n\n";

  # CAUTION: when adding/removing tables, update the check table command below accordingly!
  $command_line = "echo 'CHECK TABLE addresses, cages, cages2locations, carts, contacts, contacts2addresses, days, death_reasons, experiments, externalDBs, 
genes, genes2externalDBs, healthreports, imports, imports2contacts, litters, litters2parents, locations, log_access, log_uploads, matings, medical_records, 
medical_records2sops, mice, mice2blob_data, mice2cages, mice2experiments, mice2genes, mice2healthreports, mice2medical_records, mice2mousegroups, mice2orderlists, 
mice2phenotypesDB, mice2projects, mice2properties, mousegroups, mouse_coat_colors, mouse_lines, mouse_lines2genes, mouse_strains, mylocks, 
orderlists, parameters, parametersets, parametersets2parameters, parents2matings, projects, properties, settings, sops, users, users2projects, 
workflows, workflows2parametersets' "
                  . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'}
                  . ' '   . $backup_data{$backup}{'database'};

  $system_message = `$command_line`;

  $mailbody .= "command line: $command_line\n\n";
  print STDOUT "command line: $command_line\n\n";

  $mailbody .= "tables of $backup_data{$backup}{'database'}:\n";
  print STDOUT "tables of $backup_data{$backup}{'database'}:\n";

  my @lines = split(/\n/, $system_message);
  my ($line, $table, $status);

  shift(@lines);

  foreach $line (@lines) {
      ($table, undef, undef, $status) = split(/\t|\s+/, $line);

      if ($status ne "OK") {
         $error_counter++;
      }

      $mailbody .= "$status\t$table\n";
      print STDOUT "$status\t$table\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";
  print STDOUT "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # testing dump (restore to the demo database) if required
  if ($backup_data{$backup}{'do_backup_test'} eq 'yes') {
     $current_datetime = current_datetime();

     $mailbody .= "9) testing dump of $backup_data{$backup}{'database'} (restore it to $backup_data{$backup}{'backup_database'} on $backup_data{$backup}{'backup_host'}) at $current_datetime\n\n";
     print STDOUT "9) testing dump of $backup_data{$backup}{'database'} (restore it to $backup_data{$backup}{'backup_database'} on $backup_data{$backup}{'backup_host'}) at $current_datetime\n\n";

     $command_line = 'mysql -h ' . $backup_data{$backup}{'backup_host'} . ' -u ' . $backup_data{$backup}{'backup_db_username'} . ' -p' . $backup_data{$backup}{'backup_db_password'}
                     . ' '   . $backup_data{$backup}{'backup_database'} . ' < ' . $backup_data{$backup}{'db_dump_path'} . 
$backup_data{$backup}{'db_dump_prefix'} . $datetime . '.sql';

     $system_message = `$command_line`;

     $mailbody .= "command line: $command_line\n\n";
     print STDOUT "command line: $command_line\n\n";

     $mailbody .= "testing dump of $backup_data{$backup}{'database'} (restore it to $backup_data{$backup}{'backup_database'} on $backup_data{$backup}{'backup_host'}) finished at $current_datetime: 
\n\n";
     print STDOUT "testing dump of $backup_data{$backup}{'database'} (restore it to $backup_data{$backup}{'backup_database'} on $backup_data{$backup}{'backup_host'}) finished at $current_datetime: 
\n\n";

     if ($system_message == 0) {
        $mailbody .= "NO ERRORS\n\n";
        print STDOUT "NO ERRORS\n\n";
     }
     else {
        $error_counter++;
        $mailbody .= "THERE WHERE ERRORS!\n\n";
        print STDOUT "THERE WHERE ERRORS!\n\n";
     }

     $mailbody .= "-------------------------------------------------------------------\n\n\n";
     print STDOUT "-------------------------------------------------------------------\n\n\n";
  }


  ###########################################################################################
  # send mail to admin
  if ($error_counter == 0) {
     $errors = 'no errors';
  }
  else {
     $errors = "$error_counter ERRORS! ";
  }

  # don't mail password: replace it by 'xxxxxx'
  $mailbody =~ s/$backup_data{$backup}{'db_password'}/xxxxxx/g;

  %mail_to_admin = ( From    => $backup_data{$backup}{'admin_mail'},
                     To      => $backup_data{$backup}{'admins_mail'},
                     Subject => "$errors - full dump and backup of $backup_data{$backup}{'database'} at $backup_data{0}{'host'}",
                     Message => $mailbody
                   );

  if (sendmail(%mail_to_admin)) {
     print STDOUT "mail to $backup_data{$backup}{'admins_mail'} sent successfully!\n\n";
  }
  else {
     print STDOUT "ERROR: could not send mail to $backup_data{$backup}{'admins_mail'}!\n\n";
  }
  #-------------------------------------------------------

}
# end of do_backup()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#  flush_bin_logs():                   flush the binary-logs
sub flush_bin_logs {
  my $backup = shift;
  my ($command_line, $command_line1, $system_message, $ls_l);
  my $mailbody = '';
  my $datetime = current_datetime();
  my $error_counter = 0;
  my ($errors);
  my %mail_to_admin = ();
  my $current_datetime = current_datetime();
  my $previous_log;

  ###########################################################################################
  # flush bin-log (echo "flush logs;" | mysql -u root -pxxxxx) and copy bin-log to NAS 
  $current_datetime = current_datetime();
  
  $mailbody .= "####################################################################\n"
               . "1) Flush bin-logs and copy bin-log to $backup_data{$backup}{'bin_log_backup_path'} at $current_datetime\n\n";

  print STDOUT "####################################################################\n"
               . "1) Flush bin-logs and copy bin-log to $backup_data{$backup}{'bin_log_backup_path'} at $current_datetime\n\n";

  # flush bin-log
  $command_line1 =  qq(echo "flush logs;") . ' | mysql -u ' . $backup_data{$backup}{'db_username'} . ' -p' . $backup_data{$backup}{'db_password'};
  $system_message = system($command_line1);
  
  # get the name of the previous log: "tail -2 /var/log/mysql/mysql-bin.index | head -n 1" (show the last but one entry)
  $command_line =  'tail -2 ' . $backup_data{$backup}{'bin_log_path'} . $backup_data{$backup}{'bin_log_index_file'} . ' | head -n 1';
  $previous_log = `$command_line`;
  chomp($previous_log);           # remove the newline

  # now copy the previous log to the backup dir
  $command_line =  'cp ' . $previous_log . ' ' . $backup_data{$backup}{'bin_log_backup_path'};
  $system_message = system($command_line);

  $mailbody .= "command line: $command_line1 ; $command_line\n\n";
  print STDOUT "command line: $command_line1 ; $command_line\n\n";

  $ls_l = `ls -l $backup_data{$backup}{'bin_log_backup_path'}`;

  $current_datetime = current_datetime();

  $mailbody .= "copy previous bin-log finished at $current_datetime: \n\n";
  print STDOUT "copy previous bin-log finished at $current_datetime: \n\n";

  if ($system_message == 0) {
     $mailbody .= "NO ERRORS\n\n";
     print STDOUT "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     print STDOUT "THERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "Listing of bin-log backup directory ($backup_data{$backup}{'bin_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";

  print STDOUT "Listing of bin-log backup directory ($backup_data{$backup}{'bin_log_backup_path'})\n"
               . $ls_l . "\n"
               . "-------------------------------------------------------------------\n\n";
	       
  ###########################################################################################
  # send mail to admin
  if ($error_counter == 0) {
     $errors = 'no errors';
  }
  else {
     $errors = "$error_counter ERRORS! ";
  }

  # don't mail password
  $mailbody =~ s/$backup_data{$backup}{'db_password'}/xxxxxx/g;

  %mail_to_admin = ( From    => $backup_data{$backup}{'admin_mail'},
                     To      => $backup_data{$backup}{'admins_mail'},
                     Subject => "$errors - flush and back up binary logs of $backup_data{$backup}{'database'} at $backup_data{0}{'host'}",
                     Message => $mailbody
                   );

  if (sendmail(%mail_to_admin)) {
     print STDOUT "mail to $backup_data{$backup}{'admins_mail'} sent successfully!\n\n";
  }
  else {
     print STDOUT "ERROR: could not send mail to $backup_data{$backup}{'admins_mail'}!\n\n";
  }
  #-------------------------------------------------------	       
}
# end of flush_bin_logs()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#  current_datetime():                    returns current time as: "2005_04_26-1214"
sub current_datetime {
  my ($sec, $min, $hour, $day, $month, $yyyyear) = (localtime)[0,1,2,3,4,5];
  my $datetime;

  # create sql datetime format: 2005-04-26 00:00:00
  $month++;                                      # start with january = 1, not 0
  if ($month < 10) { $month = '0' . $month; }
  if ($day   < 10) { $day   = '0' . $day;   }
  if ($hour  < 10) { $hour  = '0' . $hour;  }
  if ($min   < 10) { $min   = '0' . $min;   }
  if ($sec   < 10) { $sec   = '0' . $sec;   }

  $datetime = ($yyyyear + 1900) . '_' . $month . '_' . $day . '-' . $hour . '' . $min . '' . $sec;

  return ($datetime);
}
# end of current_datetime()
#-------------------------------------------------------------------------------



