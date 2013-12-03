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
my %todo;
my %done;

extract_log($_) for @file_list;
write_daily_log("/Users/mfc/Dropbox/Notes/daily-log.md");

sub extract_log {
    my $filename = shift;

    open my $log_fh, "<", $filename;
    while (<$log_fh>) {

        if ( /#todo/ ) {
            my ( $task, $project, $done_date ) = $_ =~
              /^\s*(.+)\s+#todo:?([^\s]+)(?:.+#done:?(\d{4}-?\d{2}-?\d{2}))?/;
            my @project_tree = split /:/, $project;
            # $todo{todo}{} =

            if ( defined $done_date ) {
                to_nested_hash(\%done, @project_tree, $done_date, $task);
            }
            else {
                to_nested_hash(\%todo, @project_tree, $task);
            }
        }

        next
          unless my ( $subject, $date, $hashtags ) =
          $_ =~ /^#+\s?(.+)\s#(\d{4}-?\d{2}-?\d{2})(.*)$/;

        my @keywords = $hashtags =~ /#([^\s#]+)/g;
        $date =~ s/-//g;

        push @{ $log{$date} },
          { filename => $filename, subject => $subject, keywords => \@keywords };
    }
    close $log_fh;
}

use Data::Printer;
p %todo;
p %done;

sub to_nested_hash {

    # Adapted from: http://stackoverflow.com/questions/11505100/ ...
    # perl-how-to-turn-array-into-nested-hash-keys
    my $ref   = \shift;
    my $h     = $$ref;
    my $value = pop;
    $ref      = \$$ref->{ $_ } foreach @_;
    push @{$$ref}, $value;
    return $h;
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

            say $out_fh "- [$subject](file://$filename) @keywords";
        }
        say $out_fh "";
    }
    close $out_fh;
}
