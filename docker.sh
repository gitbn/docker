#!/bin/bash 
#stop si le script si une erreur 
set -e

#function installation des tools
toolsPackage(){
	#Outils de base
	apt-get update
	apt-get install -y nano curl wget ntpdate

	#time
	#continue quand même si une erreur de synchro est rencontré (ex: blocage port 123)
	ntpdate -u ntpsophia.sophia.cnrs.fr || true
	}

dockerPackage(){
	#Script pour Debian Jessie

	#Update
	apt-get update
	apt-get install -y apt-transport-https 

	#Dockers repo
	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
	apt-get update

	#Install Dockers
	apt-get install -y docker-engine
	service docker start
}

#log stdout stderr dans log.txt
(

#Menu
PS3="Choix? "
echo " "
echo -e "\033[36mQuel Docker installer sur le serveur? \033[0m"
echo " "
select choix in "Stack LEMP" "Nginx-php-fqm" "MariaDB" "PhpMyAdmin" "quitter (q|Q)";
	do 
		case $REPLY in 
			#choix: Installation de Stack LEMP
		  1) echo -e "\033[36mInstallation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[36mTéléchargement des tools \033[0m"
			#appel à la fonction tools
			toolsPackage

			echo " "
			echo -e "\033[36mInstallation de dockers \033[0m"
		    #appel à la fonction docker
			dockerPackage

		    echo " "
		    echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/dockerfiles/centos-lamp/
		    docker pull dockerfiles/centos-lamp

		    echo " "
		    echo -e "\033[36mLancement du container \033[0m"
		    #création d'un répertoire pour les sites web
		    stack="/dock/www/"
		    mkdir -p $stack
		    #création de la page test php
		    echo "<?php phpinfo(); ?>" > /dock/www/index.php
		    #exécute docker sur le port 80
		    docker run --name nginx -p 80:80 -v  $stack:/usr/share/nginx/html -d richarvey/nginx-php-fpm

		    #récupération de l'IP locale
		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

			#affichage des infos de connexion
		    echo " "
		    echo -e "\033[36mNginx est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
		 	echo " "
		    echo -e "\033[36mFinito, placer votre site web dans $web \033[0m"
		    break
		    ;;

		    ###################################################################

			#choix: Installation de Nginx-php-fqm
		  2) echo -e "\033[36mInstallation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[36mTéléchargement des tools \033[0m"
			#appel à la fonction tools
			toolsPackage

			echo " "
			echo -e "\033[36mInstallation de dockers \033[0m"
		    #appel à la fonction docker
			dockerPackage

		    echo " "
		    echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/richarvey/nginx-php-fpm/
		    docker pull richarvey/nginx-php-fpm

		    echo " "
		    echo -e "\033[36mLancement du container \033[0m"
		    #création d'un répertoire pour les sites web
		    web="/dock/www/"
		    mkdir -p $web
		    #création de la page test php
		    echo "<?php phpinfo(); ?>" > /dock/www/index.php
		    #exécute docker sur le port 80
		    docker run --name nginx -p 80:80 -v  $web:/usr/share/nginx/html -d richarvey/nginx-php-fpm

		    #récupération de l'IP locale
		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

			#affichage des infos de connexion
		    echo " "
		    echo -e "\033[36mNginx est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
		 	echo " "
		    echo -e "\033[36mFinito, placer votre site web dans $web \033[0m"
		    break
		    ;;

		    ###################################################################

			#choix: Installation de MariaDB
		  3) echo -e "\033[36mInstallation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[36mTéléchargement des tools \033[0m"
			#appel à la fonction tools
			toolsPackage
		    #Outil pour génerer les passwords
			apt-get install -y pwgen

			echo " "
			echo -e "\033[36mInstallation de dockers \033[0m"
		    #appel à la fonction docker
			dockerPackage

		    echo " "
		    echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/paintedfox/mariadb/
		    docker pull paintedfox/mariadb

		    echo " "
		    echo -e "\033[36mLancement du container \033[0m"
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
		    echo -e "\033[36mLes identifiants de la bdd sont rootsql / $dockerpwd \033[0m"
		    break
		    ;;

		    ###################################################################
		    
			#choix: Installation de PhpMyAdmin
		  4) echo -e "\033[36mInstallation du container : $choix. \033[0m"
			echo " "
			echo -e "\033[36mTéléchargement des tools \033[0m"
			#appel à la fonction tools
			toolsPackage

			echo " "
			echo -e "\033[36mInstallation de dockers \033[0m"
		    #appel à la fonction docker
			dockerPackage

		    echo " "
		    echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
		    #https://hub.docker.com/r/nazarpc/phpmyadmin/
		    docker pull nazarpc/phpmyadmin

		    echo " "
		    echo -e "\033[36mLancement du container \033[0m"
		    #demande l'adresse IP du serveur avec la bdd
		    read -p  "Quelle est l'IP  de la base de donnée?" ip
		    #exécute docker avec le port 1234 redirigé sur le port 80
		    docker run -d -p 1234:80 -e MYSQL_PORT_3306_TCP_ADDR=$ip nazarpc/phpmyadmin

		    #récupération de l'IP locale
		    iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

		    #affichage des infos de connexion
		    echo " "
		    echo -e "\033[36mL'interface PhpMyAdmin est disponible à l'adresse suivante : http://$iplocal:1234 \033[0m"
		    break

			###################################################################

			;;
			#choix: quit avec la touche 4,Q ou q
		  5|Q*|q*) echo -e "\033[36mByebye \033[0m"
		     break;; 
		  *) echo "Faute de frappe !";;
	esac
done
) 2>&1 | tee -a log.txt