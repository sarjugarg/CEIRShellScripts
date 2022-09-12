#!/bin/bash
set -x

#while true; do
# sleep 2; done

echo "  logfile: $1"

  `sqlplus -s CRESTELCEIR/CRESTELCEIR123#@//PRO-DBR-SCAN:1522/dmcprdb >> $1 << EOF
    SET AUTOCOMMIT ON 
   @${2}${3}
  commit;
EOF
        `
exit ;

