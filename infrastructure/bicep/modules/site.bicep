targetScope = 'resourceGroup'

type appSetting = {
  name: string
  value: string
}

param pattern string
param location string
param serverFarm string
param name string
param kind string
param appSettings appSetting[]

resource Site 'Microsoft.Web/sites@2022-03-01' = {
  name: format(pattern, name)
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  properties: {
    serverFarmId: serverFarm
    siteConfig:{
      appSettings: appSettings
    }
  }
}

output SiteId string = Site.id
output Site object = Site
output SiteName string = Site.name
