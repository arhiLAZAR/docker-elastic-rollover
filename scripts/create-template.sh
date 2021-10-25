#!/bin/bash

policy_name="${ER_POLICY_NAME:-default_rollover}"
template_name="${ER_TEMPLATE_NAME:-all_indices}"
url="${ER_ELASTIC_URL:-localhost:9200}"
shards="${ER_NUMBER_OF_SHARDS:-1}"
priority="${ER_TEMPLATE_PRIORITY:-999}"
description="${ER_TEMPLATE_DESCRIPTION:-The template for the default index rotation}"

if [[ "${ER_INSECURE_HTTPS}" == "true" ]]; then
  insecure_flag="--insecure"
fi

if [[ "${ER_ELASTIC_LOGIN}" != "" && "${ER_ELASTIC_PASS}" != "" ]]; then
  login_flag="--user ${ER_ELASTIC_LOGIN}:${ER_ELASTIC_PASS}"
fi

for char in {a..z} {0..9} '-'; do
  index_patterns="${index_patterns} \"${char}*\", "
done

index_patterns=$(sed 's/, $//' <<< $index_patterns)

curl  -XPUT \
      -H 'Content-Type: application/json' \
      ${insecure_flag} \
      ${login_flag} \
      "${url}/_index_template/${template_name}?pretty" \
      -d"
{
  \"index_patterns\": [ ${index_patterns} ],
  \"data_stream\": { },
  \"template\": {
    \"settings\": {
      \"number_of_shards\": ${shards},
      \"index\": {
        \"lifecycle\": {
          \"name\": \"${policy_name}\"
        }
      }
    },
    \"mappings\": { }
  },
  \"priority\": ${priority},
  \"_meta\": {
    \"description\": \"${description}\"
  }
}
"
