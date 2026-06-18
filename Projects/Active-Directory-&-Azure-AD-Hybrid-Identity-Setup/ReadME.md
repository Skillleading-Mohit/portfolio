# Enterprise Hybrid Identity: Bridging On-Premises AD DS with Microsoft Entra ID


### ***Objective***
The core objective of this project was to architect, deploy, and validate a production-ready Hybrid Identity Lifecycle Management framework. By implementing Microsoft Entra Connect Sync, this project establishes automated identity synchronization and unified access management across an on-premises enterprise environment and cloud infrastructure.

### ***Key Technical Outcomes:***
* Designed an isolated physical-virtual lifecycle simulation environment using an on-premises Hyper-V hypervisor and an Azure Free Subscription.
* Established automatic, outbound directory object mapping (Users, Groups) from an authoritative Active Directory Domain Services (AD DS) source to a Microsoft Entra ID cloud tenant.
* Deployed Password Hash Synchronization (PHS) to unlock Single Sign-On (SSO) capabilities while enforcing centralized authentication boundaries.



### ***Tools Used***
* **Hypervisor:** Microsoft Hyper-V (Hosting the virtualized Local Area Network infrastructure).
* **On-Premises OS:** Windows Server 2016 (Configured as an AD DS Domain Controller).
* **Cloud Platform:** Microsoft Azure Platform (Free Tier Subscription providing Azure global tenant architecture).
* **Identity Engines:** Microsoft Active Directory Domain Services (AD DS) & Microsoft Entra ID (Formerly Azure Active Directory).
* **Synchronization Fabric:** Microsoft Entra Connect Sync Engine (Enforcing secure TLS 1.2 identity mappings).
* **Administration Tools:** Active Directory Users and Computers (ADUC), Microsoft Entra Admin Center (entra.microsoft.com), and PowerShell (Identity validation & delta cycle execution)

### ***Performed Steps***
#### **Step 1: Lab Topology & Base Infrastructure Provisioning:**
* Provisioned a Windows Server 2016 Virtual Machine within Hyper-V with an internal virtual switch.
* Promoted the server to a `Domain Controller` creating a local root forest `(msp.com)` via AD DS.
* Configured an `Enterprise OU structure` ([Check](./Assets/)) to segment identities designated for cloud sync scoping.
* Generated sample directory objects inside the OU using `Active Directory Users and Computers (ADUC)` [link](./Assets/)
* Created and configured `NatNet` on host machine to provide internet access to the `interal virtual switch`
[link](./Assets/)

#### ***Step 2: Microsoft Entra Cloud Architecture***
* Initialized the Microsoft Entra ID tenant using the Azure subscription.
* Navigated to Identity -> Users and provisioned a cloud-only dedicated Hybrid Identity Administrator account.

#### ***Step 3: Entra Connect Synchronization***

* Downloaded the official `Microsoft Entra Connect` installation package onto the local `Entra Connect Server`. - We can install `Entra Connect` on `DC` but in production it is recommended to use a dedicated server for this.

* Ensured that all required ports are accessible. - as mentioned in last point I used a dedicated VM to host `Entra Connect` So, In this setup ***communication must flow securely in two directions: outbound to Microsoft Entra ID and inbound/outbound with your Domain Controllers***

> These are some ports you should allow connection from your `Entra Connect Server` to DC


```
1 `TCP/UDP 389`     `LDAP:` Used to query and read data from Active Directory.

2. `TCP/UDP 53`      `DNS:` Required to resolve Active Directory domain names.

3. `TCP 445`         `SMB:` Used during Seamless Single Sign-On (SSO) and password writeback.

4 `TCP/UDP 88`      `Kerberos:` Needed for authentication and ticket validation.

5 `TCP 3268 & 3269` `Global Catalog:` Used to search for objects across all forests in a multi-domain environment.

6 `TCP 135`        `RPC Endpoint Mapper:` Required for resolving random RPC ports for directory replication services.

7 `TCP 49152-65535` `Dynamic RPC Ports:` Used for password synchronization and initial forest binding.
```
> Connection outbound to Microsoft Entra ID
```
1 `TCP 443` -  Handles all authenticated outbound communication, including syncing data, metadata, and Entra Connect Health services.

2 `TCP 80` -  Used strictly for downloading Certificate Revocation Lists (CRLs) while validating TLS/SSL certificates.

Note: Traffic is strictly outbound. You do not need to open any inbound ports from the internet to your internal network.
```
* Initiated the installation wizard choosing Express Settings for standard topology mapping.

* Authenticated against the cloud endpoint by entering the Hybrid Identity Administrator credentials.

* Authenticated against the on-premises directory using Enterprise Administrator credentials to provision the forest service account configurations.

* Selected Password Hash Synchronization as the global sign-in verification method and checked the box to initiate the initial full synchronization cycle upon completion.

### ***Step 4: Directory Synchronization Verification***

Writing........

## ***Output**
On-prem user can now log into Microsoft cloud environments seamlessly using their original on-prem domain credentials, 

# Performed Steps with Screen Shots


![Step 1](./Assets/Step1-InstallingEntraConnect.png)
Selected Express Settings
![Step 2](./Assets/Step2-InstallingEntraConnectRequiredComponents.png)
![Step 3](./Assets/Step3EntraConnect-ConnectingToEntraID.png)
![Step 4](./Assets/Step4-EntraConnect-ConnectTo_AD_DS.png)

> At this step, you should uncheck  `"Start the syncronization process when configuration completes"` Otherwise this will sync all your objects to the cloud. I skip this as I have to sync all my user right now! I will demonstrate below how you can choose spacific OUs only to sync as well as we will test `attribute based syncronization`

![Step 5](./Assets/Step5-EntraConnect_Ready_to_configure.png)

![Step 6](./Assets/Step6-EntraConnect-configuring.png)
![Step 7](./Assets/Step7-EntraConnect-configuration-complete.png)

## Custom Syncronization
Above I have performed a straight forward installation but in real life we may not require to sync all users to the cloud instead we use `Custom syncronization methods`

So basically we use OU, Group, domain and user attributes based filtering options to filter users to sync to cloud.

### 1. OUs Based Filtering

On the `Entra Connect Server` Search for Microsoft Entra Connect Sync and open it. 

![Step 1](./Assets/EntraConnect-configuring-CustomSync-Step1.png)
> First you have to create an OU and then here you can spacify that OU, after this only the users located in this OU will sync to cloud, Additionaly you can spacify any domain to sync user from, I have only one domain So I skip it for now.

![Step 2](./Assets/EntraConnect-configuring-CustomSync-Step2.png)
> Under `optional features` you can choose how users password will be sync 

![Step 3](./Assets/EntraConnect-configuring-CustomSync-Step3.png)
![Step 4](./Assets/EntraConnect-configuring-CustomSync-Step4.png)
![Step 5](./Assets/EntraConnect-configuring-CustomSync-Step5.png)

### 1. Group Based Filtering


### 1. Object Attribute Based Filtering