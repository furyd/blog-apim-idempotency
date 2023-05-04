targetScope = 'resourceGroup'

param apiName string
param apimName string
param productName string

resource ApiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource Product 'Microsoft.ApiManagement/service/products@2022-08-01' existing = {
  name:productName
  parent:ApiManagement
}

resource ApiProduct 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = {
  name:apiName
  parent:Product
}
