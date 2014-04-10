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
echo "Installation des logiciels necessaires en cours....."
apt-get install -y --force-yes zip plowshare4 openssl > /dev/null
clear
echo "Installation des logiciels terminee."
sleep 5
#ajout identifiant
clear
echo -n "Entrez un identifiant: "
	read -e vpnuser	
#Verication que identifiant non vide
if [ -z "$vpnuser" ]
	then echo "Vous devez rentrer un identifiant."
	sleep 3
	echo -n "Entrez un identifiant: "
	read -e vpnuser
fi
#Verification identifiant n'existe pas deja
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
# Verication que email non vide
if [ -z "$vpnuser" ]
	then echo "Vous devez rentrer une adresse email."
	sleep 3
	echo -n "Entrez une adresse email valide pour l'envoie des certificats de connexion: "
	read -e vpnemail
fi
clear
echo "Configuration OpenVPN en cours."
#creation fichier config client vpn.ovpn
mkdir /etc/openvpn/certs

#recuperation IP du VPS
IP=`ifconfig venet0:0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}'`

#creation du fichier client vpn.ovpn
echo "client
dev tun
proto udp
remote $IP 1194
cipher none
auth none
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
ns-cert-type server" > /etc/openvpn/certs/$vpnuser.ovpn

#creation des certificats
cd /etc/openvpn/easy-rsa/2.0/
ln -s openssl-1.0.0.cnf openssl.cnf
. /etc/openvpn/easy-rsa/2.0/vars > /dev/null
clear
echo "Configuration OpenVPN en cours.."
clear
echo "Configuration OpenVPN en cours...."
export KEY_CN=$vpnuser
. /etc/openvpn/easy-rsa/2.0/pkitool $vpnuser > /dev/null
clear
echo "Configuration OpenVPN en cours....."
cd /etc/openvpn/easy-rsa/2.0/keys
echo "<ca>" >> /etc/openvpn/certs/$vpnuser.ovpn
cat ca.crt >> /etc/openvpn/certs/$vpnuser.ovpn
echo "</ca>" >> /etc/openvpn/certs/$vpnuser.ovpn
echo "<cert>" >> /etc/openvpn/certs/$vpnuser.ovpn
cat $vpnuser.crt >> /etc/openvpn/certs/$vpnuser.ovpn
echo "</cert>" >> /etc/openvpn/certs/$vpnuser.ovpn
echo "<key>" >> /etc/openvpn/certs/$vpnuser.ovpn
cat $vpnuser.key >> /etc/openvpn/certs/$vpnuser.ovpn
echo "</key>" >> /etc/openvpn/certs/$vpnuser.ovpn
cp ca.crt ca.key dh1024.pem server.crt server.key /etc/openvpn
cd /etc/openvpn/certs/

#upload du fichier config client
plowup -q dl.free.fr --email-to=$vpnemail /etc/openvpn/certs/$vpnuser.ovpn
clear
clear
#nettoyage des packages
apt-get remove -y plowshare4 > /dev/null
rm /etc/apt/sources.list.d/plowshare.list
apt-get autoremove -y > /dev/null
clear

echo "Installation terminee, verifiez votre boite email pour recuperer votre fichier de configuration."
