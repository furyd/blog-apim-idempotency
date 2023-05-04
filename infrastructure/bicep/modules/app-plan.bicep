targetScope = 'resourceGroup'

type skuType = {
  tier: string
  name: string
}

param name string = 'plan'
param pattern string
param location string
param sku skuType

resource AppPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: format(pattern, name)
  location: location
  sku: sku
}

output AppPlanId string = AppPlan.id
output AppPlan object = AppPlan
