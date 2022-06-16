. ./env.sh

DATESTR=`date +"%Y%m%d%H%M%S"`
cat << EOF | kubectl apply -n $DEMOSPACE -f -
apiVersion: mysql.oracle.com/v2
kind: MySQLBackup
metadata:
  name: mysql-backup-$DATESTR
spec:
  clusterName: mycluster
  backupProfile: 
    name: dump-instance-profile-oci-adhoc
    dumpInstance:
      dumpOptions:
        excludeSchemas: ["excludedb"]
      storage:
        ociObjectStorage:
          prefix: myic-demo         # a prefix (directory) used for ObjectStorage
          bucketName: $BUCKETNAME         # the ObjectStorage bucket
          credentials: backup-apikey # a secret with credentials ...
EOF

kubectl get MySQLBackup -n $DEMOSPACE --watch
