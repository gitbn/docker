#!/bin/bash 
#stop si le script si une erreur 
set -e

#log stdout stderr dans log.txt
(

#Menu
PS3="Choix? "
echo " "
echo -e "\033[36mQuel Docker installer sur le serveur? \033[0m"
echo " "
select choix in "menu1" "menu2" "menu3" "Quitter (q|Q)";
	do 
		case $REPLY in 
			#choix: Installation de Stack LAMP
		1)	echo -e "\033[36mInstallation du container : $choix. \033[0m"

			select choix in "sous menu1" "sous menu2" "Quitter (q|Q)";
				do 
					case $REPLY in 
						1)	echo -e "\033[36mInstallation du container : $choix. \033[0m"
							continue
							;;
						2)	echo -e "\033[36mInstallation du container : $choix. \033[0m"
							continue
							;;
						3|Q*|q*) echo -e "\033[36mByebye \033[0m"
							echo -e "\033[36m Retour au menu \033[0m"
							exit
						    break;; 
						  *) echo "Faute de frappe !";;
					esac
				done
			
		    continue
		    ;;

		    ###################################################################

			#choix: Installation de Nginx-php-fqm
		2)	echo -e "\033[36mInstallation du container : $choix. \033[0m"
			
		    ;;

		    ###################################################################

			#choix: Installation de MariaDB
		3)	echo -e "\033[36mInstallation du container : $choix. \033[0m"
			
		    continue
		    ;;

		    ###################################################################

			#choix: quit avec la touche 4,Q ou q
		6|Q*|q*) echo -e "\033[36mByebye \033[0m"
		     break;; 
		  *) echo "Faute de frappe !";;
	esac
done
) 2>&1 | tee -a log.txt
