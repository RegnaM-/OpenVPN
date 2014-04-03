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
apt-get install -y --force-yes openvpn zip plowshare4 openssl > /dev/null
clear
echo "Installation des logiciels necessaires en cours......."
service openvpn stop
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

#creation du fichier openvpn.conf
echo "port 1194
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh1024.pem
server 10.0.0.0 255.255.255.0
user nobody
group nogroup
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
keepalive 10 60
cipher none
auth none
persist-key
persist-tun
status status.log 5
status-version 2
log-append  openvpn.log
verb 3" > /etc/openvpn/openvpn.conf
clear

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
ns-cert-type server
ca ca.crt
cert $vpnuser.crt
key $vpnuser.key" > /etc/openvpn/certs/vpn.ovpn

#creation des certificats
cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
cd /etc/openvpn/easy-rsa/2.0/
ln -s openssl-1.0.0.cnf openssl.cnf
. /etc/openvpn/easy-rsa/2.0/vars > /dev/null
. /etc/openvpn/easy-rsa/2.0/clean-all > /dev/null
clear
echo "Configuration OpenVPN en cours.."
export KEY_CN=ca
. /etc/openvpn/easy-rsa/2.0/pkitool --initca > /dev/null
clear
echo "Configuration OpenVPN en cours..."
export KEY_CN=server
. /etc/openvpn/easy-rsa/2.0/pkitool --server server > /dev/null
clear
echo "Configuration OpenVPN en cours...."
export KEY_CN=$vpnuser
. /etc/openvpn/easy-rsa/2.0/pkitool $vpnuser > /dev/null
clear
echo "Configuration OpenVPN en cours....."
. /etc/openvpn/easy-rsa/2.0/build-dh > /dev/null
cd /etc/openvpn/easy-rsa/2.0/keys
cp ca.crt ca.key dh1024.pem server.crt server.key /etc/openvpn
cp $vpnuser.crt $vpnuser.key ca.cart /etc/openvpn/certs/
cd /etc/openvpn/certs/

#zip + upload des certificats client
zip -q /etc/openvpn/certs/$vpnuser.zip ca.crt $vpnuser.crt $vpnuser.key vpn.ovpn > /dev/null
plowup -q dl.free.fr --email-to=$vpnemail /etc/openvpn/certs/$vpnuser.zip
rm $vpnuser.crt $vpnuser.key
clear

#configuration ipforward+iptables
echo "Configuration OpenVPN en cours......"
echo AUTOSTART="all" >> /etc/default/openvpn
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo net.ipv.ip_forward=1 >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o venet0 -j MASQUERADE
iptables-save
clear
echo "Configuration OpenVPN en cours......"
service openvpn start
clear
echo "Configuration OpenVPN en cours......."

#nettoyage des packages
apt-get remove -y plowshare4 > /dev/null
rm /etc/apt/sources.list.d/plowshare.list
apt-get autoremove -y > /dev/null
clear

echo "Installation terminee, verifiez votre boite email pour recuperer votre fichier de configuration."
