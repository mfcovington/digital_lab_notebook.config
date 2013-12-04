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
write_todo_log("/Users/mfc/Dropbox/Notes/todo-log.md");

sub extract_log {
    my $filename = shift;

    open my $log_fh, "<", $filename;
    while (<$log_fh>) {
        $filename =~ s/\s/%20/g;

        extract_todo( $_, $filename ) if (/#todo/);

        next
          unless my ( $subject, $date, $hashtags ) =
          $_ =~ /^#+\s?(.+)\s#(\d{4}-?\d{2}-?\d{2})(.*)$/;

        my @keywords = $hashtags =~ /#([^\s#]+)/g;
        $date =~ s/-//g;

        push @{ $log{$date} },
          {
            filename => $filename,
            subject  => $subject,
            keywords => \@keywords
          };
    }
    close $log_fh;
}

sub extract_todo {
    my ( $line, $filename ) = @_;

    my ( $task, $project_info, $done_date ) =
      $line =~ /^\s*(.+)\s+#todo:?([^\s]*)(?:.+#done:?(\d{4}-?\d{2}-?\d{2}))?/;
    my ( $project, $subproject ) = split /:/, $project_info, 2;
    $project ||= ".na";
    $subproject //= ".na";

    if ( defined $done_date ) {
        push @{ $done{$project}{$subproject}{$done_date} },
          [ $task, $filename ];
    }
    else {
        push @{ $todo{$project}{$subproject} }, [ $task, $filename ];
    }
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
        for my $record ( @{ $log{$date} } ) {

            my $filename = $$record{filename};
            my $subject  = $$record{subject};
            my @keywords = @{ $$record{keywords} };

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

sub write_todo_log {
    my $outfile = shift;

    open my $out_fh, ">", $outfile;

    say $out_fh "# TODO LIST\n";

    for my $project ( sort keys %todo ) {
        my $header = format_header($project);

        say $out_fh "## $header\n" unless $project eq ".na";

        for my $subproject ( sort keys $todo{$project} ) {
            my $subheader = format_header($subproject);

            say $out_fh "### $subheader\n" unless $subproject eq ".na";
            say $out_fh "- [$$_[0]](file://$$_[1])"
              for @{ $todo{$project}{$subproject} };
            say $out_fh "";
        }
    }

    say $out_fh "# COMPLETED\n";

    for my $project ( sort keys %done ) {
        my $header = format_header($project);

        say $out_fh "## $header\n" unless $project eq ".na";

        for my $subproject ( sort keys $done{$project} ) {
            my $subheader = format_header($subproject);

            say $out_fh "### $subheader\n" unless $subproject eq ".na";

            for my $done_date ( sort keys $done{$project}{$subproject} ) {
                say $out_fh "- $done_date";
                say $out_fh "    - [$$_[0]](file://$$_[1])"
                  for @{ $done{$project}{$subproject}{$done_date} };
                say $out_fh "";
            }

        }
    }

    close $out_fh;
}

sub format_header {
    my $header = shift;
    $header =~ s/-/ /g;
    $header =~ tr/a-z/A-Z/;
    return $header;
}
