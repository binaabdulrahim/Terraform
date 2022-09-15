What is a Terraform State file? 
    Everytime you run Tf, it records info about what infrastructure it created in a tfstate.file. 
    tfstate.file contains a custom JSON format that records a mapping from the Tf resources in config file to the respresentation of those resources in the real worlds. 

    State file is a private API that changes with every release and only meant to use it witin terraform internally. You should not edit the terraform state file by hand or write code that read them directly. 

How does tfstate.file work? 
    Everytime you run a terraform, it can fetch the latest status of your infrastructure from AWS and compare that to what's in your terraform configuration to determine what changes need to be applied 

Why is terraform import used to manipulate the state file? 

tfstate.file for personal vs enterprise use? 

    
What is a Terraform backend? 
    A Terraform backend deteremines how Terraform loads and stores state. The default backend is that stores state file on local disk is called local backend. 
    Remote backend aloow you to store the state file in a remote shared store. A number of remote backends are supported including Amazon S3, Azure Storage, GCP Storage, and HashiCorps TFC, TF pro, and TF Enterprise. 

What issues does a remote backends solve? 
    Manual error: Once a remote backend is configured and you run tf plan or apply, Terraform will automatically load the state file from that backend and state file gets automtically stored in that backend you configured, limiting the manual error. 
    
    Locking:
    Secrets: