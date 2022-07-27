#!/bin/bash
bm=$1
port1=$2
port2=$3

function publish_component {
echo "baking jar"
mv /opt/services/${bm} /opt/services/${bm}.bak
#ps -ef|grep ${port2}|grep -v grep|awk '{print $2}'|xargs kill -9
echo "publish jar"
cp /opt/publish/${bm} /opt/services/
A=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port2}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
echo $A
if [ "$A" != true ];then
source /opt/services/envs.env;nohup java -Xms512m -Xmx512m -Dserver.port=${port2} -jar /opt/services/${bm} >/dev/null 2>&1 &
echo "start ${bm} ${port2}"
else
echo "${bm} ${port2} is started"
fi
sleep 1

while true
do
A=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port2}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
B=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port1}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
if [ "$A" = true ] && [ "$B" = true ];then
ps -ef|grep ${bm}|grep ${port1}|grep -v grep|grep -v publishc.sh|awk '{print $2}'|xargs kill
echo "${port2} is started & kill ${bm} ${port1}"
break
else
sleep 2
echo "${bm} ${port2} is starting"
fi
done

while true
do
B=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port1}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
if [ "$B" = true ];then
echo "killing ${bm} ${port1}"
sleep 2
else
echo "${bm} ${port1} killed"
break
fi
done

while true
do
B=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port1}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
echo $B
if [ "$B" = true ];then
echo "${port1} started"
else
echo "start ${bm} ${port1}"
source /opt/services/envs.env;nohup java -Xms512m -Xmx512m -Dserver.port=${port1} -jar /opt/services/${bm} >/dev/null 2>&1 &
break
fi
done

while true
do
B=`curl -s --connect-timeout 5 -m 10  127.0.0.1:${port1}/git-version|awk -F ',' '{print $1}'|awk -F ':' '{print $2}'`
if [ "$B" = true ];then
echo "${bm} ${port1} started,kill ${port2}"
ps -ef|grep ${bm}|grep ${port2}|grep -v grep|grep -v publishc.sh|awk '{print $2}'|xargs kill
break
else
echo "${bm} ${port1} is starting"
sleep 2
fi
done
}
publish_component;
