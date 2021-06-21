PGM=`basename $0`
if [ $# -ne 1 ]
then
	echo "Usage : $PGM <namespace>"
	exit
fi



echo -n "Input Git User : "
read myuser

echo -n "Input Git Password : "
read -s mypassword

echo -n "Input Git email : "
read myemail

echo "Press <ENTER> to continue"
read

kubectl create ns $1

kubectl create secret docker-registry mydockersecret -n $1 --docker-username=$myuser --docker-password=$mypassword --docker-email=$myemail  -o yaml > mydockersecret.yaml
