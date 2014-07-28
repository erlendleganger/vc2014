for f in $(sed "s/.*file=//" <data/file-list.txt); do
   echo wget http://www.emitlive.se/140726/$f -O data/$f
done
