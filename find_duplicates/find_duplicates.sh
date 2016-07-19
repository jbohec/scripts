#!/bin/bash

# To use the colored labels
. ../main/lib_colors.sh

# Get script name
export SCRIPT_NAME=`basename $0`

echo "------------------------------------------------------------"
printf "${CYAN}${SCRIPT_NAME}${NC}\n"
printf "${BLUE}Find all duplicates within the given tree path${NC}\n"
echo "------------------------------------------------------------"


function usage()
{
  echo
  echo "usage: $SCRIPT_NAME [-h] [-p path]"
  echo "   h : show this help"
  echo "   p : find all duplicates within the tree path"
  echo "       ex: $SCRIPT_NAME -p /Users/foo"
  echo
}


# OPTIONS
if (($# == 0)); then
  echo
  printf "${red}${SCRIPT_NAME} expects at least one argument...${NC}\n"
  usage
  exit 1
fi

while getopts ":hp:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;

    p)
      path=$OPTARG
      echo
      printf "Explored path...\t\t\t\t\t${green}${path}${NC}\n"
      ;; 

    \?)
      echo
      printf "${red}Invalid option: -${OPTARG}${NC}\n" >&2
      usage
      exit 1
      ;;

    :)
      echo
      printf "${red}Option -${OPTARG} requires an argument.${NC}\n" >&2
      usage
      exit 1
      ;;
  esac
done

printf "List all files with their respective md5 hash...\t"
# Exclude
# - Icon? : folder icons (Mac)
# - .* : hidden files (Unix, Mac)
find $path -type f ! -name "Icon?" ! -name ".*" -exec md5 {} \; 2>/dev/null | awk -F" = " '{ print $2 ";" $1 }' | sort > find_duplicates.tmp
printf "${green}OK${NC}\n"

printf "Look for duplicates...\t\t\t\t\t"
cat find_duplicates.tmp | awk -F";" '{ print $1 }' | uniq -d > find_duplicates.found
printf "${green}OK${NC}\n"

printf "Generate file with duplicates...\t\t\t"
grep -f find_duplicates.found find_duplicates.tmp > find_duplicates.txt
printf "${green}OK${NC}\n"

printf "Delete tmp files...\t\t\t\t\t"
rm -f find_duplicates.tmp find_duplicates.found
printf "${green}OK${NC}\n"

printf "Number of found duplicates...\t\t\t\t"
nb=`cat find_duplicates.txt | wc -l | tr -d '[[:space:]]'`
if [ $nb -gt 0 ]
then
	printf "${red}${nb}${NC}\n"
else
	printf "${green}${nb}${NC}\n"
fi

printf "The list can be found here...\t\t\t\t"
printf "${green}./find_duplicates.txt${NC}\n"

printf "${GREEN}Done!${NC}\n\n"
