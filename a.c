#! /bin/bash
	while [[ true ]]; do
		#statements
	
		echo -e "\033[36m$choix \033[0m"
		#lance un shell dans le container
		read -p "Nom ou ID du docker?" if [[ ! -z "$dockername" ]]; then echo $dockername fi name
		if [[ ! -z "$name" ]]; then

		    echo "dans la boucle"
		fi
		dockername=$name
		docker exec -it $dockername bash || true 
		echo

	done