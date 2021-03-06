#!/bin/bash

path=$([ -z $1 ] && echo "books*" || echo $1)
#find $path -iname "*txt" -delete
for b in $(ls $path -d)
do
	echo Processando $b
	cd $b
	
	echo Convertendo rtf para txt
	for i in $(ls nwt_??_*rtf) 
	do 
		file="`echo $i | cut -d. -f1`.txt"
		if [ ! -f "$file" ] 
		then
			echo -ne "$file                       \r"
			sed -i 's/\\u160?/ /g' $i
			unoconv -f txt $i 
		fi
	done
	echo -ne "Ok                                               \r"

	chapterword=$(tail +3 nwt_01_*.txt | head -1 | cut -d" " -f1)
	echo Removendo $chapterword
	rm -f biblia.txt
	for i in $(ls nwt_??_*txt)
	do
		echo -ne "$i                                  \r"
		sed '/^.\+)$/d' $i > temp
		sed "/$chapterword/d" temp > temp1
		#tail +1 $i > temp
		#mv temp $i
		cat temp1 >> biblia.txt
	done
	
	rm -f temp*
	
	echo Separando as palavras...
	cat biblia.txt | sed '/^.\+)$/d' | sed "/$chapterword/d" | sed 's/\([[:alpha:]]\)\-/\1_/g' | sed 's/’s//g' | sed 's/—/ /g' | sed 's/[^a-zA-Z_ ʹ]//g' | tr ' ' '\n' | sort > palavras.txt
	sed -i '/^$/d' palavras.txt
	sed -i 's/_/\-/g' palavras.txt
	rm -f diferentes.txt
	word="_" #$(head -1 palavras.txt)
	count=0
	echo -ne "$word: \r"
	for w in $(cat palavras.txt)
	do
		if [ "x${w^^}" = "x${word^^}" ] 
		then
			((count=count+1))
		else
			[ $count -gt 0 ] && echo "$count,$word" >> diferentes.txt
			count=1
			word=$w
			#echo 
		fi
		echo -ne "$w: $count                                        \r"
	done
	
	echo "$count,$word" >> diferentes.txt
	
	cat diferentes.txt | sort -n > temp
	mv temp diferentes.txt
	rm -f temp
	
	cd ..
done
