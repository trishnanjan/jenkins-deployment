# Jenkins Deployment

This repository contains Terraform code to deploy a Jenkins server on AWS EC2.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.9.6
- GitHub repository (for CI/CD)

## Local Setup

1. Clone the repository
2. Configure AWS credentials:
   ```bash
   aws configure
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the changes:
   ```bash
   terraform apply
   ```

## GitHub Actions CI/CD

This repository includes a GitHub Actions workflow for automated Terraform deployments.

### Setup

1. **Deploy the IAM role and policy** (OIDC provider already exists):
   ```bash
   terraform apply -target=module.jenkins_ec2.aws_iam_role.github_actions_terraform -target=module.jenkins_ec2.aws_iam_role_policy.terraform_policy
   ```

2. **Get the role ARN**:
   ```bash
   terraform output github_actions_role_arn
   ```

3. **Go to your GitHub repository Settings > Secrets and variables > Actions**
4. **Add the secret**:
   - `AWS_ACCOUNT_ID`: Your AWS account ID (12-digit number, in this case: `381492087649`)

### Workflow Behavior

- **Pull Requests**: Runs `terraform plan` and comments the plan on the PR
- **Push to main**: Runs `terraform plan` and `apply` automatically

### Manual Deployment

You can also trigger deployments manually from the Actions tab.

## Configuration

- **Region**: Configured for `us-east-1` (update in `provider.tf` if needed)
- **Instance Type**: `t3.medium` (suitable for Jenkins)
- **Security Groups**: Allows SSH (22) and Jenkins UI (8080) from anywhere (restrict in production)
- **GitHub Repository**: Set in `main.tf` for OIDC (update to your repo: `owner/repo`)

## Remote State (Recommended for Production)

For production deployments, configure a remote Terraform state backend:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "jenkins-deployment.tfstate"
    region = "us-east-1"
  }
}
```

## Outputs

After deployment, Terraform will output:
- `jenkins_url`: URL to access Jenkins UI
- `ssh_connection_string`: SSH command to connect to the server

## Security Notes

- **IAM Policy**: The Terraform role has broad permissions (`ec2:*`, `iam:*`, etc.). Restrict to specific resources in production.
- **Security Groups**: Currently allow access from `0.0.0.0/0`. Restrict to your IP ranges in production.
- **OIDC Trust**: The role trusts the specified GitHub repository. Ensure the repository name is correct.

## Troubleshooting

- If Jenkins installation fails, SSH into the instance and run the user_data commands manually
- Check AWS console for instance status and logs
