#!/bin/bash
# Created by Richard C Gingras Jr

# Wanted to be able to access my Emby server over the internet using https and wanted to use the 
#	same certificate that DSM automagically keeps up to date from LetsEncrypt.

# So this script will grab the "DEFAULT" cert set within DSM, convert it so emby can use it and
#	place it in a static location for emby to pickup. Will also restart the emby service so it
#	will pickup the new cert

# We need to run as root or else we wont have permission to touch needed files
#	Possibly other root users could be used if desired
if [ "$(whoami)" != "root" ]; then
	echo "please run this as root"
	exit 1
fi

# Make sure our target directory is there
if ! mkdir -p /embyssl/; then
	# Fail!? ummmm oops
	echo "Making the directory /embyssl/ failed somehow"
	exit 2
fi

# Lets grab what the default cert is according to the synology GUI
DefaultCert=$(cat /usr/syno/etc/certificate/_archive/DEFAULT)

# TODO we should check to see if the cert has been modified within the last 7 (8?) days to see if this whole process is even needed

# Lets take the cert and copy it over to the target directory so we do not break what should be working
if ! cp /usr/syno/etc/certificate/_archive/"$DefaultCert"/{cert.pem,chain.pem,privkey.pem} /embyssl/; then
	echo "We somehow managed to fail at copying the files, do we not have access somehow?"
	exit 3
fi

# Using the openssl command, er are going to convert the certificate into a format Emby supports
if ! openssl pkcs12 -export -out /embyssl/mydomain.pfx -inkey /embyssl/privkey.pem -in /embyssl/cert.pem -certfile /embyssl/chain.pem -password pass:; then
	echo "openssl convert failed"
	exit 4
fi

# Make the cert owned by the default Emby user
if ! chown embysvr /embyssl/mydomain.pfx; then
	echo "chown failed"
	exit 5
fi

# clean up these files as they are not needed
rm /embyssl/cert.pem /embyssl/chain.pem /embyssl/privkey.pem

# Restart emby so it picks up the new license (TODO: read the doc for emby, is this step needed?)
if ! synoservice --restart pkgctl-EmbyServer; then
	echo "Failed to restart the emby server serivces"
	exit 6
fi

# If arrived here then it was a success
exit 0
