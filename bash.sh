#!/bin/bash 

(
PS3="Choix du server ?"

select choix in web db pma "quitter (q|Q)"; 

	do 
		case $REPLY in 
		  1) echo -e "\033[32m Installation du serveur : $choix. \033[0m"
			
			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh

			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    docker pull richarvey/nginx-php-fpm

		    echo -e "\033[32m Lancement du container \033[0m"
		    web="/dock/www/"
		    mkdir -p $web
		    echo "<?php phpinfo(); ?>" > /dock/www/index.php
		    docker run --name nginx -p 80:80 -v  /dock/www:/usr/share/nginx/html -d richarvey/nginx-php-fpm

		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

		    echo -e "\033[32m Nginx est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
		 
		    echo -e "\033[32m Finito, placer votre site web dans $web \033[0m"
		    break

		    ###################################################################

			;;
		  2) echo -e "\033[32m Installation du serveur : $choix. \033[0m"

			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh

			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    docker pull paintedfox/mariadb

		    echo -e "\033[32m Lancement du container \033[0m"
		    db="/dock/db/"
		    mkdir -p $db
		    docker run -d -name="mariadb" -p 3306:3306 -v /dock/db:/data -e USER="rootsql" -e PASS="toor" paintedfox/mariadb

		    echo -e "\033[32m optionnel, placer votre dump de la base de données dans $db \033[0m"
		    break

		    ###################################################################
		     
			;;
		  3) echo -e "\033[32m Installation du serveur : $choix. \033[0m"

			echo -e "\033[32m Téléchargement des tools \033[0m"
			chmod 755 $(pwd)/tools.sh
		    $(pwd)/tools.sh

			echo -e "\033[32m Installation de dockers \033[0m"
		    chmod 755 $(pwd)/docker.sh
		    $(pwd)/docker.sh

		    echo -e "\033[32m Pull du container, prenez un café le temps du téléchargement! \033[0m"
		    docker pull nazarpc/phpmyadmin

		    echo -e "\033[32m Lancement du container \033[0m"
		    read -p "Quelle est l'IP  de la base de donnée?" ip
		    docker run -d -p 1234:80 -e MYSQL_PORT_3306_TCP_ADDR=$ip nazarpc/phpmyadmin

		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

		    echo -e "\033[32m L'interface PhpMyAdmin est disponible à l'adresse suivante : http://$iplocal:1234 \033[0m"
		    break

			###################################################################

			;;
		  4|Q*|q*) echo -e "\033[32m Byebye"
		     break;; 
		  *) echo "Faute de frappe !";;
	esac
done
) 2>&1 | tee -a log.txt