# /bin/bash
#Verification droit root
if [ `whoami` != "root" ]; then
    echo "Vous devez avoir les privileges super-utilisateur pour executer ce script."
    exit 1
fi
#installation packages
clear
echo "Installation des logiciels necessaires en cours."
echo "deb http://mcrapet.free.fr/debian/ unstable/" > /etc/apt/sources.list.d/plowshare.list
clear
echo "Installation des logiciels necessaires en cours.."
apt-get update -y > /dev/null
clear
echo "Installation des logiciels necessaires en cours..."
apt-get upgrade -y > /dev/null
clear
echo "Installation des logiciels necessaires en cours...."
apt-get dist-upgrade -y > /dev/null
clear
echo "Installation des logiciels necessaires en cours......"
apt-get install -y --force-yes plowshare4 > /dev/null
#ajout identifiant
clear
echo -n "Entrez un identifiant: "
	read -e vpnuser	
# Ensure CN isn't blank
if [ -z "$vpnuser" ]
	then echo "Vous devez rentrer un identifiant."
	sleep 3
	echo -n "Entrez un identifiant: "
	read -e vpnuser
fi
# Check the CN doesn't already exist
if [ -f /etc/openvpn/easy-rsa/2.0/keys/$vpnuser.crt ]
	then echo "Erreur: le certificat pour l'identifiant $vpnuser existe deja!"
		echo "    /etc/openvpn/easy-rsa/2.0/keys/$vpnuser.crt"
	sleep 3
	echo -n "Entrez un autre identifiant: "
	read -e vpnuser
fi
#demande email pour envoie des certificats
clear
echo -n "Entrez une adresse email valide pour l'envoie des certificats de connexion: "
	read -e vpnemail	
# Ensure CN isn't blank
if [ -z "$vpnuser" ]
	then echo "Vous devez rentrer une adresse email."
	sleep 3
	echo -n "Entrez une adresse email valide pour l'envoie des certificats de connexion: "
	read -e vpnemail
fi
clear
#creation des certificats
echo "Configuration OpenVPN en cours...."
export KEY_CN=$vpnuser
. /etc/openvpn/easy-rsa/2.0/pkitool $vpnuser > /dev/null
clear
echo "Configuration OpenVPN en cours....."
cd /etc/openvpn/easy-rsa/2.0/keys
cp $vpnuser.crt $vpnuser.key /etc/openvpn/certs/
cd /etc/openvpn/certs/
zip -q /etc/openvpn/certs/$vpnuser.zip ca.crt $vpnuser.crt $vpnuser.key vpn.ovpn > /dev/null
plowup -q dl.free.fr --email-to=$vpnemail /etc/openvpn/certs/$vpnuser.zip
rm $vpnuser.crt $vpnuser.key
clear
echo "Configuration OpenVPN en cours......."
apt-get remove -y plowshare4 > /dev/null
rm /etc/apt/sources.list.d/plowshare.list
apt-get autoremove -y > /dev/null
clear
echo "Installation terminee, verifiez votre boite email pour recuperer votre fichier de configuration."
