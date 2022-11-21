docker network create -d bridge server_network
cd consul-server
bash deploy.sh
cd ..
echo "Please wait 10 second of initialising Consul"
sleep 10
cd postgres
bash deploy.sh
