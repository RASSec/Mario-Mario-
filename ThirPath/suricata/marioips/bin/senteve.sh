#!/bin/sh
while true;do
	bash /opt/marioips/bin/repost.sh
	wget http://remoteadd:5000/local.rules -O /opt/marioips/rules/local.rules
	newfile="eve_`date '+%Y%m%d%H%M%S'`.json"
	bash /opt/marioips/bin/update.sh
	if [ $(ls /opt/marioips/log/post_success/ | wc -l) -ge 100 ];
	then
		rm -rf $(ls /opt/marioips/log | sort -n | sed -n '1p')
	fi
	service mario stop
	mv /opt/marioips/log/eve.json /opt/marioips/log/$newfile
	echo `date '+%Y-%m-%d %H:%M:%S'` "backup eve.json to $newfile"
	check_results=`curl -F "clientfile=@/opt/marioips/log/$newfile" -H "Accept: application/json" http://remoteadd:5000/api/evefile`
	if [[ $check_results =~ "success" ]]
	then
		mv /opt/marioips/log/$newfile /opt/marioips/log/post_success/
		echo `date '+%Y-%m-%d %H:%M:%S'` "post eve.json success"
	else
		mv /opt/marioips/log/$newfile /opt/marioips/log/post_error/
		echo `date '+%Y-%m-%d %H:%M:%S'` "post $newfile error"
	fi
	service mario start
	echo `date '+%Y-%m-%d %H:%M:%S'` "service mario restart"
	sleep 10m;
done