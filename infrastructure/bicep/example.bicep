targetScope = 'subscription'

@minLength(3)
@maxLength(9)
param projectName string

@minLength(3)
@maxLength(9)
param serviceName string

@allowed([
  'dev'
  'qa'
  'test'
  'pr'
  'pp'
  'production'
])
param environmentName string

param location string

param apimSku object

param apimProperties object

param functionVersion string
param functionRuntime string
param functionRoute string
param functionRouteVerb string

param apimRoute string

param appPlanSku object

var deploymentPattern = '${deployment().name}-{0}'

var pattern = (environmentName == 'production') ? '${projectName}-${serviceName}-{0}' : '${projectName}-${serviceName}-{0}-${environmentName}'

var policy = loadTextContent('policy.xml')

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: format(pattern, 'rg')
  location:location
}

module Storage 'modules/storage.bicep' = {
  name: format(deploymentPattern, 'Storage')
  scope: ResourceGroup
  params:{
    pattern: pattern
    location: location
  }
}

module AppPlan 'modules/app-plan.bicep' = {
  name: format(deploymentPattern, 'AppPlan')
  scope: ResourceGroup
  params:{
    pattern: pattern
    location: location
    sku: {
      name: appPlanSku.name
      tier: appPlanSku.tier
    }
  }
}

module Function 'modules/function.bicep' = {
  name: format(deploymentPattern, 'Function')
  scope: ResourceGroup
  params: {
    pattern: pattern
    location:location
    serverFarm:AppPlan.outputs.AppPlanId
    storageName:Storage.outputs.StorageName
    appSettings:[
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: functionVersion
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: functionRuntime
      }
    ]
  }
}

module ApiManagement 'modules/apim.bicep' = {
  scope: ResourceGroup
  name: format(deploymentPattern, 'ApiManagement')
  params: {
    pattern: pattern
    location:location
    tags: {
      Environment: environmentName
    }
    sku: apimSku
    properties: apimProperties
  }
}

module NamedValueFunctionKey 'modules/namedvalue-functionkey.bicep' = {
  scope: ResourceGroup
  name: format(deploymentPattern, 'NamedValueFunctionKey')
  params:{
    siteName:Function.outputs.SiteName
    apimName:ApiManagement.outputs.ApimName
  }
}

module FunctionBackend 'modules/apim-backend-function.bicep' = {
  scope: ResourceGroup
  name:format(deploymentPattern, 'FunctionBackend')
  params:{
    siteName:Function.outputs.SiteName
    apimName:ApiManagement.outputs.ApimName
    namedValueName:NamedValueFunctionKey.outputs.NamedValueName
  }
}

module FunctionApi 'modules/apim-api.bicep' = {
  scope: ResourceGroup
  name:format(deploymentPattern, 'FunctionApi')
  params:{
    apimName:ApiManagement.outputs.ApimName
    path:apimRoute
  }
}

module ApiOperation 'modules/apim-api-operation.bicep' = {
  scope: ResourceGroup
  name:format(deploymentPattern, 'ApiOperation')
  params:{
    apimName:ApiManagement.outputs.ApimName
    apiName:FunctionApi.outputs.ApiName
    verb:functionRouteVerb
    route:functionRoute
    policy:replace(policy, '{{backend-id}}', FunctionBackend.outputs.FunctionBackendName)
  }
}

module ApiProduct 'modules/apim-product-api.bicep' = {
  scope: ResourceGroup
  name:format(deploymentPattern, 'ApiProduct')
  params:{
    apimName:ApiManagement.outputs.ApimName
    apiName:FunctionApi.outputs.ApiName
    productName:'unlimited'
  }
}
