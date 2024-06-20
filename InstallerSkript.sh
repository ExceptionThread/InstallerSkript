#!/bin/bash

echo "Willkommen zum Installations-Guide"
echo "Bitte wählen Sie, was Sie installieren möchten:"
echo "1. Minecraft Server"
echo "2. Apache2"
echo "3. MySQL + PHP + phpMyAdmin"
read -p "Geben Sie die Nummer Ihrer Auswahl ein: " auswahl

read -p "Geben Sie den gewünschten Installationspfad ein: " install_path

if [ ! -d "$install_path" ]; then
  mkdir -p "$install_path"
fi

case $auswahl in
    1)
        echo "Minecraft Server Installation"
        echo "Bitte wählen Sie die Minecraft-Server-Version:"
        echo "1. 1.17.1"
        echo "2. 1.16.5"
        echo "3. 1.12.2"
        read -p "Geben Sie die Nummer der Version ein: " mc_version

        case $mc_version in
            1) version="1.17.1";;
            2) version="1.16.5";;
            3) version="1.12.2";;
            *) echo "Ungültige Auswahl"; exit 1;;
        esac

        apt-get update
        apt-get install -y openjdk-11-jdk wget screen

        mc_server_path="$install_path/minecraft-server"
        mkdir -p "$mc_server_path"
        cd "$mc_server_path"

        wget https://launcher.mojang.com/v1/objects/$(wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | grep -oP '(?<="id": "'$version'", "url": ")[^"]*' | wget -qO- -i - | grep -oP '(?<="server": ")[^"]*').jar -O minecraft_server.jar

        echo "eula=true" > eula.txt

        cat <<EOL > server.properties
# Minecraft server properties
# Generated by installation script
max-players=20
view-distance=10
spawn-monsters=true
generate-structures=true
EOL

        echo "Minecraft Server Version $version wurde installiert und konfiguriert. Starten Sie den Server mit dem Befehl:"
        echo "cd $mc_server_path && screen -S minecraft java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui"
        ;;
    2)
        echo "Apache2 Installation"
        echo "Bitte wählen Sie die Apache2-Version:"
        echo "1. Apache 2.4"
        echo "2. Apache 2.2"
        read -p "Geben Sie die Nummer der Version ein: " apache_version

        case $apache_version in
            1)
                apt-get update
                apt-get install -y apache2
                ;;
            2)
                apt-get update
                apt-get install -y apache2=2.2.*
                ;;
            *)
                echo "Ungültige Auswahl"
                exit 1
                ;;
        esac

        echo "ServerName localhost" >> /etc/apache2/apache2.conf

        echo "<!DOCTYPE html>
<html>
<head>
    <title>Willkommen bei Apache2</title>
</head>
<body>
    <h1>Es hat funktioniert!</h1>
    <p>Die Apache2-Webserver-Installation war erfolgreich.</p>
</body>
</html>" > /var/www/html/index.html

        systemctl restart apache2

        echo "Apache2 Version $apache_version wurde installiert und konfiguriert."
        echo "Sie können die Beispielseite unter http://localhost/ aufrufen."
        ;;
    3)
        echo "MySQL, PHP und phpMyAdmin Installation"
        apt-get update
        apt-get install -y mysql-server php php-mysql

        mysql_secure_installation

        apt-get install -y phpmyadmin

        echo "Bitte geben Sie den Benutzernamen für phpMyAdmin ein:"
        read pma_user
        echo "Bitte geben Sie das Passwort für phpMyAdmin ein:"
        read -s pma_password

        mysql -u root -p -e "CREATE USER '$pma_user'@'localhost' IDENTIFIED BY '$pma_password';"
        mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$pma_user'@'localhost';"
        mysql -u root -p -e "FLUSH PRIVILEGES;"

        echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf
        systemctl restart apache2

        echo "<?php
phpinfo();
?>" > /var/www/html/info.php

        systemctl restart apache2

        echo "MySQL, PHP und phpMyAdmin wurden installiert und konfiguriert."
        echo "Sie können die PHP-Info-Seite unter http://localhost/info.php und phpMyAdmin unter http://localhost/phpmyadmin aufrufen."
        ;;
    *)
        echo "Ungültige Auswahl"
        exit 1
        ;;
esac

echo "Installation abgeschlossen."
