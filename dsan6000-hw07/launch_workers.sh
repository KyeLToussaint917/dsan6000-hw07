#!/bin/bash
# Launches 3 Spark workers that auto-join the master on this instance (HW7 Steps 1, 3, 4)
set -e
command -v aws >/dev/null || sudo snap install aws-cli --classic >/dev/null
TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
md() { curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/$1; }
export AWS_DEFAULT_REGION=$(md placement/region)
IID=$(md instance-id); MASTER_IP=$(md local-ipv4)
read SG SUBNET AMI KEY < <(aws ec2 describe-instances --instance-ids $IID --query 'Reservations[0].Instances[0].[SecurityGroups[0].GroupId,SubnetId,ImageId,KeyName]' --output text)
echo "master=$MASTER_IP sg=$SG subnet=$SUBNET ami=$AMI key=$KEY region=$AWS_DEFAULT_REGION"
# Step 1: allow all traffic between instances in this security group
aws ec2 authorize-security-group-ingress --group-id $SG --ip-permissions "IpProtocol=-1,UserIdGroupPairs=[{GroupId=$SG}]" >/dev/null 2>&1 && echo "SG rule added" || echo "SG rule already present"
cat > /tmp/worker-userdata.sh <<UD
#!/bin/bash
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openjdk-21-jdk-headless
cd /home/ubuntu
wget -q https://dlcdn.apache.org/spark/spark-4.3.0/spark-4.3.0-bin-hadoop3.tgz || wget -q https://archive.apache.org/dist/spark/spark-4.3.0/spark-4.3.0-bin-hadoop3.tgz
tar -xzf spark-4.3.0-bin-hadoop3.tgz && chown -R ubuntu:ubuntu spark-4.3.0-bin-hadoop3
sudo -u ubuntu /home/ubuntu/spark-4.3.0-bin-hadoop3/sbin/start-worker.sh $MASTER_IP:7077
UD
for i in 1 2 3; do
  ID=$(aws ec2 run-instances --image-id $AMI --instance-type t3.large --key-name $KEY \
    --security-group-ids $SG --subnet-id $SUBNET \
    --iam-instance-profile Name=LabInstanceProfile \
    --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=30}' \
    --user-data file:///tmp/worker-userdata.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=worker-$i}]" \
    --query 'Instances[0].InstanceId' --output text)
  echo "launched worker-$i: $ID"
done
