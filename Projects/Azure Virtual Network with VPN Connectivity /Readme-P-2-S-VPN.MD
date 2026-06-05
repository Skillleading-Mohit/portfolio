# Azure VNet with Point-to-Site (P2S) Remote User VPN Documentation

## Objective
The goal of this project is to establish a secure Point-to-Site (P2S) VPN connection to an Azure Virtual Network (VNet). This enables remote users to connect securely to Azure cloud resources from any location over the internet. The configuration ensures encrypted transit and eliminates the need for exposed public IP endpoints on individual cloud workloads.

## Architecture
The remote user connectivity architecture consists of the following components:

*   **Azure VNet (`VNet-Prod-Hub`):** Address space `10.0.0.0/16` located in the East US region.
*   **Production Subnet (`Subnet-Prod-Apps`):** Address space `10.0.1.0/24` hosting core cloud workloads.
*   **Gateway Subnet (`GatewaySubnet`):** Dedicated address space `10.0.254.0/24`.
*   **Virtual Network Gateway (`VNG-Remote-Users`):** VpnGw1 SKU configured for Point-to-Site connections.
*   **Client Address Pool:** Dedicated IP pool `172.16.0.0/24` allocated strictly to connected remote VPN clients.
*   **Authentication Mechanism:** Microsoft Entra ID (Azure AD) native authentication.
*   **VPN Protocol:** OpenVPN (SSL/TLS based) for cross-platform compatibility.

## Performed Steps

### Phase 1: Azure Network Infrastructure Provisioning
1.  **Created the Virtual Network:** Deployed `VNet-Prod-Hub` with the address block `10.0.0.0/16`.
2.  **Provisioned Workload Subnet:** Carved out `Subnet-Prod-Apps` (`10.0.1.0/24`) for backend applications.
3.  **Provisioned Gateway Subnet:** Allocated the required `GatewaySubnet` prefix (`10.0.254.0/24`) to host the gateway.

### Phase 2: Gateway and Point-to-Site Configuration
1.  **Public IP Allocation:** Provisioned a Standard, Static Public IP address resource named `PIP-VNG-P2S`.
2.  **Deployed Virtual Network Gateway:** Created `VNG-Remote-Users` as a Route-Based VPN with VpnGw1 SKU and tied it to `GatewaySubnet`.
3.  **Configured Point-to-Site Configuration:** 
    *   Added the Address Pool `172.16.0.0/24` for remote users.
    *   Selected `OpenVPN (SSL)` as the Tunnel Type.
    *   Selected `Azure Active Directory` as the Authentication Type.
4.  **Configured Entra ID Authentication:** Entered the official Microsoft Entra ID tenant, audience, and issuer URLs into the gateway settings to authorize user logins.

### Phase 3: Client Profiling and Deployment
1.  **Generated VPN Client Profile:** Generated and downloaded the deployment ZIP package from the Point-to-Site configuration blade.
2.  **Configured Client Software:** Installed the official **Azure VPN Client** application on target user devices (Windows/macOS).
3.  **Imported Settings:** Imported the extracted `azurevpnconfig.xml` profile directly into the Azure VPN Client application.

### Phase 4: Validation and Testing
1.  **User Authentication Verification:** Logged into the Azure VPN client using Entra ID credentials, completing multi-factor authentication (MFA).
2.  **IP Assignment Verification:** Confirmed the client machine received an IP address from the designated `172.16.0.0/24` pool.
3.  **Connectivity Testing:** Successfully initiated an RDP/SSH session to a private VM endpoint inside `Subnet-Prod-Apps` using its private IP (`10.0.1.4`).

## Outcome
The deployment successfully established a secure, enterprise-grade remote access architecture. Remote users can safely connect to internal cloud workloads using native identity management and multi-factor authentication. Traffic remains fully encrypted while bypassing the public internet, satisfying security compliance policies for remote workforces.
