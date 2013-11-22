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

my %log;
my $filename = "_log ~ Brassica mapping- unscramble bwa+tophat-mapped R500+IMB211 samples ~ 20131121.md";

while (<DATA>) {
    next
      unless my ( $subject, $date, $hashtags ) =
      $_ =~ /^\#\s?(.+)\s\#(\d{4}-?\d{2}-?\d{2})(.*)$/g;

    my @keywords = $hashtags =~ /#([^\s#]+)/g;
    $date =~ s/-//g;

    push @{ $log{$date} },
      { filename => $filename, subject => $subject, keywords => \@keywords };
}   

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

__DATA__

# Unscramble misnamed parental BAM files #2013-11-21 #brassica

## Upendra's 'version1' files

    # Atmosphere
    mkdir -p /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams
    cd /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams

    icd /iplant/home/shared/ucd.plantbio/maloof.lab/members/upendra/Parents_mapping/mapping_v1/

    for PAR in 1 2; do
        for REP in 0{1..9} 1{0..6}; do
            iget -vT parent_$PAR.$REP/merged/bwa_tophat_parent_$PAR.$REP-Brapa0830.sorted.dupl_rm.xt_a_u_q20.bam
            echo $PAR-$REP
            samtools index bwa_tophat_parent_$PAR.$REP-Brapa0830.sorted.dupl_rm.xt_a_u_q20.bam
        done
    done

Some samples have truncated BAM files

## Upendra's 'version2' files

    mkdir /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams/v2
    cd /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams/v2
    icd /iplant/home/shared/ucd.plantbio/maloof.lab/members/upendra/Parents_mapping/mapping_v2/

    for PAR in 1 2; do
        for REP in 0{1..9} 1{0..6}; do
            echo $PAR-$REP
            iget -vT parent_$PAR.$REP/merged/bwa_tophat_parent_$PAR.$REP-Brapa_sequence_v1.2.sorted.dupl_rm.xt_a_u_q20.bam
            samtools index bwa_tophat_parent_$PAR.$REP-Brapa_sequence_v1.2.sorted.dupl_rm.xt_a_u_q20.bam
        done
    done

Some samples don't have merged bam files.

Versions 1 and 2 are different from each other, even though Upendra indicated that they are the same.

## Looking at mpileup to distinguish genotypes

    REF=/bigdata/brassica/fa/B.rapa_genome_sequence_0830.fa

    cd /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams
    POS=3000234; PAR=1; for REP in 0{1..9} 1{0..6}; do echo $PAR-$REP; samtools mpileup -f $REF -r A01:$POS-$POS bwa_tophat_parent_$PAR.$REP-Brapa0830.sorted.dupl_rm.xt_a_u_q20.bam; done

    cd /bigdata/brassica/unscramble-bwa+tophat-parents/individual-bams/v2
    POS=3000234; PAR=1; for REP in 0{1..9} 1{0..6}; do echo $PAR-$REP; samtools mpileup -f $REF -r A01:$POS-$POS bwa_tophat_parent_$PAR.$REP-Brapa_sequence_v1.2.sorted.dupl_rm.xt_a_u_q20.bam; done

These looked scrambled.

## CONCLUSION

These files are, themselves, scrambled! Talked to Upendra and pointed him to the files he originally gave me for SNP calling (`/iplant/home/shared/ucd.plantbio/maloof.lab/members/upendra/bam_SNP/merged_bam_noRG_SNP/`). He told me that he doesn't know why he gave me those files since they weren't meant for SNP calling. Rather, he used them while messing with GATK. Upendra will map the individual libraries according to my mapping pipeline. He will use FQ files that have uncorrected names and I will rename them (based on approach from [[_log • Upendra- SNP identification from corrected parents • 20121204]]).

# Unscramble misnamed FQ files for Upendra to map #2013-11-21 #brassica1 f #brassica2 #sdf #mid#mid
# Unscramble misnamed FQ files for #sdfsdf Upendra to map pt2 #2013-11-21
# Unscramble misnamed FQ files for #sdfsdf Upendra to map pt3 #20131101

Asked Upendra to send me path to misnamed (but otherwise good) parental FQ files from individual libraries. I'll arrange (and rename) them for Upendra to use in mapping.



