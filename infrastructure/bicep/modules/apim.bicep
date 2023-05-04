targetScope = 'resourceGroup'

type skuType = {
  capacity: int
  name: string
}

type propertiesType = {
  publisherEmail: string
  publisherName: string
}

param name string = 'apim'
param pattern string
param location string
param sku skuType
param properties propertiesType
param tags object

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: format(pattern, name)
  location:location
  properties: properties
  sku: sku
  tags: tags
}

output ApimId string = ApiManagement.id
output Apim object = ApiManagement
output ApimName string = ApiManagement.name
