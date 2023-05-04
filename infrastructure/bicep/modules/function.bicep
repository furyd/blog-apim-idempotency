targetScope = 'resourceGroup'

type appSetting = {
  name: string
  value: string
}

param deploymentPattern string = '${deployment().name}-{0}'
param pattern string
param location string
param serverFarm string
param name string = 'function'
param storageName string
param appSettings appSetting[]

resource Storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageName
}

module Function 'site.bicep' = {
  name: format(deploymentPattern, 'Function')
  scope: resourceGroup()
  params:{
    pattern: pattern
    location: location
    kind: 'functionapp'
    name: name
    serverFarm: serverFarm
    appSettings: concat(appSettings, [
      {
        name: 'AzureWebJobsStorage'
        value: format('DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1};EndpointSuffix={2}', Storage.name, Storage.listKeys().keys[0].value, environment().suffixes.storage)
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: format('DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1};EndpointSuffix={2}', Storage.name, Storage.listKeys().keys[0].value, environment().suffixes.storage)
      }
    ])
  }
}

output SiteId string = Function.outputs.SiteId
output Site object = Function.outputs.Site
output SiteName string = Function.outputs.SiteName
