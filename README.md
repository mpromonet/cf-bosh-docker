

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
export HOST_IP=$(hostname -I | awk '{print $1}')
```

# deploy CF
```
./cf-deploy.sh
```

# login to cf
```
cf login -a api.$HOST_IP.xip.io -u admin -p $(cat <(bosh int ~/cf-creds.yml --path /cf_admin_password))  --skip-ssl-validation
```

# login to uaa
```
uaac target uaa.$HOST_IPxip.io 
uaac token client get admin -s $(cat <(bosh int ~/cf-creds.yml --path /uaa_admin_client_secret))
```

