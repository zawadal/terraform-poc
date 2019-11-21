provider "aws" {
  version = "~> 2.0"
  region     = "eu-central-1"
  access_key = var.aws_access
  secret_key = var.aws_secret
}

resource "aws_security_group" "IISWindows" {
  name        = "IISWindows"
  description = "Allow WINRM Unencrypted,WWW and RDP traffic"
  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ami_name" {}
variable "admin_user" {
    default = ""
}
variable "aws_access" {
    default = ""
}
variable "aws_secret" {
    default = ""
}
variable "admin_pass" {
    default = ""
}


resource "aws_instance" "WWWHosts" {
  count		= 3
  ami           = var.ami_name
  instance_type = "t2.micro"
  key_name 	= "WindowsKeys"
  security_groups = ["IISWindows"]
  get_password_data = true
  tags		= {
    	Name = "IIS"
  }
  depends_on = [aws_security_group.IISWindows]

  user_data  = <<EOF
  <powershell>
	Enable-PSRemoting -Force
	New-NetFirewallRule -Name "WINRM" -Action Allow -Protocol TCP -LocalPort 5985 -DisplayName "WinRM Enabled"
	$password = ConvertTo-SecureString -String '${var.admin_pass}' -Force -AsPlainText
	$user = New-LocalUser -AccountNeverExpires -Description "AWS default admin" -FullName "AWS ADMIN" -Name '${var.admin_user }' -PasswordNeverExpires -Password $password
	Add-LocalGroupMember -Group "Administrators" -Member $user
	Add-LocalGroupMember -Group "Remote Management Users" -Member $user
	Set-ItemProperty -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1
        [DSCLocalConfigurationManager()]
	Configuration LCMConfig
	{
		Node localhost
		{
			Settings
			{
				ConfigurationMode = 'ApplyAndAutoCorrect'
			}
		}
	}

	LCMConfig
	Set-DscLocalConfigurationManager -Path .\LCMConfig -Verbose

        Configuration WWWHostConfig
	{
		Node localhost
		{
			WindowsFeature "IIS_Server"
			{
				Name = "Web-Server"
				Ensure = "Present"
			}
			Service "IIS_Service_running"
			{
				Name = "W3SVC"
				State = "Running"
				DependsOn = "[WindowsFeature]IIS_Server"
			}
		}
	}

	WWWHostConfig
	Start-DSCConfiguration -Path .\WWWHostConfig -Verbose -Force -Wait  
  </powershell>
  EOF
}

output "instances" {
  value = aws_instance.WWWHosts
}
