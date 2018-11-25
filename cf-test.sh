
# login to cf
# ========================
cf login -a api.$HOST_IP.xip.io -u admin -p $(cat <(bosh int ~/cf-creds.yml --path /cf_admin_password))  --skip-ssl-validation

# login to uaa
# ========================
uaac target uaa.$HOST_IPxip.io 
uaac token client get admin -s $(cat <(bosh int ~/cf-creds.yml --path /uaa_admin_client_secret))