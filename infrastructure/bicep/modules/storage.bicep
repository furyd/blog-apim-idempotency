targetScope = 'resourceGroup'

type skuType = {
  name: string
}

param pattern string
param location string
param name string = 'store'

resource Storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: replace(format(pattern, name), '-', '')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

output StorageId string = Storage.id
output Storage object = Storage
output StorageName string = Storage.name
