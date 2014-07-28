use strict;
if(m/href.*\'(.*)\'.*>(.*)</){
   my $file=$1;
   my $title=$2;
   print qq(title=$2, file=$1\n);
}

