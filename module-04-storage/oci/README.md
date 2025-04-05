# FoggyKitchen Multicloud Course – OCI Edition - **Module 04: Storage**

<img src="module-04-storage-oci.jpg" width="500"/>

---

## ⚙️ Objective

In this module, we extend our Oracle Cloud Infrastructure (OCI) setup with **persistent storage** services:

- **Block Storage (iSCSI)** attached to backend VMs in separate Fault Domains (FD1, FD2)
- **File Storage (NFS)** shared between the backend VMs via a dedicated subnet

This demonstrates how to build a realistic backend architecture with both high-performance block storage and shared NFS for applications requiring distributed file systems.

---

## 🧱 Architecture Components

- `foggykitchen_backend_vm1` and `foggykitchen_backend_vm2` each have dedicated **block volumes** attached using iSCSI
- A new subnet (`foggykitchen_fss_subnet`) hosts the **OCI File Storage Service (FSS)** mount target
- The backend VMs are connected to the FSS via **NFS**
- All VMs remain deployed in separate **Fault Domains (FD1, FD2)** to enhance availability
- Existing networking elements (VCN, NAT, IGW, subnets, NSGs, route tables) are reused or extended

---

## 🛠️ How to Deploy

1. Navigate to this module:

```bash
cd foggykitchen_multicloud/module-04-storage/oci/
```

2. Initialize OpenTofu/Terraform:

```bash
tofu init
# or
terraform init
```

3. Plan the changes:

```bash
tofu plan
# or
terraform plan
```

4. Apply the infrastructure:

```bash
tofu apply
# or
terraform apply
```

---

## 📁 New Elements Introduced

- **Block Volume**: Persistent volume attached via iSCSI
- **File Storage Service (FSS)**: Shared NFS mount for multiple VMs
- **Mount Target**: Allows access to FSS from VCN
- **NSG for FSS Subnet**: Controls access to the mount target

---

## 🧠 Learning Goals

- Understand iSCSI block storage attachment in OCI
- Implement shared file storage using NFS via OCI File Storage
- Practice multi-AZ design using Fault Domains
- Combine compute and storage resources in a modular architecture

---

## 🧹 Cleanup

When done, remove the resources:

```bash
tofu destroy
# or
terraform destroy
```

---

## 🔁 Related Modules

- [module-01-networking/oci](../../module-01-networking/oci/) – foundational VCN with public and private subnets
- [module-02-compute/oci](../../module-02-compute/oci/) – bastion host and backend VMs deployment
- [module-03-loadbalancer/oci](../module-03-loadbalancer/oci/) – introduces public Load Balancer
- [module-04-storage/azure](../module-04-storage/azure/) – same storage concept in Microsoft Azure (coming soon)

---

## 🌐 Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com) for multicloud tutorials, diagrams, and videos.

---

## 🪪 License

Licensed under the Universal Permissive License (UPL), Version 1.0.  
See [LICENSE](../../LICENSE) for more details.

