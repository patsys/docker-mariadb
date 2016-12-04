#!/bin/sh

if [ -z "$INTERVAL" ]; then
    INTERVAL=5
fi  
if [ -z "$TRY" ]; then
    TRY=30
fi 

number=0
TMP=$(mktemp)
while [ "$number" -lt "$TRY" ]; do
  mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -Bse "USE $MYSQL_DATABASE; CREATE TABLE test1_tbl(test_id INT NOT NULL);" 2> "$TMP"
  ret=$?
  err=$(cat "$TMP")
  echo "fg: $err"
  if [ "$ret" -eq 0 ]; then
    break
  elif  ! echo "$err" | grep -q "ERROR 2003" ; then
     exit "$ret"
  fi
sleep $INTERVAL
done
rm "$TMP"
if [ "$ret" -ne 0]; then
  exit "$ret"
fi
if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
  mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASSWORD -Bse "USE $MYSQL_DATABASE; CREATE TABLE test_tbl(test_id INT NOT NULL);"
  ret=$?
  if [ "$ret" -ne 0 ]; then
     exit $ret
  fi
fi

exit 0
