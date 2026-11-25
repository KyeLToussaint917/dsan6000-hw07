TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
export AWS_DEFAULT_REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
aws ec2 describe-instances --filters "Name=tag:Name,Values=worker-*" "Name=instance-state-name,Values=pending,running" --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,InstanceId,State.Name,PrivateIpAddress]' --output text | sort
