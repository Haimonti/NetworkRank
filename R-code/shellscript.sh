#!/bin/bash
function Extract_First_Line(){
	#People=$(cat mymatrix.txt | head -n 1)
	People=$(head -n 1 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g')
	IFS=','
	read -a strarraypeople<<< $People
        for person in ${strarraypeople[@]}; do
		echo create\(n:Person {name:\"$person\"}\)\;
        	#echo $person
        done>People.txt
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

function Return_Person_At_Position(){
	Position=$1
	Counter=0
	People=$(head -n 1 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g')
	IFS=','
	read -a strarraypeople<<< $People
        for person in ${strarraypeople[@]}; do
		((Counter=Counter+1))
        	[[ $Position == $Counter ]] && PersonOfInterest=$person
        done
	echo $PersonOfInterest
}

function Return_ngram_At_Position(){
	Position=$1
	Counter=0
	Words=$(tail -n +2 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g' | cut -d',' -f1)
	echo $Words | awk '{for (i=1; i<=NF; ++i)printf "%s%s", $i, i % 2? " ": "\n"}i % 2{print ""}' > words.txt
	input="words.txt"
	while IFS= read -r line
	do
		((Counter=Counter+1))
	   [[ "$line" != "" && $Counter == $Position ]] && echo $line
	done < "$input"
	echo $NGramOfInterest
}

function Extract_Relationships(){
	RowCounter=0
	Words=$(tail -n +2 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g' )
	echo $Words | awk '{gsub("[a-z]","\n");gsub(",","");print}' | awk '{$1=$1;print}' > RelationshipScores.txt
	input="RelationshipScores.txt"
	
	while IFS= read -r line
	do
	   if [[ "$line" != "" ]]; then 
		   #for i in $(seq 1 $(cat People.txt | wc -l)); do Return_Person_At_Position $i; done
		   Values=()
		   ((RowCounter=RowCounter+1))
		   echo Row $RowCounter: "$line" 
		   for val in $line; do
			   Values+=($val)
		   done
		   #for i in $(seq 1 $(cat People.txt | wc -l)); do Return_Person_At_Position $i; done
		   #Return_ngram_At_Position $RowCounter
		   echo ${Values[@]}
	   fi
	done < "$input" > RelationshipScores2.txt
	mv RelationshipScores2.txt RelationshipScores.txt
	cat RelationshipScores.txt
	#For every row extract each value for each word and assign to person at position
}
function Display_Main_Menu(){
	CYAN='\033[0;36m'
	NC='\033[0m'
	clear
	echo -e "${CYAN}1) Print out File Results${NC}"
	echo -e "${CYAN}2) Extract First Line from File${NC}"
	echo -e "${CYAN}3) Extract Words${NC}"
	echo -e "${CYAN}4) Extract Relationships${NC}"
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
		"4") clear && Extract_Relationships;;
		"5") clear && Return_ngram_At_Position 1;;
	esac
}
Display_Main_Menu

