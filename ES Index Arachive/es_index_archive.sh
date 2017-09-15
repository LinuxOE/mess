#!/bin/bash
######检查Elastiseach有没有启动#######
timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/9200"
if [ $? != 0 ];then
exit
fi
######创建新索引######
curl -XPUT "http://127.0.0.1:9200/indexname_$(date +%F)/?pretty" -d '{ 
"settings":{
"index":{ 
"number_of_shards":1, 
"number_of_replicas":0
}
}
}'
######获取别名为indexname_current的索引名#######
LAST_INDEX=$(curl -s -XGET "http://127.0.0.1:9200/_alias/indexname_current" |awk -F '[{"]+' '{print $2}')
######别名indexname_current漂移######
curl -XPOST "http://127.0.0.1:9200/_aliases" -d '{
"actions" : [
{ "remove" : { "index" : "'$LAST_INDEX'", "alias" : "indexname_current" } },
{ "add" : { "index" : "'indexname_$(date +%F)'", "alias" : "indexname_current" } },
{ "add" : { "index" : "'indexname_$(date +%F)'", "alias" : "indexname_all" } }
]
}'
######获取老的索引列表，保留最新的15个索引######
DELETE_INDEX_LIST=$(curl -s -XGET 'http://127.0.0.1:9200/_alias/indexname_all?pretty'|egrep -v 'aliases|indexname_all|}|^{'|awk -F '"' '{print $2}'|sort -r|sed '1,15d')
for INDEX in $DELETE_INDEX_LIST
do
curl -XDELETE "http://127.0.0.1:9200/$INDEX"
done