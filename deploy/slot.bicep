param location string = resourceGroup().location
param appServiceAppName string
param appServicePlanName string
param appSlotName string

resource appSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  parent: appServiceApp
  name: appSlotName
  location: location
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' existing = {
  name: appServicePlanName
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appServiceAppName
}

output slotName string = appSlot.properties.defaultHostName
