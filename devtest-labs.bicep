// cf. https://docs.microsoft.com/ja-jp/azure/devtest-labs/create-lab-windows-vm-bicep?tabs=CLI
// 以下のコマンドで作成できる
// az deployment group create --resource-group rg-learning-develop-jpe-001 --template-file devtest-labs.bicep --parameters vmName=vm-bicep-01 userName=vmuser password=<password>

param vmName string

param location string = resourceGroup().location

param vmSize string = 'Standard_D2s_v3'

param userName string

@secure()
param password string

var labVirtualNetworkName = 'Dtllabs-learning-develop-bicep-jpe-001'
var labVirtualNetworkSubnet = 'Dtllabs-learning-develop-bicep-jpe-001Subnet'
var labVirtualNetworkId = labVirtualNetwork.id

// 既存のリソースを参照する場合は existing が必要になる。
resource lab 'Microsoft.DevTestLab/labs@2018-09-15' existing = {
  name: 'labs-learning-develop-bicep-jpe-001'
}

// lab の VirtualNetwork を参照する場合は parent もないとだめっぽい。
resource labVirtualNetwork 'Microsoft.DevTestLab/labs/virtualnetworks@2018-09-15' existing = {
  parent: lab
  name: labVirtualNetworkName
}

// ここで使用している変数は直接設定するとどうも失敗するぽい。原因がよくわからん。
// galleryImageReference の値は一度作る工程で VM 作成直前に ART テンプレートを表示すると記載されている。
resource labVirtualMachine 'Microsoft.DevTestLab/labs/virtualmachines@2018-09-15' = {
  parent: lab
  name: vmName
  location: location
  properties: {
    userName: userName
    password: password
    labVirtualNetworkId: labVirtualNetworkId
    labSubnetName: labVirtualNetworkSubnet
    size: vmSize
    allowClaim: false
    galleryImageReference: {
      offer: 'Windows-10'
      publisher: 'MicrosoftWindowsDesktop'
      sku: 'win10-21h2-pro'
      osType: 'Windows'
      version: 'latest'
    }
  }
}

output labId string = lab.id
