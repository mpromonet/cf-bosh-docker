
# login to cf
# ========================
cf login -a api.$CFDOMAIN -u admin -p $(cat <(bosh int ~/cf-creds.yml --path /cf_admin_password))  --skip-ssl-validation
cf create-space space
cf target -s space
cf apps

wget https://github.com/orange-cloudfoundry/stratos-ui-cf-packager/releases/download/2.2.0/stratos-ui-packaged.zip
cf push console -b binary_buildpack -p stratos-ui-packaged.zip -m 128M -k 256M

cf apps
