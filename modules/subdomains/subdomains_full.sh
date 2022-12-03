#!/usr/bin/env bash

NUMOFLINES_subs="0"
NUMOFLINES_probed="0"
printf "${bgreen}#######################################################################\n\n"
! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]] && printf "${bblue} Subdomain Enumeration $domain\n\n"
[[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]] && printf "${bblue} Scanning IP $domain\n\n"
[ -s "subdomains/subdomains.txt" ] && cp subdomains/subdomains.txt .tmp/subdomains_old.txt
[ -s "webs/webs.txt" ] && cp webs/webs.txt .tmp/probed_old.txt
if ( [ ! -f "$called_fn_dir/.sub_active" ] || [ ! -f "$called_fn_dir/.sub_brute" ] || [ ! -f "$called_fn_dir/.sub_permut" ] || [ ! -f "$called_fn_dir/.sub_recursive_brute" ] )  || [ "$DIFF" = true ] ; then
	resolvers_update
fi
[ -s "${inScope_file}" ] && cat ${inScope_file} | anew -q subdomains/subdomains.txt
if ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9] ]] && [ "$SUBDOMAINS_GENERAL" = true ]; then
	sub_passive
	sub_crt
	sub_active
	sub_noerror
	sub_brute
	sub_permut
	sub_recursive_passive
	sub_recursive_brute
	sub_dns
	sub_scraping
	sub_analytics
else 
	notification "IP/CIDR detected, subdomains search skipped" info
	echo $domain | anew -q subdomains/subdomains.txt
fi
if [ "$BBRF_CONNECTION" = true ]; then
	[ -s "subdomains/subdomains.txt" ] && cat subdomains/subdomains.txt | bbrf domain add - 2>>"$LOGFILE" &>/dev/null
fi
webprobe_simple
if [ -s "subdomains/subdomains.txt" ]; then
	deleteOutScoped $outOfScope_file subdomains/subdomains.txt
	NUMOFLINES_subs=$(cat subdomains/subdomains.txt 2>>"$LOGFILE" | anew .tmp/subdomains_old.txt | sed '/^$/d' | wc -l)
fi
if [ -s "webs/webs.txt" ]; then
	deleteOutScoped $outOfScope_file webs/webs.txt
	NUMOFLINES_probed=$(cat webs/webs.txt 2>>"$LOGFILE" | anew .tmp/probed_old.txt | sed '/^$/d' | wc -l)
fi
printf "${bblue}\n Total subdomains: ${reset}\n\n"
notification "- ${NUMOFLINES_subs} alive" good
[ -s "subdomains/subdomains.txt" ] && cat subdomains/subdomains.txt | sort
notification "- ${NUMOFLINES_probed} new web probed" good
[ -s "webs/webs.txt" ] && cat webs/webs.txt | sort
notification "Subdomain Enumeration Finished" good
printf "${bblue} Results are saved in $domain/subdomains/subdomains.txt and webs/webs.txt${reset}\n"
printf "${bgreen}#######################################################################\n\n"