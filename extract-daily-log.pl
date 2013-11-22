#!/usr/bin/env perl
# Mike Covington
# created: 2013-11-21
#
# Description:
#
use strict;
use warnings;
use autodie;
use feature 'say';

#TODO: Read through each file in '/Users/mfc/Dropbox/Notes/' (ignore '_log.Daily.AutoLog.md')
#TODO: Write log to '/Users/mfc/Dropbox/Notes/_log.Daily.AutoLog.md'

my @file_list = @ARGV;
my %log;

extract_log($_) for @file_list;

my %month_name = (
    '01' => 'Jan',
    '02' => 'Feb',
    '03' => 'Mar',
    '04' => 'Apr',
    '05' => 'May',
    '06' => 'Jun',
    '07' => 'Jul',
    '08' => 'Aug',
    '09' => 'Sep',
    '10' => 'Oct',
    '11' => 'Nov',
    '12' => 'Dec'
);

for my $date ( sort { $b <=> $a } keys %log ) {

    my ( $year, $month, $day ) = $date =~ /(\d{4})(\d{2})(\d{2})/;

    say "$month_name{$month}. $day, $year\n";
    for my $record ( @{$log{$date}} ) {

        my $filename = $$record{filename};
        my $subject  = $$record{subject};
        my @keywords = @{ $$record{keywords} };

        $filename =~ s/\s/%20/g;

        for (@keywords) {
            s/(.*)/**$1**/;
            tr/a-z/A-Z/;
        }

        say "- [$subject](file:///Users/mfc/Dropbox/Notes/$filename) @keywords";
    }
    say "";
}

sub extract_log {
    my $filename = shift;

    open my $log_fh, "<", $filename;
    while (<$log_fh>) {
        next
          unless my ( $subject, $date, $hashtags ) =
          $_ =~ /^\#\s?(.+)\s\#(\d{4}-?\d{2}-?\d{2})(.*)$/g;

        my @keywords = $hashtags =~ /#([^\s#]+)/g;
        $date =~ s/-//g;

        push @{ $log{$date} },
          { filename => $filename, subject => $subject, keywords => \@keywords };
    }   
    close $log_fh;
}
