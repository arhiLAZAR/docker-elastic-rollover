#!/bin/bash

policy_name="${ER_POLICY_NAME:-default_rollover}"
template_name="${ER_TEMPLATE_NAME:-all_indices}"
metricbeat_template_name="${ER_METRICBEAT_TEMPLATE_NAME:-metricbeat}"
url="${ER_ELASTIC_URL:-localhost:9200}"
shards="${ER_NUMBER_OF_SHARDS:-1}"
replicas="${ER_NUMBER_OF_REPLICAS:-1}"
priority="${ER_TEMPLATE_PRIORITY:-999}"
description="${ER_TEMPLATE_DESCRIPTION:-The template for the default index rotation}"
metricbeat_description="${ER_METRICBEAT_TEMPLATE_DESCRIPTION:-The template for metricbeat indices}"
metricbeat_index_pattern="${ER_METRICBEAT_INDEX_PATTERN:-metricbeat*}"
metricbeat_alias="${ER_METRICBEAT_ALIAS:-metricbeat}"
overwrite_templates="${ER_OVERWRITE_TEMPLATES:-false}"

if [[ "${ER_INSECURE_HTTPS}" == "true" ]]; then
  insecure_flag="--insecure"
fi

if [[ "${ER_ELASTIC_LOGIN}" != "" && "${ER_ELASTIC_PASS}" != "" ]]; then
  login_flag="--user ${ER_ELASTIC_LOGIN}:${ER_ELASTIC_PASS}"
fi

if [[ "${overwrite_templates}" != "true" ]]; then
  overwrite_flag='&create=true'
fi

for char in {a..z} {0..9} '-'; do
  index_patterns="${index_patterns} \"${char}*\", "
done

index_patterns=$(sed 's/, $//' <<< $index_patterns)

echo "Create a new Index Template \"${template_name}\""
echo "Priority: ${priority}"
echo "Shards count: ${shards}"
echo "Replicas count: ${replicas}"
echo "Description: ${description}"

curl  -XPUT \
      --silent \
      --header 'Content-Type: application/json' \
      ${insecure_flag} \
      ${login_flag} \
      "${url}/_index_template/${template_name}?pretty${overwrite_flag}" \
      --data "
{
  \"index_patterns\": [ ${index_patterns} ],
  \"data_stream\": { },
  \"template\": {
    \"settings\": {
      \"number_of_shards\": ${shards},
      \"number_of_replicas\": ${replicas},
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

if [[ "${ER_CREATE_METRICBEAT_TEMPLATE}" == "true" ]]; then
  echo "Create a new Index Template \"${metricbeat_template_name}\""
  echo "Priority: $(( ${priority} + 1 ))"
  echo "Shards count: ${shards}"
  echo "Replicas count: ${replicas}"
  echo "Description: ${metricbeat_description}"

  curl  -XPUT \
        --silent \
        --header 'Content-Type: application/json' \
        ${insecure_flag} \
        ${login_flag} \
        "${url}/_index_template/${metricbeat_template_name}?pretty${overwrite_flag}" \
        --data "
  {
    \"index_patterns\": [ \"${metricbeat_index_pattern}\" ],
    \"template\": {
      \"settings\": {
        \"number_of_shards\": ${shards},
        \"number_of_replicas\": ${replicas},
        \"index\": {
          \"lifecycle\": {
            \"name\": \"${policy_name}\",
            \"rollover_alias\": \"${metricbeat_alias}\"
          }
        }
      },
      \"mappings\": { }
    },
    \"priority\": $(( ${priority} + 1 )),
    \"_meta\": {
      \"description\": \"${metricbeat_description}\"
    }
  }
  "
fi
