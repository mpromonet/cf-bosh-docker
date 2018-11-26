
# login to cf
# ========================
cf login -a api.$CFDOMAIN -u admin -p $(cat <(bosh int ~/cf-creds.yml --path /cf_admin_password))  --skip-ssl-validation

# login to uaa
# ========================
uaac target uaa.$CFDOMAIN --skip-ssl-validation
uaac token client get admin -s $(cat <(bosh int ~/cf-creds.yml --path /uaa_admin_client_secret))
