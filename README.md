
[![CircleCI](https://circleci.com/gh/mpromonet/cf-bosh-docker.svg?style=shield)](https://circleci.com/gh/mpromonet/cf-bosh-docker)

# get bosh & cf
```
git clone https://github.com/cloudfoundry/bosh-deployment
git clone https://github.com/cloudfoundry/cf-deployment
```

# allow docker access from cpi
```
sudo chmod a+rw /var/run/docker.sock
```

# set cf IP
```
export CFDOMAIN=$(hostname -I | awk '{print $1}').xip.io
```

# deploy CF
```
./cf-deploy.sh
```

# login to cf
```
cf login -a api.$CFDOMAIN -u admin -p $(cat <(bosh int ~/cf-creds.yml --path /cf_admin_password))  --skip-ssl-validation
```

# login to uaa
```
uaac target uaa.$CFDOMAIN 
uaac token client get admin -s $(cat <(bosh int ~/cf-creds.yml --path /uaa_admin_client_secret)) --skip-ssl-validation
```

