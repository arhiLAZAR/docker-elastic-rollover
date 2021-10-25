#!/bin/bash

max_age="${ER_MAX_AGE:-1d}"
max_size="${ER_MAX_SIZE:-5GB}"
max_docs="${ER_MAX_DOCS:-100000000}"
delete_after="${ER_DELETE_AFTER:-14d}"
policy_name="${ER_POLICY_NAME:-default_rollover}"
url="${ER_ELASTIC_URL:-localhost:9200}"

if [[ "${ER_INSECURE_HTTPS}" == "true" ]]; then
  insecure_flag="--insecure"
fi

if [[ "${ER_ELASTIC_LOGIN}" != "" && "${ER_ELASTIC_PASS}" != "" ]]; then
  login_flag="--user ${ER_ELASTIC_LOGIN}:${ER_ELASTIC_PASS}"
fi

curl  -XPUT \
      -H 'Content-Type: application/json' \
      ${insecure_flag} \
      ${login_flag} \
      "${url}/_ilm/policy/${policy_name}?pretty" \
      -d"
{
  \"policy\": {
    \"phases\": {
      \"hot\": {
        \"actions\": {
          \"rollover\": {
            \"max_age\": \"${max_age}\",
            \"max_primary_shard_size\": \"${max_size}\",
            \"max_docs\": ${max_docs}
          }
        }
      },
      \"delete\": {
        \"min_age\": \"${delete_after}\",
        \"actions\": {
          \"delete\": {}
        }
      }
    }
  }
}
"
