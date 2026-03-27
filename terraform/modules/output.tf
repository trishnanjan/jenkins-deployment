# Output the public IP to easily access the UI
output "jenkins_url" {
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
  description = "The URL to access the Jenkins UI"
}

output "ssh_connection_string" {
  value       = "ssh -i jenkins_key.pem ubuntu@${aws_instance.jenkins_server.public_ip}"
  description = "Command to SSH into the Jenkins server"
}