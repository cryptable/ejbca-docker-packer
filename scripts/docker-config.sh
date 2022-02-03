#!/bin/sh

if [ ${HSM_SIMULATOR} = "false" ]; then
  
  sudo cat <<EOF > /opt/docker/docker-compose.yaml
# Use root/example as user/password credentials
version: '3.1'

services:
  ebjca:
    image: ejbca
    restart: always
    ports:
      - 8080:8080
      - 8443:8443
    environment:
      DATABASE_JDBC_URL: ${EJBCA_JDBC_MYSQL}
      DATABASE_USER: ejbca
      DATABASE_PASSWORD: ${EJBCA_MYSQL_PASSWORD}
      TLS_SETUP_ENABLED: simple

EOF

else

  sudo cat <<EOF > /opt/docker/docker-compose.yaml
# Use root/example as user/password credentials
version: '3.1'

services:

  db:
    image: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MSQL_ROOT_PASSWORD}
      MARIADB_DATABASE: ejbca
      MARIADB_USER: ejbca
      MARIADB_PASSWORD: ${EJBCA_MYSQL_PASSWORD}
    volumes:
      - mariadb-volume:/var/lib/mysql

  hsm:
    image: utimacohsm
    restart: always
        
  ebjca:
    hostname: ${HOSTNAME}
    image: ejbca
    restart: always
    depends_on:
      - db
      - hsm
    ports:
      - 8080:8080
      - 8443:8443
    environment:
      DATABASE_JDBC_URL: jdbc:mysql://db:3306/ejbca?characterEncoding=UTF-8
      DATABASE_USER: ejbca
      DATABASE_PASSWORD: ${EJBCA_MYSQL_PASSWORD}
      TLS_SETUP_ENABLED: simple

volumes:
  mariadb-volume:
EOF

fi

sudo docker pull mariadb

sudo docker stack deploy -c /opt/docker/docker-compose.yaml ejbca

sleep 30