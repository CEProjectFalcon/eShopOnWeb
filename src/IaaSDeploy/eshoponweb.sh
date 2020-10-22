# ASP.NET Core 3.1 runtime
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https
sudo apt-get install -y aspnetcore-runtime-3.1
sudo apt-get autoremove -y

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

# Mount shares
resourceGroupName="rg-eshoponweb"
storageAccountName="stdeploych001"
fileShareName="dataprotection"
mntPath="/mnt/$storageAccountName/$fileShareName"
sudo mkdir -p $mntPath

if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir "/etc/smbcredentials"
fi

smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
if [ ! -f $smbCredentialFile ]; then
    echo "username=$storageAccountName" | sudo tee $smbCredentialFile > /dev/null
    echo "password=$4" | sudo tee -a $smbCredentialFile > /dev/null
else 
    echo "The credential file $smbCredentialFile already exists, and was not modified."
fi

sudo chmod 600 $smbCredentialFile

smbPath="//stdeploych001.file.core.windows.net/dataprotection"
if [ -z "$(grep $smbPath\ $mntPath /etc/fstab)" ]; then
    echo "$smbPath $mntPath cifs uid=www-data,gid=www-data,nofail,vers=3.0,credentials=$smbCredentialFile,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
fi

sudo mount -a

# Start ASP.NET Core applications
sudo systemctl start kestrel-api.service
sudo systemctl start kestrel-web.service

# nginx proxy configuration
sudo cp -f ./default /etc/nginx/sites-available
sudo nginx -s reload
