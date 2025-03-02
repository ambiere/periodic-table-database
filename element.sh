#!/bin/bash

PSQL="psql -t --username=freecodecamp --dbname=periodic_table --no-align"

if [[ $# -eq 0 ]]; then
	echo "Please provide an element as an argument."
	exit
fi

LOG_ELEMENT_INFO() {
	if [[ -z $1 ]]; then
		echo "I could not find that element in the database."
		exit
	fi

	if [[ $# -ne 1 ]]; then
		echo "Invalid number arguments. Expected 1 arguments, got $# instead."
		exit
	fi

	echo "$1" |
		while IFS="|", read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE; do
			INFO1="The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL)."
			INFO2="It's a $TYPE, with a mass of $ATOMIC_MASS amu."
			INFO3="$NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

			echo -e "$INFO1 $INFO2 $INFO3"
		done
}

QUERY_ELEMENT_INFO() {
	if [[ $# -ne 2 ]]; then
		echo "Invalid number arguments. Expected 2 arguments, got $# instead."
		exit
	fi

	COLUMN_NAME=$1
	COLUMN_VALUE=$2

	ELEMENT_INFO=$(
		$PSQL -c "SELECT * FROM elements
    INNER JOIN properties
    USING(atomic_number)
    INNER JOIN types
    USING(type_id)
    WHERE $COLUMN_NAME = '$COLUMN_VALUE';"
	)

	echo "$ELEMENT_INFO"
}

if [[ $1 =~ ^[0-9]+$ ]]; then
	ELEMENT_INFO=$(QUERY_ELEMENT_INFO "atomic_number" $1)
	LOG_ELEMENT_INFO $ELEMENT_INFO
else
	ARGUMENT=$1
	case ${#ARGUMENT} in
	1 | 2)
		SYMBOL=$1
		ELEMENT_INFO=$(QUERY_ELEMENT_INFO "symbol" $SYMBOL)
		LOG_ELEMENT_INFO $ELEMENT_INFO
		;;
	*)
		NAME=$1
		ELEMENT_INFO=$(QUERY_ELEMENT_INFO "name" $NAME)
		LOG_ELEMENT_INFO $ELEMENT_INFO
		;;
	esac
fi
