#!/bin/bash

get_mysql_root_password() {
  print_banner
  printf "${WHITE} 💻 Ingresa la ${YELLOW}CONTRASEÑA${WHITE} para el usuario Deploy y la base de datos (No utilizar caracteres especiales):${GRAY_LIGHT}"
  printf "\n\n"
  
  while true; do
    read -p "> " mysql_root_password
    echo

    # Validar que no tenga caracteres especiales (solo letras y números)
    if [[ "$mysql_root_password" =~ ^[a-zA-Z0-9]+$ ]]; then
      break
    else
      echo -e "${RED}❌ La contraseña no debe contener caracteres especiales. Intenta nuevamente.${GRAY_LIGHT}"
    fi
  done
}

get_link_git() {
  print_banner
  
  default_link="https://github.com/MinoruMX/Chasap.git"
  printf "${WHITE} 💻 Ingresa el enlace de ${YELLOW}GITHUB${WHITE} de Chasap que deseas instalar:${GRAY_LIGHT}\n"
  printf "  Presiona Enter para usar el valor por defecto:\n\n"
  printf "  ${default_link}\n\n"
  read -p "> " link_git
  link_git="${link_git:-$default_link}"

  # Si el enlace contiene ':' y '@', pedir el chasap_id
  if [[ "$link_git" == *":"* && "$link_git" == *"@"* ]]; then
    printf "\n${WHITE} 🔐 El enlace requiere autenticación.${GRAY_LIGHT}\n"
    read -p "Ingresa el chasap_id: " CHASAP_ID
  fi
}

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Proporciona un nombre para ${YELLOW}Instancia/Empresa${WHITE} que se instalará (No utilizar espacios ni caracteres especiales, usa solo letras minúsculas):${GRAY_LIGHT}"
  printf "\n\n"

    while true; do
    read -p "> " instancia_add
    echo

   # Validar que solo contenga letras minúsculas y números
    if [[ "$instancia_add" =~ ^[a-z0-9]+$ ]]; then
      # Si es válido, salimos del bucle
      break
    else
      echo -e "${RED}❌ La Instancia no debe contener caracteres especiales ni letras mayúsculas. Intenta nuevamente.${GRAY_LIGHT}"
    fi
  done
}

get_max_whats() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa la cantidad de ${YELLOW}conexiones/Whats${WHITE} que ${instancia_add} podrá registrar:${GRAY_LIGHT}"
  printf "\n\nEj:1000\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa la cantidad de ${YELLOW}usuarios/atendedores${WHITE} que ${instancia_add} podrá registrar:${GRAY_LIGHT}"
  printf "\n\nEj:1000\n\n"
  read -p "> " max_user
}

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el ${YELLOW}dominio${WHITE} del FRONTEND/PANEL para ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el ${YELLOW}dominio${WHITE} del BACKEND/API para ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el ${YELLOW}puerto${WHITE} del FRONTEND para ${instancia_add}; Ej: 3000 A 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}


get_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el ${YELLOW}${WHITE}puerto del BACKEND para esta instancia; Ej: 4000 A 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_redis_port() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el ${YELLOW}${WHITE}puerto de REDIS/AGENDAMIENTO MSG para ${instancia_add}; Ej: 5000 A 5999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " redis_port
}

get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el nombre de la Instancia/Empresa que será eliminada (Ingresa el mismo nombre con el que la instalaste):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el nombre de la Instancia/Empresa que deseas actualizar (Ingresa el mismo nombre con el que la instalaste):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_atualizar
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el nombre de la Instancia/Empresa que deseas bloquear (Ingresa el mismo nombre con el que la instalaste):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el nombre de la Instancia/Empresa que deseas desbloquear (Ingresa el mismo nombre con el que la instalaste):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el nombre de la Instancia/Empresa cuyo dominio deseas cambiar (Recuerda que para cambiar los dominios debes ingresar ambos, incluso si solo deseas cambiar uno):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el NUEVO dominio del FRONTEND/PANEL para ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el NUEVO dominio del BACKEND/API para ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el puerto del FRONTEND de la Instancia/Empresa ${empresa_dominio}; El puerto debe ser el mismo que se informó durante la instalación ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Ingresa el puerto del BACKEND de la Instancia/Empresa ${empresa_dominio}; El puerto debe ser el mismo que se informó durante la instalación ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
  get_mysql_root_password
  get_link_git
  get_instancia_add
  get_max_whats
  get_max_user
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
  fix_502
  reboot
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

software_certbot() {
  get_frontend_url
  get_backend_url
  system_certbot_setup
}

software_logs_backend() {
  get_instancia_add
  backend_logs
}

software_logs_frontend() {
  get_instancia_add
  frontend_logs
}

software_build_ambos() {
  get_instancia_add
  build_ambos
}

software_backend_migrate() {
  get_instancia_add
  backend_migrate
}

software_pm2_install() {
  get_instancia_add
  pm2_reinstall
}

software_backend_build(){
  get_instancia_add
  backend_build
  reboot
}

software_frontend_build(){
  get_instancia_add
  frontend_build
  reboot
}

software_change_version(){
  get_empresa_atualizar
  get_link_git
  change_version
}

software_fix_502(){
  get_empresa_atualizar
  fix_502
  reboot
}

software_update_baileys(){
  get_empresa_atualizar
  backend_update_baileys
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 Bienvenido(a) al Administrador de Chasap, ¡Selecciona la siguiente acción!${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [1] Instalar Chasap\n"
  printf "   [2] Actualizar Chasap\n"
  printf "   [3] Cambiar Versión Chasap\n"
  printf "   [4] Eliminar Chasap\n"
  printf "   [5] Bloquear Chasap\n"
  printf "   [6] Desbloquear Chasap\n"
  printf "   [7] Cambiar dominio Chasap\n"
  printf "   [8] Revisar Logs Backend\n"
  printf "   [9] Revisar Logs Frontend\n"
  printf "   [10] Fix - Rebuilder Front y Back\n"
  printf "   [11] Fix - Backend DB Migrate\n"
  printf "   [12] Fix - PM2 Services\n"
  printf "   [13] Fix - 502 Bad Gateway\n"
  printf "   [14] Fix - Reinstalar Certificado Certbot\n"
  printf "   [15] Actualizar paquete Baileys Backend\n"
  printf "   [20] Actualizar Backend\n"
  printf "   [21] Actualizar Frontend\n"  
  printf "\n"
  read -p "> " option

  case "${option}" in
    1) get_urls ;;
    
    2) 
      software_update 
      exit
      ;;
    3) 
      software_change_version
      exit
      ;;
    4) 
      software_delete 
      exit
      ;;
    5) 
      software_bloquear 
      exit
      ;;
    6) 
      software_desbloquear 
      exit
      ;;
    7) 
      software_dominio 
      exit
      ;;        
    8) 
      software_logs_backend
      exit
      ;;   
    9) 
      software_logs_frontend
      exit
      ;;   
    10) 
      software_build_ambos
      exit
      ;;      
    11) 
      software_backend_migrate
      exit
      ;;
    12) 
      software_pm2_install
      exit
      ;;   
    13) 
      software_fix_502
      exit
      ;;  
    14) 
      software_certbot
      exit
      ;;   
    15)
      software_update_baileys
      exit
      ;;
    20) 
      software_backend_build
      exit
      ;;
    21) 
      software_frontend_build
      exit
      ;;         
    *) exit ;;
  esac
}
