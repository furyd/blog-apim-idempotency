targetScope = 'resourceGroup'

param name string = 'functionkey'
param siteName string
param apimName string

resource Function 'Microsoft.Web/sites@2022-03-01' existing = {
  name: siteName
}

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource NamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: name
  parent: ApiManagement
  properties:{
    secret: true
    displayName: name
    value: listkeys('${Function.id}/host/default', '2022-03-01').functionkeys.default
  }
}

output NamedValueId string = NamedValue.id
output NamedValue object = NamedValue
output NamedValueName string = NamedValue.name
