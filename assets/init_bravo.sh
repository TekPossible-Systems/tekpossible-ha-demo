# Firewall Configuration
dnf install -y firewalld
sudo systemctl enable --now firewalld
firewall_ports=( PORTS )

for port in ${firewall_ports[@]}
do 
    sudo firewall-cmd --add-port="$port/tcp" --permanent
done

sudo firewall-cmd --reload
sudo hostnamectl set-hostname $(uuid -v 4)-BravoServer
sudo rpm --import /etc/pki/rpm-gpg/amazon-gpg-key

# AWS SSM Agent Deploy
sudo rpm -ivh --nodigest --nosignature https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable --now amazon-ssm-agent

# CodeDeploy Stuff
cd /home/ec2-user
sudo dnf install ruby -y
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Update and reboot the system
sudo dnf update -y
# Todo: figure out the right grace time

sudo echo "Hostname: $(hostname -f)" > /var/www/html/index.html
sudo systemctl restart httpd

# TODO: SOFTWARE INSTALL HOOKS
cd /root/software-preinstall/
bash ./install.sh
sleep 30
sudo systemctl restart amazon-ssm-agent