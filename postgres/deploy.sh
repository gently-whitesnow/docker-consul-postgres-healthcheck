consul_address="http://localhost:8500"

# Дерегиструем Postgres с ее проверками
curl \
    --request PUT \
    --url "${consul_address}/v1/agent/service/deregister/postgres-service-id"
    
curl \
    --request PUT \
    --url "${consul_address}/v1/agent/check/deregister/postgres-id"
    
docker-compose stop
docker-compose rm -f

# Если билд успешный региструем Postgres с ее проверками
if docker-compose up -d ; then
    echo "Service registration in Consul"
    curl \
          --request PUT \
          --data @postgres-service-registration.json \
          --url "${consul_address}/v1/agent/service/register"
    echo "Check registration in Consul"
    curl \
          --request PUT \
          --data @postgres-check-registration.json \
          --url "${consul_address}/v1/agent/check/register"
else
    echo "Command failed"
fi

