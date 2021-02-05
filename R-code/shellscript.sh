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
	echo -e Wrote to People.txt
}

function Extract_Words(){
	Words=$(tail -n +2 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g' | cut -d',' -f1)
	echo $Words | awk '{for (i=1; i<=NF; ++i)printf "%s%s", $i, i % 2? " ": "\n"}i % 2{print ""}' > words.txt
	input="words.txt"
	while IFS= read -r line
	do
	   [[ "$line" != "" ]] && echo create\(n:n_gram {name:\"$line\"}\)\;
	done < "$input" >Words.txt
	echo -e Wrote to file Words.txt
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
	#echo $PersonOfInterest
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
	   [[ "$line" != "" && $Counter == $Position ]] && echo $line >> NgramOfInterest.txt
	done < "$input"
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
		   echo "$line" 
		   #for i in $(seq 1 $(cat People.txt | wc -l)); do Return_Person_At_Position $i; done
		   #Return_ngram_At_Position $RowCounter
		   #echo ${Values[@]}
	   fi
	done < "$input" > RelationshipScores2.txt
	mv RelationshipScores2.txt RelationshipScores.txt
	#cat RelationshipScores.txt
	#For every row extract each value for each word and assign to person at position
	input="RelationshipScores.txt"
	RowCounter=0
	while IFS= read -r line
	do
		((RowCounter=RowCounter+1))
		echo "$line"
		Return_ngram_At_Position $RowCounter
		tail -n 1 NgramOfInterest.txt
	done < "$input"
}

function Return_Num_Rows_And_Columns_For_Matrix(){
	NumCols=$(awk -F'\" ' '{print NF; exit}' mymatrixbackup.txt);
	NumRows=$(cat mymatrixbackup.txt | wc -l)
	echo Rows: $NumRows Cols: $NumCols
}
function Iterate_Matrix_And_Create_Relationship(){

	input="mymatrixbackup.txt"
	RowCounter=0
	while IFS= read -r line
	do
		((RowCounter=RowCounter+1))
		LineToPrint=$(echo "$line" | cut -d '"' -f1-2 |  sed -e 's/^"//')
		[[ ${#LineToPrint} -gt 1 ]] && Word=$LineToPrint
		NGram=$(echo $line | cut -d '"' -f1-2 | sed -e 's/^"//')
		IFS=', ' read -r -a array <<< $line
		ColCounter=0
		for item in $(echo ${array[@]}); do 
			
			[[ $item =~ [0-9] ]] && ((ColCounter=ColCounter+1)) && echo $NGram:$item:$ColCounter
			#[[ ${#item} -gt 3 && $RowCounter -gt 1 ]] && ItemToPrint=$item
			#[[ $Word != "" && $ItemToPrint =~ [0-9] ]] && echo $Word:$ItemToPrint:$ColCounter 

		done 
	done < "mymatrixbackup.txt" > Relationships.txt
	
	while IFS= read -r line
	do
		NGram=$(echo "$line" | cut -d":" -f1)
		Score=$(echo "$line" | cut -d":" -f2)
		PersonNumber=$(echo "$line" | cut -d":" -f3)
		Return_Person_At_Position $PersonNumber
		#echo $NGram:$Score:$PersonOfInterest
		echo -e MATCH \(n:Person {name:\"$PersonOfInterest\"}\),\(a:n_gram{name:\"$NGram\"}\) MERGE \(n\)-[r:Associated_With {score:$Score}]-\>\(a\)\;

	done < "Relationships.txt" > RelationshipsFinal.txt
########mv Relationships.txt RelationshipsFinal.txt

########input="RelationshipsFinal.txt"
########RowCounter=0
########while IFS= read -r line
########do
########	NGram=$(echo "$line" | cut -d ':' -f1)
########	#NGram=$(echo \'$NGram\')
########	Score=$(echo "$line" | cut -d ':' -f2)
########	PersonNum=$(echo "$line" | cut -d ':' -f3)
########	LineToPrint=$(echo "$line")
########	Return_Person_At_Position $PersonNum
########	#echo -e $NGram : $Score : $PersonNum : $PersonOfInterest
########	[[ $Score != "0" ]] && echo -e MATCH \(n:Person {name:\"$PersonOfInterest\"}\),\(a:n_gram{name:\"$NGram\"}\) MERGE \(n\)-[r:Associated_With {score:$Score}]-\>\(a\)\;
########done < RelationshipsFinal.txt #> RelationshipFinalResults.txt
???END
########echo -e Created file RelationshipFinalResults.txt
}
function Display_Main_Menu(){
	CYAN='\033[0;36m'
	NC='\033[0m'
	clear
	echo -e "${CYAN}1) Print out File Results${NC}"
	echo -e "${CYAN}2) Extract First Line from File${NC}"
	echo -e "${CYAN}3) Extract Words${NC}"
	echo -e "${CYAN}4) Extract Relationships${NC}"
	echo -e "${CYAN}5) Create File Relationship Scores${NC}"
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
		"5") clear && sed -i ' 1 s/^/&"" /' mymatrixbackup.txt && Iterate_Matrix_And_Create_Relationship;;
		"6") clear && Return_Num_Rows_And_Columns_For_Matrix;;
		"7") clear && Iterate_Matrix_And_Create_Relationship;;
	esac
}
Display_Main_Menu

