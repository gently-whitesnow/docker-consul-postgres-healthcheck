# Скрипт-хелсчек, который исполняется внутри контейнера
# В контейнере необходимо общаться по DNS
consul_address="consul-server:8500"

check_operation=$(pg_isready -U db_user -d db)
ok_string="/var/run/postgresql:5432 - accepting connections"

if [ "$check_operation" = "$ok_string" ]; then
    curl \
        --request PUT \
        --url "${consul_address}/v1/agent/check/pass/postgres-id"
fi
