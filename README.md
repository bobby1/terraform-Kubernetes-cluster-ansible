# terraform-kubernetes-cluster-ansible
This code is a basic demonstration of ways to create Structured Design Life Cycle (SDLC) deployment cloud environments with minimum effort.  The code uses terraform to create Amazon Web Services (AWS) instances.  And, Ansible is used to push basic tools and configuration to the new server instances and install a security agent.

This code extends the terraform-with-ansible github repository (https://github.com/bobby1/terraform-with-ansible) to add a kubenetes cluster with two controllers and worker nodes.

## Design Principles
* Reusable code: The same code base is used for all environment; implementation differences are set based on the environment or tier for the SDLC.
* SDLC from the start: Development (dev), Staging (stg) and Production (prd) folders are available to allow checkout of the code to implement a project using all basic tiers at the beginning of a project.
* Scalable:  the environment setting allows each environment to scale automatically.  Development environment use micro server instance (t2.micro) to service a small number of developers, staging environments uses medium server instances (t2.medium) to allow a large audience to test the application.  Production environments uses large server instances (t2.large) to be generally available to the Internet.

  ** In the same manner, dev environments will create two server instances.  Stg environments will create four server instances.  And Prd environments will create six server instances automatically

  ** This is an alternative to terraform workspace and does not require workspace setup

* Secure: The code show examples of how to secure user account and application accessibility based on environments.
  
  ** Secure Shell Protocol (SSH) keys can be pre-configured and installed on the server to allow secure sessions with the all the server instances.
  
  ** Access to the server instances is limited based on the environment.  Dev can be configured to only allow developer access.  Stg can be configured to only allow corporate user access.  Prd can be configured to allow general Internet access.

* Flexible: The code can be customized for individual environments, based on your application needs, for example.  the AWS Machine Images (ami) for each region can be preconfigure, without the need to have project specify them for every region. Additional configuration parameters are already in the code to allow for easy customization.  
  
* Auditable: The code creates output and logging where possible.
  ** The public IP and DNS name for servers’ instances created are output in Terraform to allow easy access to the new instance

  ** Scripts on servers create a local trail of activity as well as log to the syslog or remote syslogger.

* Easy to use and maintain:  All code contains a banner with project, usage, pre-requisite and beware sections.  In addition, tags to identify the project, environment and other identifiable information are added where possible.

## Pre-requisites

To use this code base, AWS cli, Terraform and Ansible are required to be installed locally on the server.

   * AWS cli access configuration (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  
   * Terraform by HashiCorp (https://www.terraform.io/)
  
   * Ansible (https://www.ansible.com/)

   * An OpenSSH key-pair must be available to upload to the new environment (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/openssh.html)

## How to use

* To create the example environment using Terraform, in the SDLC directory for the environment to deploy, for example, dev

  $ terraform init

  $ terraform fmt

  $ terraform validate

  $ terraform plan  

    $ terraform plan -out <filename>  is recommended but not required

  $ terraform apply
  
    $ terraform apply <filename>  if -out was used
  
 Once the server instance is created, terraform will output the server’s name and IP.  You can retrieve this output at any time after creating the instances by running 
  
   $ terraform output

Once you have the new instance DNS name information, connect to each instance to ensure your connection and ssh keys work.

for example:  
  ssh ubuntu@ec2-54-92-22-20.compute-1.amazonaws.com 
  and accept the server ssh key into the ssh known-hosts
 
  or
  
  ssh -o StrictHostKeyChecking=accept-new ubuntu@ec2-54-92-22-20.compute-1.amazonaws.com 
  to automatically accept the ssh key

In this example, the controller node and worker nodes are automatically populated into a file in the ansible directory, aws_k8s_hosts rather than the /etc/ansible/hosts file for easier management.

* To install applications and files on the new instances, using Ansible.

  ** Add the server instances to the ansible host list at/etc/ansible/hosts.  The example ansible host files use application grouping to install software.  The new instances should be under the awsTest test host groups.

  ** Go to the directory containing the Ansible playbook

     $ ansible-playbook -i aws_k8s_hosts site.yml

  Check the kubernetes cluster has been provisioned by sshing to the cluster controller and outputting the nodes
    $ ssh ubuntu@<controller-ip or controller DNS public name>
    $ kubectl get nodes

        ubuntu@ip-172-31-21-90:~$ kubectl get nodes
          NAME               STATUS   ROLES    AGE     VERSION
          ip-172-31-21-90    Ready    master   2m38s   v1.18.3
          ip-172-31-29-50    Ready    <none>   83s     v1.18.3
          ip-172-31-47-250   Ready    <none>   83s     v1.18.3

  Your Kubernetes cluster is ready to accept and deploy your container!

If you no longer need the stack,  you can clean up by returning to the iac/env/dev directory and destroy the stack.
  $ terraform destroy

## Roadmap

Please email me for features and additions you would like to see.  

or

## Get Involved

* Submit a proposed code update through a pull request to the `devel` branch.
* Talk to us before making larger changes
  to avoid duplicate efforts. This not only helps everyone
  know what is going on, but it also helps save time and effort if we decide
  some changes are needed.

## Author

Terraform-with-ansible was created by [Bobby Wen] (https://github.com/bobby1) as a primer to Terraform and ansible.

## License

MIT License

https://github.com/bobby1/terraform-with-ansible/blob/main/LICENSE
