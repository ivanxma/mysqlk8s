PGM=`basename $0`

if [ -f ./$PGM.ignore ]
then
	. ./$PGM.ignore
else

export BUCKETNAME=mybucket-operator
export COMPID=ocid1.compartment....
export DEMOSPACE=myic-demo

fi

