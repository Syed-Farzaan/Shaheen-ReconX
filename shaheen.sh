#!/bin/bash

domain=$1
folder_name=$2
file_name=$3
YELLOW="\033[1;93m"
RED="\033[1;91m"
GREEN="\033[1;32m"
RESET="\033[0m"
BASE_DIR="$HOME/Targets"
TARGET_DIR="$BASE_DIR/$folder_name/$file_name"
script_start_time=$(date +%s)


show_help() {
	echo -e "${YELLOW}Usage: ${GREEN}$0 <domain> <target_foldername> <filename>${RESET}"
	exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	show_help
fi

if [ $# -ne 3 ]; then
	echo -e "${YELLOW} [+] Usage: $0 domain target_foldername filename${RESET}"
	exit 1
fi

if [ $# -ne 3 ]; then
	echo "Usage: $0 domain target_foldername filename"
	exit 1
fi

if [ ! -d "$TARGET_DIR" ];then
	mkdir -p "$TARGET_DIR"
fi

cd "$TARGET_DIR" || exit
if [ ! -f "$file_name.lst" ];then
	touch "$file_name.lst"
fi

figlet -c -t -f Doom "Shaheen  ReconX" | lolcat
USAGE=$(cat <<'Falcon'
											 .ze$$e.
								      .ed$$$eee..      .$$$$$$$P""
								   z$$$$$$$$$$$$$$$$$ee$$$$$$"
								.d$$$$$$$$$$$$$$$$$$$$$$$$$"
							      .$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$e..
							    .$$****""""***$$$$$$$$$$$$$$$$$$$$$$$$$$$be.
									     ""**$$$$$$$$$$$$$$$$$$$$$$$L
						 Advanced Reconnaissance       z$$$$$$$$$$$$$$$$$$$$$$$$$
						   Turned Simple (ARTS)      .$$$$$$$$P**$$$$$$$$$$$$$$$$
									    d$$$$$$$"              4$$$$$
									  z$$$$$$$$$                $$$P"
									 d$$$$$$$$$F                $P"
									 $$$$$$$$$$F
									  *$$$$$$$$"   Created by: Syed Bukhari (@0xTheFalcon)
									    "***""     Version-1.2.1
Falcon
)
echo "$USAGE" | lolcat

enumerate() {
	echo -e "\n${YELLOW} [+] Harvesting Subdomains with Subfinder + Passive Sources..........${RESET}"
	subfinder -d "$domain" -o "subfinder.lst" -silent -all > /dev/null
	sleep 1

	echo -e "${YELLOW} [+] Harvesting Subdomains with Kaeferjaeger.gay (through Cloud Providers)..........${RESET}"
	/opt/cloudrecon/cloud_data_search.sh -q -s "$domain" > kaeferjaeger.lst
	grep -v '^\*' kaeferjaeger.lst > temp.lst && mv temp.lst kaeferjaeger.lst
	sort -u kaeferjaeger.lst -o kaeferjaeger.lst
	sleep 1

	echo -e "${YELLOW} [+] Merging Results in one file..........${RESET}"
	sort -u subfinder.lst kaeferjaeger.lst > "$file_name.lst"
}


if [[ -s "$file_name.lst" ]]; then
	read -p "$(echo -e "\n${YELLOW} [+] Existing Subdomain List Found, do you want to skip enumeration? (y/n): ${RESET}")" choice

	if [[ "$choice" = "y" || "$choice" = "Y" ]]; then
		echo -e "${RED} [-] Skipping Enumeration.........${RESET}"
	else
		enumerate
	fi
else 
	enumerate
fi

echo -e "${YELLOW} [+] Subdomain list saved to: ${GREEN} $file_name.lst ${RESET}"
read -p "$(echo -e "${YELLOW} [+] Review $file_name.lst before running httprobe. Continue with probing? (y/n): ${RESET}")" probe_choice

if [[ "$probe_choice" != "y" && "$probe_choice" != "Y" ]]; then
	echo -e "${RED} [-] Stopping before httprobe. Review the file, then rerun when ready.${RESET}"
	exit 0
fi


echo -e "${YELLOW} [+] Probing for Alive/Responsive Hosts Using Httprobe..........${RESET}"
cat "$file_name.lst" | httprobe --prefer-https -p 8008,8080,8081,8089,8443,8843,5000,9001 -c 20 -t 40000 | sed 's~http[s]*://~~g' | sort -u >> alive.lst
sort -u alive.lst -o alive.lst
sleep 1


count1=$(wc -l < "$file_name.lst")
count3=$(cat alive.lst | wc -l)
if [[ -f subfinder.lst && -f kaeferjaeger.lst ]]; then
    sort -u subfinder.lst -o subfinder.lst
    sort -u kaeferjaeger.lst -o kaeferjaeger.lst
    count2=$(comm -13 subfinder.lst kaeferjaeger.lst | wc -l)
else
    count2="N/A"
fi

echo -e "${YELLOW} [+] New/Unique Subdomains Found by Kaeferjaeger = ${GREEN} $count2 ${RESET}"
echo -e "${YELLOW} [+] Total Hosts of Target Found = ${GREEN} $count1 ${RESET}"
echo -e "${YELLOW} [+] Number of Alive/Responsive Hosts = ${GREEN} $count3 ${RESET}"


rm -f subfinder.lst
rm -f temp.lst

script_end_time=$(date +%s)
elapsed_seconds=$((script_end_time - script_start_time))

hours=$((elapsed_seconds / 3600))
minutes=$(((elapsed_seconds % 3600) / 60))
seconds=$((elapsed_seconds % 60))

echo -e "${YELLOW} [+] Total Time Elapsed = ${GREEN}${hours}h ${minutes}m ${seconds}s${RESET}"
echo -e "${YELLOW} [+] Workspace: ${GREEN}$TARGET_DIR${RESET}"
