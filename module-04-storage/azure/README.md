# FoggyKitchen Multicloud Course – Azure Edition - **Module 03: Load Balancer**

<img src="module-03-lb-azure.jpg" width="500"/>

---

## ⚙️ Objective

In this module, we demonstrate how to deploy a simple public Load Balancer in Microsoft Azure that distributes traffic to backend virtual machines running in a private subnet.

Key components include:

- **foggykitchen_loadbalancer** – a public Standard Load Balancer
- **foggykitchen_backend_vm1** and **foggykitchen_backend_vm2** – Linux virtual machines in the private subnet
- **foggykitchen_nat_gw** – NAT Gateway for outbound access
- **foggykitchen_bastion_vm** – jump host in the public subnet with SSH access

Traffic from the Internet is directed to the Load Balancer frontend IP and distributed to the backend VMs.

---

## 🔐 Authentication with Azure

Authentication is handled automatically by the Azure CLI or service principal, depending on your Terraform provider configuration.  
Make sure you're authenticated by running:

```bash
az login
```

---

## 🚀 How to Deploy

1. Clone the repo and navigate to this module:

```bash
git clone https://github.com/mlinxfeld/foggykitchen_multicloud.git
cd foggykitchen_multicloud/module-03-loadbalancer/azure/
```

2. Initialize Terraform/OpenTofu:

```bash
terraform init
# or
tofu init
```

3. Plan the deployment:

```bash
terraform plan
# or
tofu plan
```

4. Apply the infrastructure:

```bash
terraform apply
# or
tofu apply
```

5. Test Load Balancer access:

Visit the public IP address of the Load Balancer in your browser or run:

```bash
curl http://<lb-public-ip>
```

6. When you're done, destroy resources:

```bash
terraform destroy
# or
tofu destroy
```

---

## 🔁 Related Modules

- [module-01-networking/azure](../../module-01-networking/azure/) – foundational network
- [module-02-compute/azure](../../module-02-compute/azure/) – bastion and backend VMs
- [module-03-loadbalancer/oci](../oci/) – same scenario in Oracle Cloud Infrastructure

---

## 📣 Contributing

This project is part of a multicloud educational series. Contributions are welcome!  
Visit [FoggyKitchen.com](https://foggykitchen.com/) to learn more or submit pull requests via GitHub.

---

## 🪪 License
Copyright (c) 2025 [FoggyKitchen.com](https://foggykitchen.com/)

Licensed under the Universal Permissive License (UPL), Version 1.0.  
See [LICENSE](../../LICENSE) for details.
