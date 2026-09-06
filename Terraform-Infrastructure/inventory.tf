# Get the EC2 instances belonging to the EKS node group
data "aws_instances" "eks_workers" {

  filter {
    name   = "tag:aws:eks:cluster-name"
    values = [var.clustername]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [
    module.eks
  ]
}


# Generate Ansible inventory
resource "local_file" "inventory" {

  filename = "${path.root}/inventory.ini"

  content = <<-EOT
[bastion]
bastion ansible_host=${module.bastion_host.public_ip} ansible_user=ec2-user

[eks_workers]
%{for i, ip in data.aws_instances.eks_workers.private_ips~}
worker-${i + 1} ansible_host=${ip} ansible_user=ec2-user
%{endfor}

EOT

  depends_on = [
    module.bastion_host,
    module.eks
  ]
}