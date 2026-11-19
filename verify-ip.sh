#!/bin/bash
HOSTS_FILE="$HOME/etc/hosts"

verify-IP() {
  local name="$1"
  local expected="$2"
  local ips ip
  ips=`nslookup "$name" < /dev/null 2> /dev/null | awk '/^Name:/ {found=1} found && /^Address:/ {print $2}'`
  if [ -z "$ips" ]; then
    echo "Could not resolve $name"
    return 2
  fi
  for ip in $ips
  do
    if [ "$ip" = "$expected" ]; then
      echo "$name: OK ($expected)"
      return 0
    fi
  done
  echo "Bogus IP for $name in $HOME/etc/hosts !"
  return 1
}

if [ ! -f "$HOSTS_FILE" ]; then
  echo "$HOSTS_FILE does not exist"
  exit 3
fi

status=0
while read ip name rest || [ -n "$ip" ]
do
  case "$ip" in
    ""|\#*) continue ;;
    127.*|255.255.255.255|*:*) continue ;;
  esac
  verify-IP "$name" "$ip"
  code=$?
  echo "  (verify-IP returned $code)"
  [ $code -ne 0 ] && status=1
done < "$HOSTS_FILE"
exit $status