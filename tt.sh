N=30  #节点个数
Z=18  #zone个数
R=6000 #交易操作个数（实验次数）
echo create network
docker stop $(docker ps -aq)
docker network prune -f
for(( i=1; i<N+5; i++ ))
do
  docker network create --subnet=$[i].0.0.0/16 blockchain$[i]
done
echo create success
docker network ls

for(( i=1; i<N+5; i++ ))
do 
  #for(( j=0; j<6; j++ ))
  #do
  echo llll
  #gnome-terminal 
  docker run --rm -p $[1000+i]:$[5000]  --net blockchain$[i] --name node$[i] --ip $[i].0.0.10 cjk &
  #done
done

sleep 15
##################################################################
START_TIME=`date +%s`
echo begin to test

########################################
#随机数函数
########################################
function rand(){
  min=$1
  max=$(($2-$min+1))
  num=$(($RANDOM+1000000000)) 
  echo $(($num%$max+$min))
}
 
#rnd=$(rand 40 50)
#result=$(echo -n $rnd |shasum |awk '{print $1}')

#######################################
#节点注册
#######################################
start=$(date +%H%M%S)
for((i=1;i<N+1;i++))
do
   for((j=1;j<N+1;j++))
   do
   if [ "$j" -ne "$i" ]; then
   curl -X POST -H "Content-Type: application/json" -d "{\"nodes\": [\"http://$[j].0.0.10:5000\"],\"id\": [$[j%Z]]}" "http://$[i].0.0.10:5000/nodes/register"
   fi
   done
done
sleep 20
#######################################
#初始块查看
#######################################
u=0
for(( i=1; i<N+1; i++ ))
do
  curl -X GET -H "Content-Type: application/json"  "http://$[i].0.0.10:5000/chain"
done

#######################################
#同时挖矿
#######################################

while [ "1" -ne "0" ]
do
rnd=$(rand 1 N)

c=$(echo -n $rnd |shasum |awk '{print $1}')
   curl -X GET -H "Content-Type: application/json"  "http://$[rnd].0.0.10:5000/mine"
   echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
END_TIME=`date +%s`
 
EXECUTING_TIME=`expr $END_TIME - $START_TIME`
echo $EXECUTING_TIME
done &

#######################################
#交易
#######################################
for(( i=1; i<R+1; i++ ))
do
u=$[$u+1]
zid=$(rand 0 Z-1)
rnd=$(rand 1 N)
mon=$(rand 1 10000)
c=$(echo -n $rnd |shasum |awk '{print $1}')
   for((j=1;j<N+1;j++))
   do
      if [ $[j%Z] = $[zid] ]; then
      curl -X POST -H "Content-Type: application/json" -d "{\"sender\": \"$c\",\"sender_zone\": $[zid],\"recipient\": \"acount$[rnd]\",\"recipient_zone\": $[zid],\"amount\": $[mon]}" "$[j].0.0.10:5000/transactions/new" &
      fi
   done
done
rnd=$(rand 1 N)
curl -X GET -H "Content-Type: application/json"  "http://$[rnd].0.0.10:5000/mine"
echo success


for(( i=1; i<N+1; i++ ))
do
  echo resolve /////////////////////////////
  curl -X GET -H "Content-Type: application/json"  "http://$[i].0.0.10:5000/chain"
done
END_END_TIME=`date +%s`
while [ "1" -ne "0" ]
do
END_EXECUTING_TIME=`expr $END_END_TIME - $START_TIME`
echo --------------------COST TIME $END_EXECUTING_TIME-------------------
done



