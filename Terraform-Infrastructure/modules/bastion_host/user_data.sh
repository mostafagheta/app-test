#!/bin/bash
set -e

# 1. Update system
yum update -y

# 2. Install required packages (curl removed - curl-minimal already ships with AL2023)
yum install -y unzip git jq htop tree nano vim

# 3. Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install \
  --bin-dir /usr/bin \
  --install-dir /usr/local/aws-cli \
  --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# 4. Install kubectl
KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fL -o /tmp/kubectl \
  "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm -f /tmp/kubectl

# 5. Export PATH for all sessions
echo 'export PATH=$PATH:/usr/local/bin' >> /etc/bashrc
export PATH=$PATH:/usr/local/bin

# 6. Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 7. Create eks-manager user
useradd -m -s /bin/bash eks-manager
usermod -aG wheel eks-manager

# 8. Configure AWS credentials
mkdir -p /home/eks-manager/.aws
cat > /home/eks-manager/.aws/credentials << EOF
[default]
aws_access_key_id = ${access_key_id}
aws_secret_access_key = ${secret_access_key}
EOF

cat > /home/eks-manager/.aws/config << EOF
[default]
region = ${aws_region}
output = json
EOF

chown -R eks-manager:eks-manager /home/eks-manager/.aws
chmod 700 /home/eks-manager/.aws
chmod 600 /home/eks-manager/.aws/credentials
chmod 600 /home/eks-manager/.aws/config

# 9. Create kubeconfig
mkdir -p /home/eks-manager/.kube
chown -R eks-manager:eks-manager /home/eks-manager/.kube

sudo -u eks-manager env HOME=/home/eks-manager PATH=$PATH \
  aws eks update-kubeconfig \
  --region ${aws_region} \
  --name ${cluster_name}

# 10. Verify kubectl configuration
chown -R eks-manager:eks-manager /home/eks-manager/.kube

# 11. Create Cluster Autoscaler YAML
cat > /home/eks-manager/cluster-autoscaler.yaml << 'EOF'
${cluster_autoscaler_yaml_content}
EOF

chown eks-manager:eks-manager /home/eks-manager/cluster-autoscaler.yaml
chmod 644 /home/eks-manager/cluster-autoscaler.yaml