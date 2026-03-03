# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "#  Init RDS"
echo "# #################################"
echo

kubectl create -f manifest/job/flyway.yaml 2>/dev/null || kubectl replace --force -f manifest/job/flyway.yaml
