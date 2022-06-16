. ./env.sh

PGM=`basename $0`
if [ -f $PGM.ignore ]
then
	. ./$PGM.ignore
else

cat << EOF | kubectl apply -n $DEMOSPACE -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: backup-apikey
stringData:
  fingerprint: 68:c5:...
  passphrase : ""
  privatekey: |
    -----BEGIN RSA PRIVATE KEY-----
...
    -----END RSA PRIVATE KEY-----
  region: us-ashburn-1
  tenancy: ocid1.tenancy.......
  user: ocid1.user.oc1........
EOF

fi
