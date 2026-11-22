locals {
    user = "azdoagent"
    host_ips = join(",",var.private_ip_addresses)
}

resource "null_resource" "windows_ansible_provisioner" {
    depends_on = [var.private_ip_addresses]
    count = length(var.private_ip_addresses)
 
  provisioner "local-exec" {
      command = "echo [windows] > hosts\necho ${var.private_ip_addresses[count.index]} >> hosts"
  }

 provisioner "local-exec" {
      command = "export http_proxy=\nexport https_proxy=\nansible-playbook -i hosts ${var.ansible_playbook}"
  }	 	 
}