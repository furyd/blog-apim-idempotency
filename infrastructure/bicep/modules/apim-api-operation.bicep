targetScope = 'resourceGroup'

param name string = 'operation'
param apiName string
param apimName string
param verb string
param route string
param policy string = ''

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource Api 'Microsoft.ApiManagement/service/apis@2022-08-01' existing = {
  name: apiName
  parent:ApiManagement
}

resource Operation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  name:name
  parent:Api
  properties:{
    method: verb
    urlTemplate: route
    displayName:name
  }
}

resource Policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = if (!empty(policy)) {
  name:'policy'
  parent:Operation
  properties:{
    format:'rawxml'
    value:policy
  }
}

output OperationId string = Operation.id
output Operation object = Operation
output OperationName string = Operation.name
