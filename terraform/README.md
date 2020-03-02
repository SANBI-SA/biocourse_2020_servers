### Terraform for Bioinformatics Course teaching

This directory contains Terraform config for the virtual servers used by JupyterHub and the
virtual Slurm cluster. Before using it, make sure to use `terraform import` so that you
import whatever infrastructure is already existing.

Then to run the whole thing:

```bash
terraform apply -var-file="main.tfvars"
```
