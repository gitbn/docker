#!/bin/bash 
#stop si le script si une erreur 
set -e

#function installation des tools
toolsPackage(){
    #Outils de base
    apt-get update
    apt-get install -y nano curl wget ntpdate apt-transport-https

    #time
    #continue quand même si une erreur de synchro est rencontré (ex: blocage port 123)
    ntpdate -u ntpsophia.sophia.cnrs.fr || true
    }

dockerPackage(){
    #Script pour Debian Jessie

    #Update
    apt-get update

    #Dockers repo
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
    apt-get update

    #Install Dockers
    apt-get install -y docker-engine
    service docker start
}

dockerps(){
    echo
    docker ps -a
    echo
}

promptdocker(){
    echo
    echo -e "\033[36m$choix \033[0m"
    #lance un shell dans le container
    read -p "Nom ou ID du docker ($dockername) ?" name
    if [[ ! -z "$name" ]]; then
        dockername=$name
    fi
}

#log stdout stderr dans log.txt
(
while true
do
    echo
    echo -e "\033[36mDocker \033[0m"
    PS3='Choix? '
    select choix in "Gestion des dockers" "Installation de Docker (Debian)" "Stack LAMP" "Distribué" "Samba" "Exit (q|Q)";
        do
        case $REPLY in
        #gestion des dockers
        1)  back=0
            clear
            while true
                do
                    dockerps
                    PS3='Choix? '
                    select choix in "Bash" "Stop" "Restart" "Remove" "Back";
                        do
                        case $REPLY in
                        1)  promptdocker
                            docker exec -it $dockername bash || true 
                            echo
                            break
                            ;;

                            ###################################################################

                        2)  promptdocker
                            docker stop $dockername || true
                            echo
                            break
                            ;;

                            ###################################################################

                        3)  promptdocker
                            docker restart $dockername || true
                            echo
                            break
                            ;;

                            ###################################################################

                        4)  promptdocker
                            docker stop $dockername && docker rm $dockername || true
                            echo
                            break
                            ;;

                            ###################################################################

                        5)  back=1
                            break
                            ;;

                            ###################################################################

                        *) echo "Faute de frappe !";;
                    esac
                done
                #retour au menu principal
                if [[ $back == 1 ]]; then
                    break
                fi
            done
            break
            ;;

            ###################################################################

        #choix: Installation de Docker
        2)  echo -e "\033[36mInstallation de : $choix. \033[0m"
            echo
            echo -e "\033[36mTéléchargement des tools \033[0m"
            #appel à la fonction tools
            toolsPackage

            echo
            echo -e "\033[36mInstallation de docker \033[0m"
            #appel à la fonction docker
            dockerPackage

            #affichage des infos de connexion
            echo
            echo -e "\033[36mDocker est installé ! \033[0m"
            echo
            break
            ;;

            ###################################################################

        #choix: Installation des containers LAMP
        3)  echo -e "\033[36m$choix \033[0m"
            echo
            echo -e "\033[36mTéléchargement des tools \033[0m"
            #appel à la fonction tools
            toolsPackage

            echo
            echo -e "\033[36mInstallation de docker \033[0m"
            #appel à la fonction docker
            dockerPackage

            echo
            echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
            #https://hub.docker.com/r/dockerfiles/centos-lamp/
            docker pull dockerfiles/centos-lamp

            echo
            echo -e "\033[36mLancement du container \033[0m"
            #création d'un répertoire pour les sites web
            stack="/dock/www/"
            mkdir -p $stack
            #création de la page test php
            echo "<?php phpinfo(); ?>" > /dock/www/index.php
            #exécute docker sur le port 80
            docker run -d -p 80:80 --name lamp -v $stack:/var/www/html/ dockerfiles/centos-lamp

            #récupération de l'IP locale
            iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

            #affichage des infos de connexion
            echo
            echo -e "\033[36mApache est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
            echo
            echo -e "\033[36mFinito, placer votre site web dans $stack \033[0m"
            echo
            break
            ;;

            ###################################################################

        #Version distribué
        4)  back=0
            clear
            while true
                do                    
                    PS3='Choix? '
                    select choix in "Nginx-php-fqm" "MariaDB" "PhpMyAdmin" "Back";
                        do
                        case $REPLY in
                        #Nginx-php-fqm
                        1)  echo -e "\033[36mInstallation du container : $choix. \033[0m"
                            echo
                            echo -e "\033[36mTéléchargement des tools \033[0m"
                            #appel à la fonction tools
                            toolsPackage

                            echo
                            echo -e "\033[36mInstallation de docker \033[0m"
                            #appel à la fonction docker
                            dockerPackage

                            echo
                            echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
                            #https://hub.docker.com/r/richarvey/nginx-php-fpm/
                            docker pull richarvey/nginx-php-fpm

                            echo
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
                            echo
                            echo -e "\033[36mNginx est disponible à l'adresse suivante : http://$iplocal:80 \033[0m"
                            echo
                            echo -e "\033[36mFinito, placer votre site web dans $web \033[0m"
                            break
                            ;;

                            ###################################################################

                        #MariaDB
                        2)  echo -e "\033[36mInstallation du container : $choix. \033[0m"
                            echo
                            echo -e "\033[36mTéléchargement des tools \033[0m"
                            #appel à la fonction tools
                            toolsPackage
                            #Outil pour génerer les passwords
                            apt-get install -y pwgen

                            echo
                            echo -e "\033[36mInstallation de docker \033[0m"
                            #appel à la fonction docker
                            dockerPackage

                            echo
                            echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
                            #https://hub.docker.com/r/paintedfox/mariadb/
                            docker pull paintedfox/mariadb

                            echo
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
                            echo
                            echo -e "\033[36mLes identifiants de la bdd sont rootsql / $dockerpwd \033[0m"
                            break
                            ;;

                            ###################################################################

                        #PhpMyAdmin
                        3)  echo -e "\033[36mInstallation du container : $choix. \033[0m"
                            echo
                            echo -e "\033[36mTéléchargement des tools \033[0m"
                            #appel à la fonction tools
                            toolsPackage

                            echo
                            echo -e "\033[36mInstallation de docker \033[0m"
                            #appel à la fonction docker
                            dockerPackage

                            echo
                            echo -e "\033[36mPull du container, prenez un café le temps du téléchargement! \033[0m"
                            #https://hub.docker.com/r/nazarpc/phpmyadmin/
                            docker pull nazarpc/phpmyadmin

                            echo
                            echo -e "\033[36mLancement du container \033[0m"
                            #demande l'adresse IP du serveur avec la bdd
                            read -p  "Quelle est l'IP  de la base de donnée?" ip
                            #exécute docker avec le port 1234 redirigé sur le port 80
                            docker run -d -p 1234:80 -e MYSQL_PORT_3306_TCP_ADDR=$ip nazarpc/phpmyadmin

                            #récupération de l'IP locale
                            iplocal=$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')

                            #affichage des infos de connexion
                            echo
                            echo -e "\033[36mL'interface PhpMyAdmin est disponible à l'adresse suivante : http://$iplocal:1234 \033[0m"
                            break
                            ;;

                            ###################################################################                    

                        4)  back=1
                            break
                            ;;

                            ###################################################################

                        *) echo "Faute de frappe !";;
                    esac
                done
                #retour au menu principal
                if [[ $back == 1 ]]; then
                    break
                fi
            done
            break
            ;;

            ###################################################################

        #Samba
        5)  echo -e "\033[36mSoon.. \033[0m"
            break
            ;;

            ###################################################################

        #Quit
        6|Q*|q*)
            echo -e "\033[36mBye.. \033[0m"
            exit
            ;;

            ###################################################################

            *) echo "Faute de frappe !";;
        esac
    done
done
) 2>&1 | tee -a log.txt