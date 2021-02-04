#!/bin/bash
function Extract_First_Line(){
	#People=$(cat mymatrix.txt | head -n 1)
	People=$(head -n 1 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g')
	IFS=','
	read -a strarraypeople<<< $People
        for person in ${strarraypeople[@]}; do
		echo create\(n:Person {name:\"$person\"}\)\;
        	#echo $person
        done
}

function Extract_Words(){
	Words=$(tail -n +2 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g' | cut -d',' -f1)
	echo $Words | awk '{for (i=1; i<=NF; ++i)printf "%s%s", $i, i % 2? " ": "\n"}i % 2{print ""}' > words.txt
	input="words.txt"
	while IFS= read -r line
	do
	   [[ "$line" != "" ]] && echo create\(n:n_gram {name:\"$line\"}\)\;
	done < "$input"
}

function Display_Main_Menu(){
	CYAN='\033[0;36m'
	NC='\033[0m'
	clear
	echo -e "${CYAN}1) Print out File Results${NC}"
	echo -e "${CYAN}2) Extract First Line from File${NC}"
	echo -e "${CYAN}3) Extract Words${NC}"
	read -p "Choose an option (Note only enter in integer value):" chosenoption
	echo "You chose option $chosenoption"
	re='^[0-9]+$'
	if ! [[ $chosenoption =~ $re ]] ; then
	   echo "error: Not a number" >&2; exit 1
	fi

	case $chosenoption in
		"1") clear && cat mymatrix.txt;;
		"2") clear && Extract_First_Line;;
		"3") clear && Extract_Words;;
	esac
}
#RunSootOnAllAPKSInFolder
Display_Main_Menu

