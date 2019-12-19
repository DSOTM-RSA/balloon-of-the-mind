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
Security \
Firewalls and virtual networks \
Allow access to Azure services > OFF

3. Restrict access to the server-level (using Ip address rules)

EXECUTE sp_delete_database_firewall_rule N'Allow appServer database level rule';
GO

Firewalls and virtual networks 
RULE NAME > Allow appServer
START IP > [start ip]
END IP > [end ip]

Notes: This method is useful but requires either static IPs or a deffined IP range.
Dynamic IPs that update may lose their connectivity, Virtual network rules are beneficial in these cases.

4. Using a server-level virtual network rule

Firewalls and virtual networks \
Virtual networks \
+ Add existing virtual network \
Virtual network > appServerVNET \
Subnet name / prefix > appServerSubnet / 10.0.0.0/24

Remove previous IP address rule

## Controlling Who Can Access The Database

Authentication is available via SQL authenticatin or Azure Active Directory (AAD)

The admin user created at sever initialisation time can authenticate to any database on the srver as te database owner or "dbo".

Authorization refers to what an identity can do; permissions are granted directly to use accounts and/or database roles.

In practice the application itself should use a contained database user to authenticate directly to the database. See [here](https://docs.microsoft.com/sql/relational-databases/security/contained-database-users-making-your-database-portable?view=sql-server-2017)

1. Create a Database User

sqlcmd -S tcp:serverNNNN.database.windows.net,1433 -d sampleDatabase -U '[username]' -P '[password]' -N -l 30

<!-- creates a containerd user, allows access only to the sampleDatabase database -->
CREATE USER ApplicationUser WITH PASSWORD = 'StrongPassword';
GO

2. Grant Permissions to a User

ALTER ROLE db_datareader ADD MEMBER ApplicationUser;
ALTER ROLE db_datawriter ADD MEMBER ApplicationUser;
GO

<!-- deny access to particular tables -->
DENY SELECT ON SalesLT.Address TO ApplicationUser;
GO

3. Login in as created ApplicationUser

sqlcmd -S tcp:serverNNNN.database.windows.net,1433 -d sampleDatabase -U 'ApplicationUser' -P '[password]' -N -l 30

4. Test getting some data

<!-- authorized to access this data -->
SELECT FirstName, LastName, EmailAddress, Phone FROM SalesLT.Customer;
GO

<!-- not authorized to access this table -->
SELECT * FROM SalesLT.Address;
GO


