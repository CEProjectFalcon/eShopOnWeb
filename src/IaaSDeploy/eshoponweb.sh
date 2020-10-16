# ASP.NET Core 3.1 runtime
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https
sudo apt-get install -y aspnetcore-runtime-3.1
sudo apt-get autoremove

# nginx
sudo apt-get install -y nginx
sudo service nginx start

# API
sudo mkdir -p /var/www/eshoponweb/api
sudo tar -xzf api.tar.gz -C /var/www/eshoponweb/api
sudo chown -R www-data:www-data /var/www/eshoponweb/api
sed -i "s/<replaceserver>/$1/g" /var/www/eshoponweb/api/appsettings.Production.json
sed -i "s/<replaceuser>/$2/g" /var/www/eshoponweb/api/appsettings.Production.json
sed -i "s/<replacepass>/$3/g" /var/www/eshoponweb/api/appsettings.Production.json
sudo chmod 0400 /var/www/eshoponweb/api/appsettings.Production.json
sudo cp ./kestrel-api.service /etc/systemd/system
sudo systemctl enable kestrel-api.service

# WEB
sudo mkdir -p /var/www/eshoponweb/web
sudo tar -xzf web.tar.gz -C /var/www/eshoponweb/web
sudo chown -R www-data:www-data /var/www/eshoponweb/web
sed -i "s/<replaceserver>/$1/g" /var/www/eshoponweb/web/appsettings.Production.json
sed -i "s/<replaceuser>/$2/g" /var/www/eshoponweb/web/appsettings.Production.json
sed -i "s/<replacepass>/$3/g" /var/www/eshoponweb/web/appsettings.Production.json
sudo chmod 0400 /var/www/eshoponweb/web/appsettings.Production.json
sudo cp ./kestrel-web.service /etc/systemd/system
sudo systemctl enable kestrel-web.service

# Start ASP.NET Core applications
sudo systemctl start kestrel-api.service
sudo systemctl start kestrel-web.service

# nginx proxy configuration
sudo cp -f ./default /etc/nginx/sites-available
sudo nginx -s reload
