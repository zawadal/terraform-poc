# Terraform - POC

#### Description

Project aims to deliver IaC deployment based on AWS cloud services + combined onpremise automation infrastructure using jenkins, ansible, terraform and Powershell DSC.

#### Design

[![](https://raw.githubusercontent.com/zawadal/terraform-poc/master/POC.png)](https://raw.githubusercontent.com/zawadal/terraform-poc/master/POC.png)

#### Detailed overview

Porject is devided intentionaly into two separate parts: onpremis infrastructure that emulates customer or Atos services and Cloud environment where infrastracture will be deployed.

Onpremis infrastracture consist of following automation elements:
- Jenkins - orchestrator for trigering JOBS,  CICD pipeline triger
- Ansible - configuration manager - executes jobs including terraforming
- Terraform - terraforming cloud services (deploying resources on Cloud)
- Powershell DSC - performs Desired State for Windows Server machines

Jenkins is configured to triger jobs - in this case jobs are Ansible playbooks. First job using Ansible terraform module to perform terraform apply and inject sensitive variables like access_keys and passwords. This passwords are stored in encrypted Ansible vault and being decrypted by Credentials configured in Jenkins during execution. 

In 1st stage - ansible task applies terraform configuration to create 3 cloud Windows 2k16 Server hosts. User data is injected to prepare ground for WSMan remoting, create admin user. 

Output from terraform apply goes to Ansible that parses it and create ansible-inventory for 2nd stage that contains newly created infrastructure. 

In stage 2 ansible executes winrm powershell commands to deliver necesary confguration to newly created infrastructure. Desired State Configuration is powershell-driven Windows internal tool that assures IIS is installed and running. Moreover whenever IIS will be removed or stopped DSC will recognize configuration drift and roll back to rigt state.

