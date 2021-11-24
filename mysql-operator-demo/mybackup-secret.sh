kubectl create secret generic oci-credentials \
        --from-literal=user=ocid1.user.oc1.. \
        --from-literal=fingerprint=48:..  \
        --from-literal=tenancy=ocid1.tenancy.oc1.. \
        --from-literal=region=us-ashburn-1 \
	--from-literal=passphrase= \
        --from-file=privatekey=/home/opc/.oci/oci_api_key.pem
