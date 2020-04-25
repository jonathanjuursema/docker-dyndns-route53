#!/bin/sh

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Missing AWS_ACCESS_KEY_ID"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Missing AWS_SECRET_ACCESS_KEY"
  exit 1
fi
if [ -z "$ROUTE53_HOSTED_ZONE_ID" ]; then
  echo "Missing ROUTE53_HOSTED_ZONE_ID"
  exit 1
fi
if [ -z "$ROUTE53_RECORD" ]; then
  echo "Missing ROUTE53_RECORD"
  exit 1
fi
if [ -z "$ROUTE53_TTL" ]; then
  echo "Missing ROUTE53_TTL"
  exit 1
fi

CURRENT_IP=""
SLEEP="$(($ROUTE53_TTL))"

update_route53() {
  aws route53 change-resource-record-sets \
    --hosted-zone-id $ROUTE53_HOSTED_ZONE_ID \
    --change-batch "{
      \"Changes\": [{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$ROUTE53_RECORD.\",
          \"Type\": \"A\",
          \"TTL\": $ROUTE53_TTL,
          \"ResourceRecords\": [{
            \"Value\": \"$NEW_IP\"
          }]
        }
      }]
    }"
}

get_ip() {
  curl -s https://diagnostic.opendns.com/myip > /tmp/current-ip.txt
}

while true; do

  date

  get_ip
  if [ $? -ne 0 ]; then
    echo "Failed to get IP, trying again next time."
    sleep $SLEEP
    continue
  fi

  NEW_IP=`cat /tmp/current-ip.txt`
  if [ "$CURRENT_IP" == "$NEW_IP" ]; then
    echo "Current IP: $NEW_IP - NO CHANGE"
    echo ""
    sleep $SLEEP
    continue
  else
    echo "Current IP: $NEW_IP - CHANGED"
  fi
  CURRENT_IP=$NEW_IP

  update_route53
  if [ $? -ne 0 ]; then
    echo "Failed to update Route 53, trying again next time."
    CURRENT_IP=""
  fi

  echo ""

  sleep $SLEEP

done
