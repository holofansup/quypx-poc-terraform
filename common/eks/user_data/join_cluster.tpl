MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex

CLUSTER_NAME=${cluster_name}
B64_CLUSTER_CA=${cert_auth}
API_SERVER_URL=${api_server_url}
DNS_CLUSTER_IP=${dns_cluster_ip}
/etc/eks/bootstrap.sh $CLUSTER_NAME \
  --b64-cluster-ca $B64_CLUSTER_CA \
  --apiserver-endpoint $API_SERVER_URL \
  --dns-cluster-ip $DNS_CLUSTER_IP \
  --use-max-pods true
--//