targetScope = 'resourceGroup'

param name string = 'api'
param apimName string
param path string

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource Api 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name:name
  parent:ApiManagement
  properties:{
    displayName:name
    path:path
    protocols:['https']
  }
}

output ApiId string = Api.id
output Api object = Api
output ApiName string = Api.name
