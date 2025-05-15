#!/bin/bash
# Kubernetes 安装准备脚本 (适用于所有节点)

echo "==== 开始执行Kubernetes安装准备 ===="

echo "==== 1. 关闭Swap ===="
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab
echo "Swap已关闭"

echo "==== 2. 启用IP转发 ===="
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo sysctl -a | grep ip_forward
cat /proc/sys/net/ipv4/ip_forward
echo "IP转发已启用"

echo "==== 3. 启用 br_netfilter 模块 ===="
modprobe br_netfilter
echo "br_netfilter" >> /etc/modules
cat /proc/sys/net/bridge/bridge-nf-call-iptables
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p
echo "br_netfilter模块已启用"

echo "==== 4. 安装socat ===="
sudo apt update
sudo apt install socat -y
echo "socat已安装"

echo "==== 5. 安装docker ===="
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo "Docker已安装"

echo "==== 6. 安装cri-dockerd ===="
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd_0.3.15.3-0.debian-bookworm_amd64.deb
sudo dpkg -i cri-dockerd_0.3.15.3-0.debian-bookworm_amd64.deb
echo "cri-dockerd已安装"

echo "==== 7. 安装kubeadm, kubelet, kubectl ===="
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "kubeadm, kubelet, kubectl已安装"

echo "==== Kubernetes安装准备完成 ====" 