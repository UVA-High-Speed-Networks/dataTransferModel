procName=$1
kill -9 `ps aux | grep $procName | awk '{print $2}'`
