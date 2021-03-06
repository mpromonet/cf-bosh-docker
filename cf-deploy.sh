# ================== 
# deploy bosh director
# ==================
export BOSH_ENVIRONMENT="docker-director"
export BOSH_DIRECTOR_IP="10.244.0.3"
export NETWORK_NAME=bosh_network
export NETWORK_RANGE=10.244.0.0/20
export NETWORK_GW=10.244.0.1
export NETWORK_STATIC=10.244.0.10-10.244.0.127
export DNS="[8.8.8.8]"

pushd bosh-deployment > /dev/null
	bosh create-env bosh.yml \
		-o docker/cpi.yml \
		-o docker/unix-sock.yml \
		-v docker_host=unix:///var/run/docker.sock \
		-v director_name=${BOSH_ENVIRONMENT} \
		-v internal_cidr=${NETWORK_RANGE} \
		-v internal_gw=${NETWORK_GW} \
		-v internal_ip=${BOSH_DIRECTOR_IP} \
		-v network=${NETWORK_NAME} \
		--vars-store=~/bosh-creds.yml --state=state.json
		
	bosh int ~/bosh-creds.yml --path /director_ssl/ca > ~/ca.crt	      
	bosh -e "${BOSH_DIRECTOR_IP}" --ca-cert ~/ca.crt alias-env "${BOSH_ENVIRONMENT}"
popd  > /dev/null

cat << EOF > ~/boshenv
	      export BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT}"
	      export BOSH_CLIENT=admin
	      export BOSH_CLIENT_SECRET=$(bosh int ~/bosh-creds.yml --path /admin_password)
	      export BOSH_CA_CERT=~/ca.crt
EOF

# ================== 
# deploy cf
# ==================
source ~/boshenv 

pushd cf-deployment > /dev/null
	bosh update-runtime-config ../bosh-deployment/runtime-configs/dns.yml --name dns \
			--vars-store ~/dns-creds.yml  --no-redact -n

	bosh update-cloud-config -n iaas-support/bosh-lite/cloud-config.yml \
			-o ../overide.yml \
			-v network_name=${NETWORK_NAME} \
			-v network_range=${NETWORK_RANGE} \
			-v network_gw=${NETWORK_GW} \
			-v network_static=${NETWORK_STATIC} \
			-v dns=${DNS} 

	export STEMCELL_VERSION=$(bosh interpolate cf-deployment.yml --path=/stemcells/alias=default/version)
	bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-xenial-go_agent?v=${STEMCELL_VERSION}

	bosh deploy -d cf cf-deployment.yml \
		-o operations/bosh-lite.yml \
		-o operations/enable-nfs-volume-service.yml \
		-o operations/enable-service-discovery.yml \
		-o operations/use-compiled-releases.yml \
		-v system_domain=$CFDOMAIN \
		--vars-store ~/cf-creds.yml  -n
		
popd > /dev/null

