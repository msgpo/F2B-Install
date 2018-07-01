#!/bin/bash -e
#F2B Installer
#author: elmerfdz
version=v0.1.0-0

#Org Requirements
f2breqname=('Fail2ban' 'cURL')
f2breq=('fail2ban' 'curl')


#config variables
WEB_DIR='/var/www'
SED=`which sed`
CURRENT_DIR=`dirname $0`

F2B_LOC='/etc/fail2ban'
F2B_ACTION_LOC='/etc/fail2ban/action.d'
F2B_FILTER_LOC='/etc/fail2ban/filter.d'
WAN_IP=$(curl ipinfo.io/ip)
INT_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

#Modules
#Organizr Requirement Module
f2binstall_mod() 
	{ 
        echo
        echo -e "\e[1;36m> Updating apt repositories...\e[0m"
		echo
		apt-get update	    
        echo
		for ((i=0; i < "${#f2breqname[@]}"; i++)) 
		do
		    echo -e "\e[1;36m> Installing ${f2breqname[$i]}...\e[0m"
		    echo
		    apt-get -y install ${f2breq[$i]}
		    echo
		done
		echo
    }

f2bconfig_mod() 
	{ 
        echo
        echo -e "\e[1;36m> Configuring Fail2ban...\e[0m"
		echo
        cp $CURRENT_DIR/config/jail.local $F2B_LOC
        $SED -i "s/WANIP/$WAN_IP/g" $F2B_LOC/jail.local
        $SED -i "s/INTIP/$INT_IP/g" $F2B_LOC/jail.local
        chmod 644 $F2B_LOC/jail.local
        cp $CURRENT_DIR/config/action.d/cloudflare-v4.conf $F2B_ACTION_LOC
        chmod 644 $F2B_ACTION_LOC
        cp $CURRENT_DIR/config/filter.d/* $F2B_FILTER_LOC   
        chmod 644 $F2B_FILTER_LOC/*
		echo
        echo -e "\e[1;36m> - Done\e[0m"        
    }

 f2bconfig_cf_mod() 
	{ 
        echo
        echo -e "\e[1;36m> Adding Organizr v2 Jail...\e[0m"
		echo
        echo
        echo "Please enter the full path to your Organizr login log path?"
        echo "- e.g /var/www/organizr_folder_name/db/organizrLoginLog.json"
        read -r ORGLOGPATH
        echo
		echo -e "\e[1;36m> Enter your Cloudflare email.\e[0m"
        read -r cfuser_f2bi
        echo
		echo -e "\e[1;36m> Enter your Cloudflare API.\e[0m" 
		echo "- You can get your Cloudflare API from here: https://dash.cloudflare.com/profile"        
        read -r cftoken_f2bi
        echo
        $SED -i "s/cfuser_f2bi/$cfuser_f2bi/g" $F2B_ACTION_LOC/cloudflare-v4.conf
        $SED -i "s/cftoken_f2bi/$cftoken_f2bi/g" $F2B_ACTION_LOC/cloudflare-v4.conf     
		echo

echo "
## Organizr Jails

[organizr-auth]
enabled  = true
port     = http,https
filter   = organizr-auth-v2
logpath  = $ORGLOGPATH
maxretry = 3

[organizr-auth-cf]
enabled  = true
port     = http,https
filter   = organizr-auth-v2
action   = cloudflare-v4    
logpath  = $ORGLOGPATH
maxretry = 3" >> $F2B_LOC/jail.local

        fail2ban-client reload
        systemctl restart fail2ban
        fail2ban-client reload
   }   


 # Show status of all fail2ban jails.
 # Credit https://gist.github.com/ahmadawais/840098791653a4973a84e27b8451469e
f2bstall_mod() 
    {
        JAILS=($(fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'))
        for JAIL in ${JAILS[@]}
        do
            echo "--------------- JAIL STATUS: $JAIL ---------------"
            echo
            fail2ban-client status $JAIL
            echo
            echo "--------------- ### ---------------"
            echo
        done
}  



show_menus() 
	{
		echo
		echo -e " 	  \e[1;36m|F2B - INSTALLER $version|  \e[0m"
		echo
		echo "| 1.| F2B Install  " 
		echo "| 2.| F2B CloudFlare Action Setup for Organizr "
		echo "| 3.| F2B Complete Install [Install + Config + Organizr Jail + CF Action] "
		echo "| 4.| Show All Jail Status"                
		echo "| x.| Quit 					  "
		echo
		echo
		printf "\e[1;36m> Enter your choice: \e[0m"
	}
read_options(){
		read -r options

		case $options in
	 	"1")
			echo "- Your choice: 1. Fail2ban Install"
			f2binstall_mod
			f2bconfig_mod
			unset DOMAIN
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read
		;;

	 	"2")
			echo "- Your choice: 2. Fail2ban Install"
            f2bconfig_cf_mod
			echo
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read
		;; 


		"3")
        	echo "- Your choice 3: F2B Complete Install [Install + Config + Organizr Jail + CF Action]"
			f2binstall_mod
			f2bconfig_mod
            f2bconfig_cf_mod
    		echo
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read	
		;;

		"4")
        	echo "- Your choice 4: Show All Jails Status"
            f2bstall_mod
    		echo
            echo -e "\e[1;36m> \e[0mPress any key to return to menu..."
			read	
		;;        

		"x")
			exit 0
		;;


	      	esac
	     }

while true 
do
	clear
	show_menus
	read_options
done