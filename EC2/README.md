Terraform can create infrastructure across a wide variety of platforms also called providers such AWS, Azure, GCP. 
You configure the providers in main.tf. In main.tf, you're telling Terraform that you are going to use the provider "aws" and wan tto deploy this infrastructure in "us-east-1" region. 

For each type of provider, there are many type of resources that you can create such as servers, database, and load balancer. resource syntx is: resource "<provider>_<type>" "<name>"{ configuration}

Terraform init: tell TF to scan the code, figure out which providers you're using, and download the code for them. 
Provider code will be downloaded into a .tf folder which is TF's scratch directory. This is usually added to .gitignore. 
It's safe to run tf init multiple times bc command is idempotent. 

Terraform plan: lets you see what TF will do before actual making any changes. Sanity check your code before unleashing it. Anything with + will be created, anything with - will be deleted, and anything with ~ will be modified in place. 

Terraform apply: creates the instance. Shows the same command as plan. 

It's always useful to store terraform cod ein version control, allowing you to share your code and track history of all infrastructure changes. 