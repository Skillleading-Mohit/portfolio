# Set variables
$resourceGroup = "RG-Dev-Test"
$location = "EastUS"
$vmName = "VM-Web-1"
$vnetName = "Vnet-Dev-Test"
$subnetName = "Subnet-Dev-Test"
$nsgName = "NSG-Web-1"
$publicIpName = "VM-Web-1-ip"
$nicName = "VM-Web-1-nic"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create Virtual Network and Subnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24"

$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $vnetName `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet $subnetConfig

# Create Public IP
$publicIP = New-AzPublicIpAddress `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $publicIpName `
    -AllocationMethod Static

# Create Network Security Group and Rule (Allow RDP)
$nsgRule = New-AzNetworkSecurityRuleConfig `
    -Name "Allow-RDP" `
    -Protocol "Tcp" `
    -Direction "Inbound" `
    -Priority 1000 `
    -SourceAddressPrefix "*" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 3389 `
    -Access "Allow"

$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name $nsgName `
    -SecurityRules $nsgRule

# Create Network Interface
$nic = New-AzNetworkInterface `
    -Name $nicName `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $publicIP.Id `
    -NetworkSecurityGroupId $nsg.Id

# Set VM Credentials
$cred = Get-Credential   # Enter username and password

# Create VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS1_v2"

$vmConfig = Set-AzVMOperatingSystem `
    -VM $vmConfig `
    -Windows `
    -ComputerName $vmName `
    -Credential $cred `
    -ProvisionVMAgent `
    -EnableAutoUpdate

$vmConfig = Set-AzVMSourceImage `
    -VM $vmConfig `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2019-Datacenter" `
    -Version "latest"

$vmConfig = Add-AzVMNetworkInterface `
    -VM $vmConfig `
    -Id $nic.Id

# Create the VM
New-AzVM `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -VM $vmConfig
