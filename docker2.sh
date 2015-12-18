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

#log stdout stderr dans log.txt
(
while true
do
    echo
    echo -e "\033[36mDocker \033[0m"
    PS3='Choix? '
    select choix in "Gestion des dockers" "Installation de Docker (Debian)" "Stack LAMP" "Samba" "Exit (q|Q)";
        do
        case $REPLY in
        #gestion des dockers
        1)  back=0
            clear
            while true
                do
                    dockerps
                    PS3='Choix? '
                    select choix in "Bash" "Stop" "Restart" "Remove" "back";
                        do
                        case $REPLY in
                        1)  echo
                            echo -e "\033[36m$choix \033[0m"
                            #lance un shell dans le container
                            read -p "Nom ou ID du docker? ($dockername)" name
                            if [[ $name == null ]]; then

                                echo "dans la boucle"
                            fi
                            dockername=$name
                            docker exec -it $dockername bash || true 
                            echo
                            break
                            ;;

                            ###################################################################

                        2)  echo
                            echo -e "\033[36m$choix \033[0m"
                            #stop le container
                            read -p "Nom ou ID du docker? " dockername
                            docker stop $dockername || true
                            echo
                            break
                            ;;

                            ###################################################################

                        3)  echo
                            echo -e "\033[36m$choix \033[0m"
                            #redémarre le container
                            read -p "Nom ou ID du docker? " dockername
                            docker restart $dockername || true
                            echo
                            break
                            ;;

                            ###################################################################

                        4)  echo
                            echo -e "\033[36m$choix \033[0m"
                            #supprimer un container
                            read -p "Nom ou ID du docker? " dockername
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

        #Installation du container Samba
        4)  echo -e "\033[36mSoon.. \033[0m"
            break
            ;;

            ###################################################################

        #Quit
        5|Q*|q*)
            echo -e "\033[36mBye.. \033[0m"
            exit
            ;;

            ###################################################################

            *) echo "Faute de frappe !";;
        esac
    done
done
) 2>&1 | tee -a log.txt