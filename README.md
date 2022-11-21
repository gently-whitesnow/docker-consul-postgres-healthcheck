# Docker, consul, postgres -> healthcheck

## Что это?
Если вы такой же любитель острых ощущений и хотите запустить Consul и Postgres в Docker,
при этом иметь Healthcheck базы данных, то предлагаю ознакомиться с моим решением.

### Предисловие 
Самое простое что можно в такой связке сделать - это статично зарегистрировать базу данных в консуле.
Мы будем знать ее ip и порт, все сервисы подключенные к Consul будут это знать. 
Однако, жива ли база данных, работоспособна ли она, никто нам не скажет, кроме логов с ошибками.
Я не нашел удобного решения этой задачи, Postgres не предоставляет API для Healthcheck. Можно выполнить команду внутри контейнера
или за его пределами:
```
pg_isready -U db_user -d db
```
Это возможность наводит на мысль использовать идею "Docker check" - тип проверки консула:
> https://developer.hashicorp.com/consul/docs/discovery/checks#types-of-checks 

В таком раскладе сервису Consul надо дать прав к Docker Socket (через volume), либо разместить его на хосте, чего я делать не хотел.

### Как это работает
Способ проверки работоспособности: TTL - consumer обязан в течение определенного времени напомнить о себе.

1) Создаем network:
```
docker network create -d bridge server_network
```
2) Поднимаем Consul сервер
3) Через Dockerfile переопределяем image базы Postgres, загружая в контейнер утилиту '**curl**'
4) Прописываем конфигурационные файлы для регистрации **сервиса** и **проверки** для сервиса
```
postgres-service-registration.json 
postgres-check-registration.json
```
6) Перед поднятием БД дерегистрируем **ее** вместе с **проверкой работоспособности**
7) Через volume кладем в контейнер скрипт для напоминания о себе Consul
8) Если база успешно поднялась, регистрируем **ее** вместе с **проверкой работоспособности**
9) Инструментами Docker вызываем скрипт healthckeck'a, который включает в себя команду проверки 
работоспособности базы и продления ttl, если все в порядке

### Деплой
```
bash deploy_all.sh
```
Смотрим сюда http://localhost:8500/ui/dc1/services

### Полезные ссылки
1) Настроить Postgres:
> https://habr.com/ru/post/578744/
2) Примеры конфигураций Consul:
> https://github.com/hashicorp/learn-consul-docker/tree/main
3) Настроить Consul на русском:
> https://www.dmosk.ru/miniinstruktions.php?mini=consul-cluster  
> https://www.dmosk.ru/miniinstruktions.php?mini=consul-service  
> https://eax.me/consul/  
> https://habr.com/ru/post/453322/  
4) Настроить Consul на английском, цикл статей:
> https://developer.hashicorp.com/consul/tutorials/docker/docker-container-agents
5) Что такое **сервис** в Consul:
> https://developer.hashicorp.com/consul/api-docs/agent/service
6) Что такое **проверка** в Consul:
> https://developer.hashicorp.com/consul/api-docs/agent/check

### p.s.
0) Когда регистрируем/дерегистрируем базу - у нас network хоста.
Когда мы подтверждаем работоспособность из контейнера - у нас network внутренний.
1) Думаю вместо **curl** можно заиспользовать что-то более легковесное.
2) Проверку работы базы, можно заменить например на какой-нибудь SELECT.

#### Если есть о чем подискутировать, пишите: 
https://t.me/gently_whitesnow

