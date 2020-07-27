# letsencrypt-f5-management
scripts for renewing and installing letsencrypt certs for BIG-IP/BIG-IQ management interfaces.

*** NOT FOR TRAFFIC CERTIFICATES ***


- bash

- bash + vault

- ansible



requirements:

  - valid dns resolution
  - docker
  - route challenge requests to certbot 

optional:
 - irule to route challenge requests to container
    - Server Name Indicator
    - URI 


notes:

valid for GTM/F5DNS, requires the whole chain built in bigip-mgmt.sh

works for BIG-IQ centralized manager and BIG-IQ data collection devices