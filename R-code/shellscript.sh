#!/bin/bash
function Extract_First_Line(){
	People=$(head -n 1 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g')
	IFS=','
	read -a strarraypeople<<< $People
        for person in ${strarraypeople[@]}; do
		echo create\(n:Person {name:\"$person\"}\)\;
        done>People.txt
	echo -e Wrote to People.txt
}

function Extract_Words(){
	tail -n +2 mymatrix.txt | sed 's|" |",|g' | sed 's|"||g' | cut -d',' -f1 | awk '{for (i=1; i<=NF; ++i)printf "%s%s", $i, i % 2? " ": "\n"}i % 2{print ""}' > words.txt
	WordRank=1
	input="words.txt"
	while IFS= read -r line
	do		
	   [[ "$line" != "" ]] && echo create\(n:n_gram {name:\"$line\"\,Rank:$WordRank}\)\; && ((WordRank=WordRank+1))
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
		done 
	done < "mymatrixbackup.txt" > Relationships.txt
	while IFS= read -r line
	do
		NGram=$(echo "$line" | cut -d":" -f1)
		Score=$(echo "$line" | cut -d":" -f2)
		PersonNumber=$(echo "$line" | cut -d":" -f3)
		Return_Person_At_Position $PersonNumber
		[[ $Score != "0" ]] && echo -e MATCH \(n:Person {name:\"$PersonOfInterest\"}\),\(a:n_gram{name:\"$NGram\"}\) MERGE \(n\)-[r:Associated_With {score:$Score}]-\>\(a\)\;
	done < "Relationships.txt" > RelationshipsFinal.txt
	echo -e Created File RelationshipsFinal.txt
}

function Merge_Files_Neo4j(){
	Green='\033[0;32m'
	NC='\033[0m'
	[[ -f "People.txt" ]] && cat People.txt > FinalOutputNeo4j.txt && rm People.txt 
	[[ -f "Words.txt" ]] && cat Words.txt >> FinalOutputNeo4j.txt && rm Words.txt
	[[ -f "words.txt" ]] && rm words.txt
	[[ -f "RelationshipsFinal.txt" ]] && cat RelationshipsFinal.txt >> FinalOutputNeo4j.txt && rm RelationshipsFinal.txt
	[[ -f "Relationships.txt" ]] && rm Relationships.txt
	echo -e ${Green} Finished!! ${NC}Created file FinalOutputNeo4j.txt
}

function Display_Main_Menu(){
	CYAN='\033[0;36m'
	NC='\033[0m'
	clear
	echo -e "${CYAN}1) Print out File Results${NC}"
	echo -e "${CYAN}2) Create words and people nodes${NC}"
	echo -e "${CYAN}3) Extract Relationships and Create File Scores${NC}"
	echo -e "${CYAN}4) Merge Neo4j files into one file${NC}"
	read -p "Choose an option (Note only enter in integer value):" chosenoption
	echo "You chose option $chosenoption"
	re='^[0-9]+$'
	if ! [[ $chosenoption =~ $re ]] ; then
	   echo "error: Not a number" >&2; exit 1
	fi

	case $chosenoption in
		"1") clear && cat mymatrix.txt;;
		"2") clear && Extract_First_Line && Extract_Words;;
		#"3") clear && Extract_Relationships && sed -i ' 1 s/^/&"" /' mymatrixbackup.txt && Iterate_Matrix_And_Create_Relationship;;
		"3") clear && sed -i ' 1 s/^/&"" /' mymatrixbackup.txt && Iterate_Matrix_And_Create_Relationship;;
		"4") clear && Merge_Files_Neo4j;;
	esac
}
Display_Main_Menu
