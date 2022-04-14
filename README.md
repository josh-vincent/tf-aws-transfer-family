# tf-aws-transfer-family
Aws Transfer Family, File transfer, SFTP

## Prerequisites 
### IAM 
- iam role must already exist and have permissions to home directory bucket
- s3 Bucket must already exist
- ssh key will have to be created on the source server/computer

This will work across accounts if the iam permissions allow access to the home directory s3 bucket. 
Will have to include it in the s3 bucket policy

Update `main.tf` with your VPC id 
```terraform
locals {
  vpc_id = "vpc-00000000000" # Enter VPC id to attach too.
}
```
Copy a user in the `files\users\` directory will create a new user with the same name as the filename 
update these fields 
```yaml
---
ssh_key: "ssh-rsa BBBB3NzaC1yc2EAAAADAQABAAABgQDmZQWu1bowq4wlN+gaO+nyyerrmagArQXSI493mFTD0Ldyrq0bwzPWS3v6B9LqX0KY3AgdLm7kGdtKwyLHLWMVUYHJcvP2QBaIm3cOc/dihR1HRVfg1v+NJdGmy1QTmgjhNFxjbXN2gaRNOLHIsPoA9hcuHQuqcAUTWa9Ara9ARqd5Pip9a89cCcwOtsXVP6Q5Maer13puouF/wa9VJOHTFkrx7xkca5cLsvoO6qJYq+04LDbST18wQgzkWHMltvERho26YsEVmlUoVH80zN/vCbTnFw17cd3+F4KowO7IZ9DvnDWp2PGZRw2I3+f00xEhzzmJcZSYXkHjsZ2T0tq7Bavv1qIDj7eF2t+N7nCbHVHtIM13/v1wkfmLOYZ09LthWQ0B0pFjyj9TPSD+qq/U3myk2fKslvxEXFFRP9JCCyP7jhKU9FLNCvAQ2YLPJOl27CBs2sbOZAR1bgzBVE5mwzgCGaznS2jRwBgbeMVvtVglw2SHZHjkumIPYCKmgxk= Josh@Joshs-MacBook-Pro.local"
home_directory: "landing\example-one" #don't include the \
role: "example-s3-sftp-role"
bucket_name: "my-example-bucket-1234"
owner: "Bob Smith"
```

update `providers.tf` with your terraform cloud details 
```terraform
terraform {
  # first in terminal run `terraform login`
  cloud {
    organization = "your-org-name"
    #hostname = "app.terraform.io" # Optional; defaults to app.terraform.io
    workspaces {
      name = "tf-aws-transfer-family" #Your workspace name
    }
  }
}
```
```terraform
terraform init 
terraform apply
```

will deploy a sftp server in your vpc and add the users in the `files\users\` directory