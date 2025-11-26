#!/bin/bash
#
# Funciones para configurar el backend de la aplicación
#######################################
# Crea una base de datos REDIS usando Docker
# Argumentos:
#   Ninguno
#######################################
backend_redis_create() {
  print_banner
  printf "${WHITE} 💻 Creando Redis y base de datos Postgres...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  usermod -aG docker deploy
  docker run --name redis-${instancia_add} -p ${redis_port}:6379 --restart always --detach redis redis-server --requirepass ${mysql_root_password}
  
  sleep 2
  sudo su - postgres <<EOF
  createdb ${instancia_add};
  psql
  CREATE USER ${instancia_add} SUPERUSER INHERIT CREATEDB CREATEROLE;
  ALTER USER ${instancia_add} PASSWORD '${mysql_root_password}';
  \q
  exit
EOF

sleep 2
}

#######################################
# Configura las variables de entorno para el backend
# Argumentos:
#   Ninguno
#######################################
backend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variables de entorno (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # asegurar idempotencia
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  # asegurar idempotencia
  frontend_url=$(echo "${frontend_url/https:\/\/}")
  frontend_url=${frontend_url%%/*}
  frontend_url=https://$frontend_url

  sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/backend/.env
NODE_ENV=production
BACKEND_URL=${backend_url}
FRONTEND_URL=${frontend_url}
PROXY_PORT=443
PORT=${backend_port}
# CHASAP_ID 
$( [ -n "$CHASAP_ID" ] && echo "CHASAP_ID=${CHASAP_ID}" )

DB_DIALECT=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=${instancia_add}
DB_PASS=${mysql_root_password}
DB_NAME=${instancia_add}

JWT_SECRET=${jwt_secret}
JWT_REFRESH_SECRET=${jwt_refresh_secret}

REDIS_URI=redis://:${mysql_root_password}@127.0.0.1:${redis_port}
REDIS_OPT_LIMITER_MAX=1
REGIS_OPT_LIMITER_DURATION=3000

USER_LIMIT=${max_user}
CONNECTIONS_LIMIT=${max_whats}
CLOSED_SEND_BY_ME=true

MAIL_HOST="smtp.hostinger.com"
MAIL_USER="contato@seusite.com"
MAIL_PASS="senha"
MAIL_FROM="Recuperar Contraseña <contato@seusite.com>"
MAIL_PORT="465"

[-]EOF
EOF

  sleep 2
}

#######################################
# Instala las dependencias de Node.js
# Argumentos:
#   Ninguno
#######################################
backend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependencias del backend...${GRAY_LIGHT}\n\n"

  sleep 2

  # Primero instalar Node.js y npm bien
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs

  # Luego como usuario deploy hacer el resto
  sudo -u deploy bash -c "
    cd /home/deploy/${instancia_add}/backend &&
    npm cache clean -f &&
    npm install --loglevel=error
  "

  sleep 2
}


#######################################
# Compila el código del backend
# Argumentos:
#   Ninguno
#######################################
backend_node_build() {
  print_banner
  printf "${WHITE} 💻 Compilando el código del backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npm run build
EOF

  sleep 2
}


#######################################
# Actualiza el código del backend
# Argumentos:
#   Ninguno
#######################################
backend_update() {
  print_banner
  printf "${WHITE} 💻 Actualizando el backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  cd /home/deploy/${empresa_atualizar}

  echo "🚫 Deteniendo PM2..."
  sudo -u deploy pm2 stop ${empresa_atualizar}-backend

  echo "🔄 Haciendo git fetch..."
  sudo -u deploy git fetch origin

  echo "🔍 Verificando cambios locales..."
  if [ -n "$(sudo -u deploy git status --porcelain)" ]; then
    echo "⚠️ Cambios locales detectados. Ejecutando reset forzado..."
    sudo -u deploy git reset --hard origin/main
  else
    echo "✅ No hay cambios locales, ejecutando git pull..."
    PULL_OUTPUT=$(sudo -u deploy git pull)
    echo "$PULL_OUTPUT"

    if echo "$PULL_OUTPUT" | grep -q "Already up to date."; then
      echo "✅ No hay cambios para actualizar. Saliendo..."
      sudo -u deploy pm2 start ${empresa_atualizar}-backend
      sudo -u deploy pm2 save
      return 0
    fi
  fi

  echo "📂 Moviéndose a backend..."
  cd /home/deploy/${empresa_atualizar}/backend

  echo "📦 Instalando dependencias..."
  sudo -u deploy npm install --loglevel=error

  echo "⬆️  Actualizando paquetes forzadamente..."
  sudo -u deploy npm update -f 

  echo "📥 Instalando tipos de fs-extra..."
  sudo -u deploy npm install @types/fs-extra --loglevel=error

  echo "🧹 Limpiando carpeta dist..."
  sudo -u deploy rm -rf dist

  echo "🏗️  Compilando proyecto (build)..."
  sudo -u deploy npm run build

  echo "🛢️ Migrando base de datos..."
  sudo -u deploy npx sequelize db:migrate

  echo "🌱 Insertando datos semilla..."
  sudo -u deploy npx sequelize db:seed

  echo "▶️ Iniciando PM2..."
  sudo -u deploy pm2 start ${empresa_atualizar}-backend
  sudo -u deploy pm2 save

  sleep 2
}

#######################################
# Ejecuta db:migrate
# Argumentos:
#   Ninguno
#######################################
backend_db_migrate() {
  print_banner
  printf "${WHITE} 💻 Ejecutando db:migrate...${GRAY_LIGHT}\n\n"

  sleep 2

  sudo -u deploy bash -c "
    cd /home/deploy/${instancia_add}/backend && (
      npx sequelize db:migrate || (
        echo '⚠️ Falló el primer intento, reintentando en 5 segundos...' &&
        sleep 5 &&
        npx sequelize db:migrate
      )
    )
  "

  sleep 2
}


#######################################
# Ejecuta db:seed
# Argumentos:
#   Ninguno
#######################################
backend_db_seed() {
  print_banner
  printf "${WHITE} 💻 Ejecutando db:seed...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npx sequelize db:seed:all
EOF

  sleep 2
}

#######################################
# Inicia el backend usando pm2 en modo producción
# Argumentos:
#   Ninguno
#######################################
backend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  pm2 start dist/server.js --node-args="--experimental-global-webcrypto" --name ${instancia_add}-backend
  pm2 save --force
EOF

  sleep 2
}

#######################################
# Configura nginx para el backend
# Argumentos:
#   Ninguno
#######################################
backend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_hostname=$(echo "${backend_url/https:\/\/}")

sudo su - root << EOF
cat > /etc/nginx/sites-available/${instancia_add}-backend << 'END'
server {
  server_name $backend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${instancia_add}-backend /etc/nginx/sites-enabled
EOF

  echo -e "\n✅ ${WHITE}INSTALACIÓN COMPLETADA${GRAY_LIGHT}\n"
  sleep 2
}

reboot() {
  echo -e "\n✅ ${WHITE}REINICIANDO SERVER${GRAY_LIGHT}\n"
  sudo reboot
}

backend_update_baileys() {
  print_banner
  printf "${WHITE} 💻 Actualizando @whiskeysockets/baileys en backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  cd /home/deploy/${empresa_atualizar}

  sudo -u deploy pm2 stop ${empresa_atualizar}-backend

  cd /home/deploy/${empresa_atualizar}/backend

  sudo -u deploy npm install @whiskeysockets/baileys@latest --loglevel=error

  sudo -u deploy npm run build

  sudo -u deploy pm2 restart ${empresa_atualizar}-backend
  sudo -u deploy pm2 save

  sleep 2
}
