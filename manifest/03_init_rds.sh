# manifest/init.sh
#!/bin/bash

set -Eeuo pipefail

echo
echo "# #################################"
echo "#  Init RDS"
echo "# #################################"
echo

kubectl apply -f manifest/job/flyway.yaml
