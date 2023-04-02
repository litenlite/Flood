@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

@description('admin login user for SQL')
param sqlServerAdministratorLogin string

@secure()
@description('admin password for SQL')
param sqlServerAdministratorLoginPassword string

var appServiceAppName = 'flood-${resourceNameSuffix}'
var appServicePlanName = 'flood-plan'
var applicationInsightsName = 'flood-insight'
var storageAccountName = 'flood${resourceNameSuffix}'
var blobsContainerName = 'toyimages'
var sqlServerName = 'flood-${resourceNameSuffix}'

var sqlDatabaseName = 'Toys'
var sqlDatabaseConnectionString = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlServerAdministratorLogin};Password=${sqlServerAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: { name: 'S1' }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'StorageAccountName'
          value: storageAccount.name
        }
        {
          name: 'StorageAccountBlobEndpoint'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'StorageAccountImagesContainerName'
          value: storageAccount::blobService::blobContainer.name
        }
        {
          name: 'SqlDatabaseConnectionString'
          value: sqlDatabaseConnectionString
        }
      ]
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    Flow_Type: 'Bluefield'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }

  resource blobService 'blobServices' = {
    name: 'default'

    resource blobContainer 'containers' = {
      name: blobsContainerName
      properties: {
        publicAccess: 'Blob'
      }
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}

resource sqlServerFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: { name: 'Standard', tier: 'Standard'}
}

output appServiceName string = appServiceApp.name
output appServiceHostName string = appServiceApp.properties.defaultHostName
output storageAccountName string = storageAccount.name
output blobContainerName string = storageAccount::blobService::blobContainer.name
output sqlFQDN string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name

