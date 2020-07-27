#!/bin/bash
# copy ssh keys
# eval $(ssh-agent -s)
# ssh-add ~/.ssh/id_rsa
# ssh-copy-id id@server
# ssh
# scp
# openssl
# bigip
# https://support.f5.com/csp/article/K42531434
# bigiq
# https://support.f5.com/csp/article/K52425065

echo -n "Enter user name "
read user
sudo certbot certonly --webroot
sudo chown -R $user /etc/letsencrypt/
echo "Enter hosts: hostname hostname "
read hosts
for host in $hosts
do
dir=$PWD
echo "backup cert $host"
# backup current cert
ssh -oStrictHostKeyChecking=no $user@$host 'cp -f /config/httpd/conf/ssl.crt/server.crt /config/httpd/conf/ssl.crt/server.crt.bak;cp -f /config/httpd/conf/ssl.key/server.key /config/httpd/conf/ssl.key/server.key.bak;cp -f /config/httpd/conf/ssl.crt/chain.crt /config/httpd/conf/ssl.crt/chain.crt.bak'
ssh -oStrictHostKeyChecking=no $user@$host 'ls /config/httpd/conf/ssl.crt/;ls /config/httpd/conf/ssl.key/'
echo "cert backedup $host"
# combine chain
echo "combine chain cert $host"
#root=$(curl -s https://letsencrypt.org/certs/isrgrootx1.pem.txt)
#https://letsencrypt.org/certificates/
#https://www.identrust.com/dst-root-ca-x3
root=$(cat -<<EOF
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF
)
# clean up
rm /etc/letsencrypt/live/$host/server.crt
rm /etc/letsencrypt/live/$host/root.crt
rm /etc/letsencrypt/live/$host/chain.crt
rm /etc/letsencrypt/live/$host/key.key
# temp files
echo "$root"  >> /etc/letsencrypt/live/$host/root.crt
cat /etc/letsencrypt/live/$host/cert.pem >> /etc/letsencrypt/live/$host/server.crt
cat /etc/letsencrypt/live/$host/chain.pem >> /etc/letsencrypt/live/$host/chain.crt
cat /etc/letsencrypt/live/$host/privkey.pem >> /etc/letsencrypt/live/$host/key.key
ls 
echo "combine chain cert $host"
cat /etc/letsencrypt/live/$host/server.crt >> /etc/letsencrypt/live/$host/combined.crt
cat /etc/letsencrypt/live/$host/chain.crt >> /etc/letsencrypt/live/$host/combined.crt
cat /etc/letsencrypt/live/$host/root.crt >> /etc/letsencrypt/live/$host/combined.crt
# # copy to device
echo "copy to device $host"
cd /etc/letsencrypt/live/$host
scp combined.crt $user@$host:/config/httpd/conf/ssl.crt/server.crt
# scp chain.crt $user@$host:/config/httpd/conf/ssl.crt/chain.crt
scp key.key  $user@$host:/config/httpd/conf/ssl.key/server.key
echo "copied to device $host"
#ssh -oStrictHostKeyChecking=no $user@$host 'ls /config/httpd/conf/ssl.crt/;ls /config/httpd/conf/ssl.key/'
# install cert restart service
echo "installing cert $host"
path="/config/httpd/conf/ssl.crt"
ssh -oStrictHostKeyChecking=no $user@$host "tmsh modify /sys httpd ssl-certchainfile $path/combined.crt;bigstart restart httpd;bigstart restart webd"
done
echo "done"
#ssh -oStrictHostKeyChecking=no $user@$host "tmsh modify /sys httpd ssl-ca-cert-file $pathCrt/ca.crt ssl-certchainfile $pathCrt/chain.crt ssl-certfile $pathCrt/server.crt ssl-certkeyfile $pathKey/key.key;bigstart restart httpd;bigstart restart webd"