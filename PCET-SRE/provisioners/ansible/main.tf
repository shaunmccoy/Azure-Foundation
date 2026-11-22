locals {
    private_key_path = "~/.ssh/id_rsa"
    user = "azdoagent"
    host_ips = join(",",var.private_ip_addresses)
}

resource "null_resource" "ansible_provisioner" {
    depends_on = [var.private_ip_addresses]
    count = length(var.private_ip_addresses)
    connection {
        type = "ssh"
        host = var.private_ip_addresses[count.index]
        user = local.user
        private_key = file(local.private_key_path)
        agent = false
    }
    
    provisioner "remote-exec" {
        inline = [
            "echo 'Connection Established'"
        ]
    }
    
    provisioner "local-exec" {
        command = "ssh-keygen -f /home/azdoagent/.ssh/known_hosts -R ${var.private_ip_addresses[count.index]}"
    }

    provisioner "local-exec" {
        command = "ssh -o StrictHostKeyChecking=no ${local.user}@${var.private_ip_addresses[count.index]} uptime"
    }
    
    provisioner "local-exec" {
        command = "set ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -u ${local.user} --private-key ${local.private_key_path} -i ${var.private_ip_addresses[count.index]}, ${var.ansible_playbook}"
    }
}
