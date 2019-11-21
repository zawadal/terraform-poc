[windows]
{{ terraform_data }}

[windows:vars]
ansible_port = 5985
ansible_connection = winrm
ansible_winrm_transport = ntlm
ansible_user = "{{ tf_admin_user }}"
ansible_password = "{{ tf_admin_pass }}"
ansible_winrm_server_cert_validation = ignore