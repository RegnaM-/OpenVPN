# /bin/bash
#Verification droit root
if [ `whoami` != "root" ]; then
    echo "Vous devez avoir les privileges super-utilisateur pour executer ce script."
    exit 1
fi
clear
echo -n "Entrez l'identifiant a DESACTIVER: "
	read -e vpnuser	
# Ensure CN isn't blank
if [ -z "$vpnuser" ]
	then echo "Vous devez rentrer un identifiant."
	sleep 3
	echo -n "Entrez l'identifiant a DESACTIVER: "
	read -e vpnuser
fi
. /etc/openvpn/easy-rsa/2.0/vars > /dev/null
. /etc/openvpn/easy-rsa/2.0/revoke-full $vpnuser > /dev/null
rm /etc/openvpn/easy-rsa/2.0/keys/$vpnuser.crt
rm /etc/openvpn/easy-rsa/2.0/keys/$vpnuser.key
rm /etc/openvpn/easy-rsa/2.0/keys/$vpnuser.csr
clear
echo  "Identifiant: $vpnuser est desormais supprimé"
