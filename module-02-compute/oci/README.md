# FoggyKitchen Multicloud Course – OCI Edition - **Module 02: Compute**

<img src="module-02-compute-oci.jpg" width="400"/>

---

## ⚙️ Objective

In this module, we deploy two compute instances in Oracle Cloud Infrastructure (OCI) as a foundation for a secure and layered multicloud architecture:

- One **public VM** (Bastion Host) deployed in the public subnet with public IP
- One **private VM** (Backend) deployed in the private subnet without public IP
- SSH key pair is automatically generated via `tls_private_key`
- Provisioning using Terraform `null_resource` and `remote-exec` to install and start `nginx` on both VMs
- Backend VM is only accessible via the Bastion using `bastion_host` SSH proxy configuration

This setup mirrors best practices for deploying secure compute infrastructure in OCI. A corresponding version exists in Azure under `/azure/`.

---

## 🔐 Authentication with OCI

Before deploying this configuration, you need to authenticate with OCI. Two recommended options are available:

### Option 1: Using Environment Variables

1. Copy the example setup file:

```bash
cp setup_oci_tf_vars.sh.example setup_oci_tf_vars.sh
```

2. Edit `setup_oci_tf_vars.sh` and provide your credentials:

```bash
export TF_VAR_user_ocid="ocid1.user.oc1..*******"
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..*******"
export TF_VAR_fingerprint="xx:xx:xx:*******:xx:xx"
export TF_VAR_private_key_path="/Users/youruser/.oci/oci_api_key.pem"
export TF_VAR_region="eu-frankfurt-1"
```

3. Load the variables:

```bash
source setup_oci_tf_vars.sh
```

### Option 2: Using `terraform.tfvars`

1. Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit and fill in your OCI credentials:

```hcl
tenancy_ocid       = "ocid1.tenancy.oc1..*******"
user_ocid          = "ocid1.user.oc1..*******"
fingerprint        = "xx:xx:xx:*******:xx:xx"
private_key_path   = "/Users/youruser/.oci/oci_api_key.pem"
region             = "eu-frankfurt-1"
```

---

## 🚀 How to Deploy

1. Clone the repository and navigate to the module directory:

```bash
git clone https://github.com/mlinxfeld/foggykitchen_multicloud.git
cd foggykitchen_multicloud/module-02-compute/oci/
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

After completing this compute module, you can:

- Add a Load Balancer in front of the bastion or backend
- Expand backend use: database, docker host, API server
- Extend to Azure to compare compute provisioning across clouds
- Integrate with DevOps pipelines and remote provisioners

---

## 🔁 Related Modules

- [module-01-networking/oci](../../module-01-networking/oci/) – foundational network
- [module-02-compute/azure](../azure/) – same scenario in Microsoft Azure


---

## 📣 Contributing

This is an open learning project — contributions are welcome!  
Submit a pull request or check out [FoggyKitchen.com](https://foggykitchen.com/) for more updates.

## 🪪 License
Copyright (c) 2025 [FoggyKitchen.com](https://foggykitchen.com/)

Licensed under the Universal Permissive License (UPL), Version 1.0.  
See [LICENSE](../../LICENSE) for details.