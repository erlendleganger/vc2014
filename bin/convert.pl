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
my $ztime="0:00:00.0";

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub timediff{
   my ($t0,$t1)=@_;
   return sec2time(time2sec($t0)-time2sec($t1));
}

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub timesum{
   my ($t0,$t1)=@_;
   return sec2time(time2sec($t0)+time2sec($t1));
}

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub time2sec{
   my $timestr=shift;
   my $sign=1;
   my $sec;
   return 0 if (!defined $timestr);
   $sign=-1 if($timestr=~m/^\s*\-/);
   if($timestr=~m!(\d+):(\d+):([\.\d]+)!){
      $sec=$1*3600+$2*60+$3;
   }
   elsif($timestr=~m!(\d+):([\.\d]+)!){
      $sec=$1*60+$2;
   }
   $sec=$sign*$sec;
}

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub sec2time{
   my $sec=shift;
   my $sign="";
   if($sec<0){
      $sec=-$sec;
      $sign="-";
   }
   my ($h,$m,$s);
   {
      use integer;
      $h=$sec/3600;
      $m=($sec-$h*3600)/60;
   }
   $s=$sec-$h*3600-$m*60;
   sprintf "$sign%d:%02d:%04.1f",$h,$m,$s;
}

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub sec2timeMMSS{
   my $sec=shift;
   my $sign="";
   if($sec<0){
      $sec=-$sec;
      $sign="-";
   }
   my ($h,$m,$s);
   {
      use integer;
      $h=$sec/3600;
      $m=($sec-$h*3600)/60;
      $s=$sec-$h*3600-$m*60;
   }
   sprintf "$sign%d:%02d",$m,$s;
}

#------------------------------------------------------------------------
#main code here
my $testmode;
#$testmode="1";
if($testmode){
   my ($t0,$t1,$t2);

   #---------------------------------------------------------------------
   $t0='1:2';
   $t1=sec2time(time2sec($t0));
   if($t1 eq "0:01:02.0"){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='1:2:3';
   $t1=sec2time(time2sec($t0));
   if($t1 eq "1:02:03.0"){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='1:2:3';
   $t1=sec2timeMMSS(time2sec($t0));
   if($t1 eq "2:03"){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='-1:2:3';
   $t1=time2sec($t0);
   if($t1 < 0){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='-1:2:3';
   $t1=sec2time(time2sec($t0));
   if($t1 eq "-1:02:03.0"){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='-2:3';
   $t1=sec2time(time2sec($t0));
   if($t1 eq "-0:02:03.0"){
      print "$t0 converted to $t1 - ok\n";
   }
   else{
      die "$t0 converted to $t1 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='2:3:4';
   $t1='1:2:3';
   $t2=timesum($t0,$t1);
   if($t2 eq "3:05:07.0"){
      print "$t0 plus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 plus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   for $t1('0:1','0:0:1','0:0:1.0'){
      $t0='1:59:59';
      $t2=timesum($t0,$t1);
      if($t2 eq "2:00:00.0"){
         print "$t0 plus $t1 = $t2 - ok\n";
      }
      else{
         die "$t0 plus $t1 = $t2 - error\n";
      }
   }

   #---------------------------------------------------------------------
   $t0='2:3:4';
   $t1='1:2:3';
   $t2=timediff($t0,$t1);
   if($t2 eq "1:01:01.0"){
      print "$t0 minus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 minus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='1:2:3';
   $t1='2:3:4';
   $t2=timediff($t0,$t1);
   if($t2 eq "-1:01:01.0"){
      print "$t0 minus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 minus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='1:2:3';
   $t1='1:2:3';
   $t2=timediff($t0,$t1);
   if($t2 eq "0:00:00.0"){
      print "$t0 minus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 minus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='0:0.1';
   $t1='0:0.2';
   $t2=timediff($t0,$t1);
   if($t2 eq "-0:00:00.1"){
      print "$t0 minus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 minus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   $t0='0:0.2';
   $t1='0:0.1';
   $t2=timediff($t0,$t1);
   if($t2 eq "0:00:00.1"){
      print "$t0 minus $t1 = $t2 - ok\n";
   }
   else{
      die "$t0 minus $t1 = $t2 - error\n";
   }

   #---------------------------------------------------------------------
   #premature exit, for testmode only
   exit 0;
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
         $db{$nr}{Sex}='Female';
         $db{$nr}{Sex}='Male' if($class=~m/Herrar/);
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
#calculate some times used 
for my $nr(keys %db){
   $db{$nr}{TimeUsedSwim}=sec2time(time2sec($db{$nr}{TimeSwim}));
   $db{$nr}{TimeUsedT1}=timediff($db{$nr}{TimeT1},$db{$nr}{TimeSwim});
   $db{$nr}{TimeUsedCycling}=timediff($db{$nr}{TimeCycling},$db{$nr}{TimeT1});
   $db{$nr}{TimeUsedCycling1half}=timediff($db{$nr}{TimeCyclingLap2},$db{$nr}{TimeT1});
   $db{$nr}{TimeUsedCycling2half}=timediff($db{$nr}{TimeCycling},$db{$nr}{TimeCyclingLap2});
   $db{$nr}{TimeUsedT2}=timediff($db{$nr}{TimeT2},$db{$nr}{TimeCycling});
   $db{$nr}{TimeUsedRun1half}=timediff($db{$nr}{TimeRunLap2},$db{$nr}{TimeT2});
   $db{$nr}{TimeUsedRun2half}=timediff($db{$nr}{TimeRun},$db{$nr}{TimeRunLap2});
   $db{$nr}{TimeUsedRun}=timediff($db{$nr}{TimeRun},$db{$nr}{TimeT2});
   for my $name(qw(TimeUsedSwim TimeUsedT1 TimeUsedCycling TimeUsedCycling1half TimeUsedCycling2half TimeUsedT2 TimeUsedRun1half TimeUsedRun2half TimeUsedRun)){
      my $time=$db{$nr}{$name};
      undef $db{$nr}{$name} if($time=~m/^\-/ or $time eq $ztime);
   }
}

#------------------------------------------------------------------------
my %nrlist=();
my $nrcount=0;
my $rank=0;

#------------------------------------------------------------------------
#calculate rankings
for my $name(qw(UsedSwim UsedT1 T1 UsedCycling Cycling UsedT2 T2 UsedRun Run)){
   %nrlist=();
   for my $nr(keys %db){
      if(defined $db{$nr}{"Time$name"} and $db{$nr}{"Time$name"} ne $ztime){
         push @{$nrlist{overall}},$nr;
         push @{$nrlist{$db{$nr}{Sex}}},$nr;
         push @{$nrlist{$db{$nr}{Class}}},$nr;
      }
   }
   for my $key(keys %nrlist){
      #$metadb{$key}{$name}{count}=1+$#{$nrlist{$key}};
      my $count=1+$#{$nrlist{$key}};
      $rank=0;
      for my $nr(sort{$db{$a}{"Time$name"}cmp$db{$b}{"Time$name"}} @{$nrlist{$key}}){
         $rank++;
         my $pctbeaten=sprintf "%3.0f",100.0*$rank/$count;
         $db{$nr}{"Rank$name"}{$key}="$rank/$count ($pctbeaten%)";
      }
   }
}

#------------------------------------------------------------------------
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
table {
border-collapse: collapse;
}

td, th {
border: 1px solid black;
padding: 3px;
}
</style>
</head>
<body>
EOT
;
print OUT<<EOT
<h1>Vätter Challenge 2014 results</h1>
<h2>Contents</h2>
<ul>
<li><a href="#intro">Introduction</a></li>
<li><a href="#detail">Details for each competitor</a></li>
</ul>
EOT
;

#------------------------------------------------------------------------
print OUT qq(<a name="#detail"></a>\n<h2>Details for each competitor</h2>\n);
for my $nr(sort{ $a <=> $b } keys %db){
   no warnings;
   print OUT<<EOT
<hr>
<table>
<tr><td>Bib number:</td><td>$nr</td></tr>
<tr><td>Name:</td><td>$db{$nr}{Name}</td></tr>
<tr><td>Club:</td><td>$db{$nr}{Club}</td></tr>
<tr><td>Sex:</td><td>$db{$nr}{Sex}</td></tr>
<tr><td>Class:</td><td>$db{$nr}{Class}</td></tr>
</table>
&nbsp;
<table>
<tr><td>Text</td><td>Time</td><td>Overall</td><td>$db{$nr}{Sex}s</td><td>Class</td></tr>
<tr><td>Swim:</td><td>$db{$nr}{TimeUsedSwim}</td><td>$db{$nr}{RankUsedSwim}{overall}</td><td>$db{$nr}{RankUsedSwim}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankUsedSwim}{$db{$nr}{Class}}</td></tr>
<tr><td>T1:</td><td>$db{$nr}{TimeUsedT1}</td><td>$db{$nr}{RankUsedT1}{overall}</td><td>$db{$nr}{RankUsedT1}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankUsedT1}{$db{$nr}{Class}}</td></tr>
<tr><td>Total after T1:</td><td>$db{$nr}{TimeT1}</td><td>$db{$nr}{RankT1}{overall}</td><td>$db{$nr}{RankT1}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankT1}{$db{$nr}{Class}}</td></tr>
<tr><td>Cycling:</td><td>$db{$nr}{TimeUsedCycling}</td><td>$db{$nr}{RankUsedCycling}{overall}</td><td>$db{$nr}{RankUsedCycling}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankUsedCycling}{$db{$nr}{Class}}</td></tr>
<tr><td>Total after Cycling:</td><td>$db{$nr}{TimeCycling}</td><td>$db{$nr}{RankCycling}{overall}</td><td>$db{$nr}{RankCycling}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankCycling}{$db{$nr}{Class}}</td></tr>
<tr><td>T2:</td><td>$db{$nr}{TimeUsedT2}</td><td>$db{$nr}{RankUsedT2}{overall}</td><td>$db{$nr}{RankUsedT2}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankUsedT2}{$db{$nr}{Class}}</td></tr>
<tr><td>Total after T2:</td><td>$db{$nr}{TimeT2}</td><td>$db{$nr}{RankT2}{overall}</td><td>$db{$nr}{RankT2}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankT2}{$db{$nr}{Class}}</td></tr>
<tr><td>Run:</td><td>$db{$nr}{TimeUsedRun}</td><td>$db{$nr}{RankUsedRun}{overall}</td><td>$db{$nr}{RankUsedRun}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankUsedRun}{$db{$nr}{Class}}</td></tr>
<tr><td>Total after Run:</td><td>$db{$nr}{TimeRun}</td><td>$db{$nr}{RankRun}{overall}</td><td>$db{$nr}{RankRun}{$db{$nr}{Sex}}</td><td>$db{$nr}{RankRun}{$db{$nr}{Class}}</td></tr>
</table>
EOT
;
}

#------------------------------------------------------------------------
print OUT "</body>\n<html>\n";
close OUT;
