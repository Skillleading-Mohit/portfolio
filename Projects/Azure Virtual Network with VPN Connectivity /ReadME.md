# Azure VNet with VPN Connectivity Implementation Documentation

## Objective
The goal of this project is to establish a secure, reliable, and scalable hybrid networking environment. It connects an on-premises network to an Azure Virtual Network (VNet) using a Route-Based Site-to-Site (S2S) VPN gateway. This ensures encrypted cross-premises communication over the public internet, allowing secure cloud resource management and seamless workload migration.

## Architecture
The hybrid architecture utilizes a Hub-and-Spoke topology foundation, consisting of the following key components:

*   **Azure VNet (`VNet-Prod-Hub`):** Address space `10.0.0.0/16` located in the IN Central region.
*   **Production Subnet (`Subnet-Prod-Apps`):** Address space `10.0.1.0/24` hosting core cloud workloads.
*   **Gateway Subnet (`GatewaySubnet`):** Dedicated address space `10.0.254.0/24` required to host the Virtual Network Gateway.
*   **Virtual Network Gateway (`VNG-Prod-Hub`):** VpnGw1 SKU, route-based generation 2, utilizing a standard Public IP address.
*   **Local Network Gateway (`LNG-OnPrem-HQ`):** Represents the physical on-premises network object in Azure, referencing the on-premises public IP (``) and local address space (`192.168.1.0/24`).
*   **VPN Connection (`Conn-Hub-To-OnPrem`):** IPSec/IKEv2 tunnel secured via a Pre-Shared Key (PSK).
*   **On-Premises Gateway:** You can use Enterprise-grade firewall/router I am using `Windows Server RRAS VPN` configured with matching IPSec parameters.

## Performed Steps

### Phase 1: Azure Network Infrastructure Provisioning
1.  **Created the Virtual Network:** Deployed `VNet-Prod-Hub` with the address block `10.0.0.0/16`.
2.  **Provisioned Workload Subnet:** Carved out `Subnet-Prod-Apps` (`10.0.1.0/24`) and attached a custom Network Security Group (NSG) to restrict inbound traffic to authorized blocks.
3.  **Provisioned Gateway Subnet:** Allocated the exact designation `GatewaySubnet` with a `/24` prefix (`10.0.254.0/24`) to accommodate gateway routing mechanics.

### Phase 2: Hybrid Connectivity Deployment
1.  **Public IP Allocation:** Provisioned a Standard, Static Public IP address resource named `PIP-VNG-Prod`.
2.  **Deployed Virtual Network Gateway:** Created `VNG-Prod-Hub`, binding it to the `GatewaySubnet` and `PIP-VNG-Prod`. Configured it as a Route-Based VPN with VpnGw1 SKU (deployment took approximately 30 minutes).
3.  **Configured Local Network Gateway:** Created `LNG-OnPrem-HQ` matching the on-premises edge router's public IP address and declared local subnets.
4.  **Established Connection Resource:** Created `Conn-Hub-To-OnPrem` linking the Virtual Network Gateway and Local Network Gateway. Selected Site-to-Site (IPSec) connection type and generated a high-entropy 32-character Pre-Shared Key.

### Phase 3: On-Premises Configuration & Activation
1.  **Downloaded Configuration Script:** Exported the device-specific VPN configuration script directly from the Azure portal connection blade.
2.  **Configured Edge Router:** Applied the configuration script to the on-premises firewall, establishing phase 1 and phase 2 IPSec/IKE parameters matching Azure defaults (AES256, SHA256, DH Group 2).
3.  **Configured Routing:** Defined static routes on-premises to direct traffic destined for `10.0.0.0/16` through the newly built tunnel interface.

### Phase 4: Validation and Testing
1.  **Tunnel Verification:** Verified the Connection resource status shifted to "Connected" in the Azure Portal, confirming active ingress/egress data packets.
2.  **ICMP Connectivity Testing:** Successfully initiated a ping request from a test VM in `Subnet-Prod-Apps` (`10.0.1.4`) to an on-premises host (`192.168.1.50`).
3.  **Path Traversal Validation:** Executed a `traceroute`/`tracert` to verify that data packets securely routed through the VPN tunnel interface without traversing the public internet.

## Outcome
The project successfully delivered an operational, secure hybrid network tunnel. On-premises administrators can now securely access cloud workloads via internal IP addressing schemes without exposing public endpoints. The infrastructure provides reliable encrypted data transit, satisfies strict organizational security compliance requirements, and lays the groundwork for future multi-region hub-and-spoke expansion.
