#!/bin/bash

url="${ER_ELASTIC_URL:-localhost:9200}"

if [[ "${ER_INSECURE_HTTPS}" == "true" ]]; then
  insecure_flag="--insecure"
fi

if [[ "${ER_ELASTIC_LOGIN}" != "" && "${ER_ELASTIC_PASS}" != "" ]]; then
  login_flag="--user ${ER_ELASTIC_LOGIN}:${ER_ELASTIC_PASS}"
fi

until curl -sko /dev/null ${insecure_flag} ${login_flag} "${url}"
do
  sleep 1
done

sleep 10
