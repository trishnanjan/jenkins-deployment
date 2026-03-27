

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow inbound traffic for Jenkins and SSH"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP in production
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

# EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium" # Minimum recommended for Jenkins
  key_name      = "jenkins_key" # Replace with your existing AWS SSH key pair name

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # Bootstrapping Jenkins via User Data
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              
              # Install Java (OpenJDK 21)
              sudo apt-get install -y fontconfig openjdk-21-jre
              
              # Add Jenkins repository and key
              sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
                https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
              echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              
              # Install Jenkins
              sudo apt-get update -y
              sudo apt-get install -y jenkins
              
              # Start and enable Jenkins service
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}