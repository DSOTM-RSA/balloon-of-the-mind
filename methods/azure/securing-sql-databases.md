# Securing Azure SQL Databases

Premise: An application hosted on a VM connects to a database hosted on a Azure SQL database logical server. The database holds sensitve customer information such as telephone numbers and addresses. This data should be properly secured.

## Configuring the Database Server

1. Define Parameters

export ADMINUSER='ServerAdmin'
export PASSWORD='AdminPassword'
export SERVERNAME=server$RANDOM
export RESOURCEGROUP=shorebreak
<!-- set the location defined in resource-group  -->
export LOCATION=$(az group show --name shorebreak | jq -r '.location')

2. Create Logical SERVERNAME

az sql server create \
--name $SERVERNAME \
--resource-group $RESOURCEGROUP \
--location $LOCATION \
--admin-user $ADMINUSER \
--admin-password "$PASSWORD"

3. Create Database

az sql db create \
--resource-group $RESOURCEGROUP \
--server $SERVERNAME \
--name sampleDatabase
--sample-name AdeventurWorksLT \
--service-objective Basic

4. Get Connection String for this Database

az sql db show-connection-string \
--client sqlcmd \
--name sampleDatabase \
--server $SERVERNAME | jq -r


## Configuring the Application Server

1. Create the VM

az vm create \
--resource-group $RESOURCEGROUP \
--name appServer \
--image UbuntuLTS \
--size Standard_DS2_v2 \
--generate-ssh-keys

2. Connect to VM

ssh [X.X.X.X]

3. Install mssql.tools 

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

## Restricting Network Access

1. Allow access to Azure Service (and our VM since it has outbound internet access)

Azure Portal \
SQL server \ 
Securtity \
Firewalls and virtual networks \
Allow access to Azure services > ON 


2. Connect to Database

ssh [X.X.X.X]
sqlcmd -S tcp:serverNNNN.database.windows.net,1433 -d sampleDatabase - U '[username]' -U '[password]'


3. Restrict access down to the database-level (using IP address rules)

EXECUTE sp_set_database_firewall_rule N'Alow appServer database rule', '[ip range start]', '[ip range end]'
GO

Azure Portal \
SQL server \ 
Securtity \
Firewalls and virtual networks \
Allow access to Azure services > OFF

3. Restrict access to the server-level (using Ip address rules)

EXECUTE sp_delete_database_firewall_rule N'Allow appServer database level rule';
GO

Firewalls and virtual networks \
RULE NAME > Allow appServer
START IP > [start ip]
END IP > [end ip]

Notes: This method is useful but requires either static IPs or a deffined IP range.
Dynamic IPs that update may lose their connectivity, Virtual network rules are beneficial in these cases.

