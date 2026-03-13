#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_SERVERS="${BOOTSTRAP_SERVERS:?BOOTSTRAP_SERVERS is required}"
TOPIC_NAME="${TOPIC_NAME:-orders}"
PARTITIONS="${PARTITIONS:-3}"
REPLICATION_FACTOR="${REPLICATION_FACTOR:-3}"

echo "Checking topic: ${TOPIC_NAME}"

if /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVERS}" \
  --command-config /opt/kafka/config/client.properties \
  --describe \
  --topic "${TOPIC_NAME}" >/dev/null 2>&1; then
  echo "Topic '${TOPIC_NAME}' already exists. Nothing to do."
  exit 0
fi

echo "Creating topic '${TOPIC_NAME}'"

/opt/kafka/bin/kafka-topics.sh \
  --create \
  --bootstrap-server "${BOOTSTRAP_SERVERS}" \
  --command-config /opt/kafka/config/client.properties \
  --topic "${TOPIC_NAME}" \
  --partitions "${PARTITIONS}" \
  --replication-factor "${REPLICATION_FACTOR}" \
  --config cleanup.policy=delete \
  --config retention.ms=604800000

echo "Topic created successfully."

echo "Verifying topic..."
/opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server "${BOOTSTRAP_SERVERS}" \
  --command-config /opt/kafka/config/client.properties \
  --describe \
  --topic "${TOPIC_NAME}"