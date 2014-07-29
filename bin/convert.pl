use strict;
use warnings;
use HTML::TableExtract;
use Data::Dumper;
my %db;
my %timemap=(
   'TimeSwim'=>'itime1',
   'TimeT1'=>'itime2',
   'TimeCyclingLap1'=>'itime4',
   'TimeCyclingLap2'=>'itime6',
   'TimeCyclingLap3'=>'itime8',
   'TimeCycling'=>'itime10',
   'TimeT2'=>'itime11',
   'TimeRunLap1'=>'itime13',
   'TimeRunLap2'=>'itime16',
   'TimeRunLap3'=>'itime19',
   'TimeRun'=>'finish',
);

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub time2sec{
   my $timestr=shift;
   return 0 if (!defined $timestr);
   if($timestr=~m!(.*?):(.*?):(.*)!){
      my $sec=$1*3600+$2*60+$3;
   }
   elsif($timestr=~m!(.*?):(.*)!){
      my $sec=$1*60+$2;
   }
}

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub sec2time{
   my $sec=shift;
   my ($h,$m,$s);
   {
      use integer;
      $h=$sec/3600;
      $m=($sec-$h*3600)/60;
   }
   $s=$sec-$h*3600-$m*60;
   sprintf "%02d:%02d:%04.1f",$h,$m,$s;
}

#------------------------------------------------------------------------
my $classfile="gen/class-list.txt";
open CLASS,"<$classfile" or die "canot open $classfile";
while(<CLASS>){
   chomp;
   my $class=$_;
   my $startlistfile="data/${class}startlist.htm";
   print "parsing $startlistfile\n";
   my $te = HTML::TableExtract->new( depth => 0);
   $te->parse_file($startlistfile);
   for my $ts ($te->tables) {
      #print "Table found at ", join(',', $ts->coords), ":\n";
      for my $row ($ts->rows) {
         next if (@$row[0]=~m/Start/);
         #print join(',', @$row), "\n";
         #print "$$row[0],$$row[1],$$row[2],$class\n";
         my $nr=$$row[0];
         $nr=~s/\s*//;
         my $name=$$row[1];
         my $club=$$row[2];
         #print "nr=$nr, name=$name\n";
         $db{$nr}{Name}=$name;
         $db{$nr}{Club}=$club;
         $db{$nr}{Class}=$class;
      }

   }

   #---------------------------------------------------------------------
   for my $timefield(keys %timemap){
      my $timefile="data/${class}$timemap{$timefield}.htm";
      print "parsing $timefile\n";
      my $t = HTML::TableExtract->new( depth => 0);
      $t->parse_file($timefile);
      #print Dumper($te);
      for my $ts ($t->tables) {
         for my $row ($ts->rows) {
            next if(! defined $$row[2]);
            my $nr=$$row[2];
            $nr=~s/\s*//; #lose leading spaces
            next if (not $nr=~m/^\d+/);
            next if(! defined $$row[4]);
            $db{$nr}{$timefield}=sec2time(time2sec($$row[4]));
            #print "$nr, $db{$nr}{$timefield}\n";
         }
      }
   }
}
#------------------------------------------------------------------------
close CLASS;

#------------------------------------------------------------------------
#calculate some time used 
for my $nr(keys %db){
   if(defined $db{$nr}{TimeSwim}){
      $db{$nr}{TimeUsedSwim}=sec2time(time2sec($db{$nr}{TimeSwim}));
      $db{$nr}{TimeUsedT1}=sec2time(time2sec($db{$nr}{TimeT1})-time2sec($db{$nr}{TimeSwim}));
      $db{$nr}{TimeUsedCycling}=sec2time(time2sec($db{$nr}{TimeCycling})-time2sec($db{$nr}{TimeT1}));
      $db{$nr}{TimeUsedCycling1half}=sec2time(time2sec($db{$nr}{TimeCyclingLap2})-time2sec($db{$nr}{TimeT1}));
      $db{$nr}{TimeUsedCycling2half}=sec2time(time2sec($db{$nr}{TimeCycling})-time2sec($db{$nr}{TimeCyclingLap2}));
      $db{$nr}{TimeUsedT2}=sec2time(time2sec($db{$nr}{TimeT2})-time2sec($db{$nr}{TimeCycling}));
      $db{$nr}{TimeUsedRun1half}=sec2time(time2sec($db{$nr}{TimeRunLap2})-time2sec($db{$nr}{TimeT2}));
      $db{$nr}{TimeUsedRun2half}=sec2time(time2sec($db{$nr}{TimeRun})-time2sec($db{$nr}{TimeRunLap2}));
      $db{$nr}{TimeUsedRun}=sec2time(time2sec($db{$nr}{TimeRun})-time2sec($db{$nr}{TimeT2}));
   }
}

print Dumper(%db);

#------------------------------------------------------------------------
my $outfile="gen/vc2014-result.html";
open OUT,">$outfile" or die "cannot create $outfile";
print OUT<<EOT
<html>
<head>
<style type="text/css">
body
{
   background-color: white;
   #font-family: Verdana, Arial, Sans-Serif;
   #font-family: 'Lucida Sans Unicode', 'Lucida Grande', sans-serif;
   font-family: 'Trebuchet MS', Helvetica, sans-serif;
   #font-size: 90%;
}
</style>
</head>
<body>
EOT
;
print OUT<<EOT
<h1>V�tter Challenge 2014 results</h1>
<h2>Contents</h2>
<ul>
<li><a href="#intro">Introduction</a></li>
<li><a href="#detail">Details for each competitor</a></li>
</ul>
EOT
;

#------------------------------------------------------------------------
print qq(<a name="#detail"></a>\n<h2>Details for each competitor</h2>\n);
for my $nr(sort{ $a <=> $b } keys %db){
   print OUT<<EOT
<hr>
<table>
<tr><td>Bib number:</td><td>$nr</td></tr>
<tr><td>Name:</td><td>$db{$nr}{Name}</td></tr>
<tr><td>Club:</td><td>$db{$nr}{Club}</td></tr>
<tr><td>Class:</td><td>$db{$nr}{Class}</td></tr>
<tr><td>Swim:</td><td>$db{$nr}{TimeUsedSwim}</td></tr>
<tr><td>T1:</td><td>$db{$nr}{TimeUsedT1}</td></tr>
<tr><td>Cycling:</td><td>$db{$nr}{TimeUsedCycling}</td></tr>
<tr><td>T2:</td><td>$db{$nr}{TimeUsedT2}</td></tr>
<tr><td>Run:</td><td>$db{$nr}{TimeUsedRun}</td></tr>
<tr><td>Total time:</td><td>$db{$nr}{TimeRun}</td></tr>
</table>
EOT
;
}

#------------------------------------------------------------------------
print OUT "</body>\n<html>\n";
close OUT;