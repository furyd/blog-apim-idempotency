targetScope = 'resourceGroup'

param name string = 'function-backend'
param siteName string
param apimName string
param namedValueName string
param sitePath string = ''

resource Function 'Microsoft.Web/sites@2022-03-01' existing = {
  name: siteName
}

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}
resource FunctionBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  name:name
  parent:ApiManagement
  properties:{
    url: 'https://${Function.properties.defaultHostName}/${sitePath}'
    description:Function.name
    protocol: 'http'
    resourceId:'${environment().resourceManager}${Function.id}'
    credentials:{
      header:{
        'x-function-key': ['{{${namedValueName}}}']
      }
    }
  }
}

output FunctionBackendId string = FunctionBackend.id
output FunctionBackend object = FunctionBackend
output FunctionBackendName string = FunctionBackend.name
