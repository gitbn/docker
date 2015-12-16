#!/bin/bash 
#stop si le script si une erreur 
set -e

#log stdout stderr dans log.txt
(

#Menu
PS3="Choix? "
echo " "
echo -e "\033[32m Quel Docker installer sur le serveur? \033[0m"
echo " "
select choix in "Nginx-php-fqm" "MariaDB" "PhpMyAdmin" "quitter (q|Q)";
	do 
		case $REPLY in 
			#Choix 1 : Installation de Nginx-php-fqm
		  1) echo -e "\033[32m Installation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh

			echo " "
			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo " "
		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/richarvey/nginx-php-fpm/
		    docker pull richarvey/nginx-php-fpm

		    echo " "
		    echo -e "\033[32m Lancement du container \033[0m"
		    #création d'un répertoire pour les sites web
		    web="/dock/www/"
		    mkdir -p $web
		    #création de la page test php
		    echo "<?php phpinfo(); ?>" > /dock/www/index.php
		    #exécute docker sur le port 80
		    docker run --name nginx -p 80:80 -v  /dock/www:/usr/share/nginx/html -d richarvey/nginx-php-fpm

		    #récupération de l'IP locale
		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

			#affichage des infos de connexion
		    echo " "
		    echo -e "\033[32m Nginx est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
		 	echo " "
		    echo -e "\033[32m Finito, placer votre site web dans $web \033[0m"
		    break
		    ;;

		    ###################################################################

			#Choix 2 : Installation de MariaDB
		  2) echo -e "\033[32m Installation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh
		    #Outil pour génerer les passwords
			apt-get install -y pwgen

			echo " "
			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo " "
		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/paintedfox/mariadb/
		    docker pull paintedfox/mariadb

		    echo " "
		    echo -e "\033[32m Lancement du container \033[0m"
		    #création d'un repertoire pour la base de données
		    db="/dock/db/"
		    mkdir -p $db
		    #exécute docker sur le port 3306 avec génération de mot de passe
		    docker run -d --name="mariadb" -p 3306:3306 -v $db:/data -e USER="rootsql" -e PASS="$(pwgen -s -1 6)" paintedfox/mariadb
		    sleep 5
		    #récupère le mot de passe généré
		    dockerid=$(docker ps | awk 'NR==2' | awk '{print $1}')
		    dockerpwd=$(docker logs $dockerid | grep MARIADB_PASS | awk -F "=" '{print $2}')

		    #affichage des infos de connexion
		    echo " "
		    echo -e "\033[32m Les identifiants de la bdd sont rootsql / $dockerpwd \033[0m"
		    break
		    ;;

		    ###################################################################
		    
			#Choix 3 : Installation de PhpMyAdmin
		  3) echo -e "\033[32m Installation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh

			echo " "
			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo " "
		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/nazarpc/phpmyadmin/
		    docker pull nazarpc/phpmyadmin

		    echo " "
		    echo -e "\033[32m Lancement du container \033[0m"
		    #demande l'adresse IP du serveur avec la bdd
		    read -p  "Quelle est l'IP  de la base de donnée?" ip
		    #exécute docker avec le port 1234 redirigé sur le port 80
		    docker run -d -p 1234:80 -e MYSQL_PORT_3306_TCP_ADDR=$ip nazarpc/phpmyadmin

		    #récupération de l'IP locale
		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

		    #affichage des infos de connexion
		    echo " "
		    echo -e "\033[32m L'interface PhpMyAdmin est disponible à l'adresse suivante : http://$iplocal:1234 \033[0m"
		    break

			###################################################################

			;;
			#quit avec la touche 4,Q ou q
		  4|Q*|q*) echo -e "\033[32m Byebye"
		     break;; 
		  *) echo "Faute de frappe !";;
	esac
done
) 2>&1 | tee -a log.txt
