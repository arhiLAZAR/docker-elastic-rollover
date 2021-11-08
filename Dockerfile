FROM ubuntu:18.04

COPY scripts/create-policy.sh /usr/local/bin/create-policy
COPY scripts/create-template.sh /usr/local/bin/create-template
COPY scripts/wait-for-elastic.sh /usr/local/bin/wait-for-elastic

RUN apt-get -y update && \
apt-get install -y --no-install-recommends \
curl \
jq \
ca-certificates && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
