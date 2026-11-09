# Verification

Set `allowed_http_cidr` to your current public IP with `/32` before applying. Do not use `0.0.0.0/0` for this lab.
```bash
curl -I "$(terraform output -raw url)"
aws ec2 describe-instances --instance-ids "$(terraform output -raw instance_id)" --query 'Reservations[0].Instances[0].State.Name'
```
No SSH ingress is configured. For deeper administration, extend the lab with SSM Session Manager and an instance profile rather than opening port 22.
