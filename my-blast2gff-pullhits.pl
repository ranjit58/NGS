#!/usr/bin/perl
#usage perl program.pl input>output
open(IN,"<$ARGV[0]") || die "file not found $ARGV[0]";
while (<IN>)
{
        chomp $_;
        my $line =$_;
        @arr=split ("\t",$line);

        $query = $arr[0];
        $subject = $arr[1];
        $identity = $arr[2];
        $align_length = $arr[3];
        $mismatch = $arr[4];
        $gaps = $arr[5];
        $q_start = $arr[6];
        $q_end = $arr[7];
        $sub_start = $arr[8];
        $sub_end = $arr[9];
        $e_value = $arr[10];
        $bit_score = $arr[11];

        if($sub_start < $sub_end)
        {
        #print "$query\tblast2gff\tblastfrag\t$sub_start\t$sub_end\t$e_value\/$bit_score\t+\t.\t$query\n";
        print "Q\tblast2gff\tblastfrag\t$sub_start\t$sub_end\t$e_value\/$bit_score\t+\t.\t$query\n";

        }
        else
        {
        #print "$query\tblast2gff\tblastfrag\t$sub_end\t$sub_start\t$e_value\/$bit_score\t-\t.\t$query\n";
        print "Q\tblast2gff\tblastfrag\t$sub_end\t$sub_start\t$e_value\/$bit_score\t-\t.\t$query\n";

        }
}

