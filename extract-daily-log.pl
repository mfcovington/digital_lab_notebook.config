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

my @file_list = @ARGV;
my %log;

extract_log($_) for @file_list;
write_daily_log("/Users/mfc/Dropbox/Notes/daily-log.md");

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

sub write_daily_log {
    my $outfile = shift;

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

    open my $out_fh, ">", $outfile;
    for my $date ( sort { $b <=> $a } keys %log ) {

        my ( $year, $month, $day ) = $date =~ /(\d{4})(\d{2})(\d{2})/;

        say $out_fh "$month_name{$month}. $day, $year\n";
        for my $record ( @{$log{$date}} ) {

            my $filename = $$record{filename};
            my $subject  = $$record{subject};
            my @keywords = @{ $$record{keywords} };

            $filename =~ s/\s/%20/g;

            for (@keywords) {
                s/(.*)/**$1**/;
                tr/a-z/A-Z/;
            }

            say $out_fh "- [$subject](file:///Users/mfc/Dropbox/Notes/$filename) @keywords";
        }
        say $out_fh "";
    }
    close $out_fh;
}
