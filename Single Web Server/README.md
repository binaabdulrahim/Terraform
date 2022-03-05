The goal of this exercise is to deploy a web server that can respond to HTTP request. 
First, we will create a bash script that writes "Hello, World" into index.html and runs a tool called busybox on Ubuntu  to fire up a web server on port 8080. 
    The reason we are using port 8080 is because listening to any port less than 1024 requires root user privileges. That means you have to listen on higher-numbered ports. 

<<-EOF and EOF are called heredoc syntax which allow you to create multiline strings without having to insert newline characters. 


By default, AWS does not allow any incoming or outgoing traffic from an EC2 instance but to allow our EC2 instance to receive traffic on port 8080 then we need to create a security group. 
    Use ingree security group to allow incoming tcp traffic on port 8080

Expressions in TF is anything that returns a value. The simpliest type of expressions, literals such as strings and numbers. Reference is another type of expression. 
Reference: allows you to access values from other parts of your code. To acccess the ID of the SG resource, use the resource attribute reference which is the following syntax: <Provider>_<Type>, <Name>_<Atrribute>
    SG exports an attribute called id so it would look like this: aws_security_group.ec2_sg.id --> going to use this for vpc_security_group_ids arugment. 


When you add a reference from one resource to another (like the one above) you create an implicit dependency. What TF does with these dependencies is build a dependency graph then uses them to automatically determine which order it should create resources. Because when TF walks through your dependency tree, it creates as many resoures in parallel as it can. 