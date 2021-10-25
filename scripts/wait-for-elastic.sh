#!/bin/bash

url="${ER_ELASTIC_URL:-localhost:9200}"

if [[ "${ER_INSECURE_HTTPS}" == "true" ]]; then
  insecure_flag="--insecure"
fi

if [[ "${ER_ELASTIC_LOGIN}" != "" && "${ER_ELASTIC_PASS}" != "" ]]; then
  login_flag="--user ${ER_ELASTIC_LOGIN}:${ER_ELASTIC_PASS}"
fi

echo -ne "Wait for Elasticsearch to become reachable...\t\t"

until curl -sko /dev/null ${insecure_flag} ${login_flag} "${url}"
do
  sleep 1
done

sleep 10

echo "Done!"
