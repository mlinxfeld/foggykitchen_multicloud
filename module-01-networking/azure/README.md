# FoggyKitchen Multicloud Course – Azure Edition - **Module 01: Networking**

![](module-01-networking-azure.jpg)

## 🌐 Objective

In this module, we will build the foundational networking layer in Microsoft Azure, equivalent to a standard OCI VCN setup. This includes:

- A new Resource Group
- A Virtual Network (VNet)
- Public and private subnets
- A NAT Gateway for private egress
- A basic Network Security Group (NSG) with SSH access

This is the first step in building a progressively layered multicloud landscape — starting from the network base in Azure. The same logical setup is mirrored in OCI in the corresponding `/oci/` directory.

---

## 🔐 Authentication with Azure

Authentication is handled automatically by the Azure CLI or service principal, depending on your Terraform provider configuration.  
Make sure you're authenticated by running:

```bash
az login
```

---

## 🚀 How to Deploy

1. Clone the repository and navigate to the module directory:

```bash
git clone https://github.com/mlinxfeld/foggykitchen_multicloud.git
cd foggykitchen_multicloud/module-01-networking/azure/
```

2. Initialize the Terraform or OpenTofu project:

```bash
terraform init
# or
tofu init
```

3. Plan the infrastructure:

```bash
terraform plan
# or
tofu plan
```

4. Apply the configuration:

```bash
terraform apply
# or
tofu apply
```

5. Clean up resources when finished:

```bash
terraform destroy
# or
tofu destroy
```

---

## 📘 Next Steps

After completing this networking layer, you will be able to:

- Deploy compute instances into public or private subnets
- Add a Load Balancer in the next module
- Compare this setup directly with OCI’s equivalent under `/oci/`
- Explore advanced topics like NAT, NSG rules, and private DNS

---

## 📣 Contributing

This is an open learning project — contributions are welcome!  
Submit a pull request or check out [FoggyKitchen.com](https://foggykitchen.com/) for more updates.

## 🪪 License
Copyright (c) 2025 [FoggyKitchen.com](https://foggykitchen.com/)

Licensed under the Universal Permissive License (UPL), Version 1.0.  
See [LICENSE](../../LICENSE) for details.
