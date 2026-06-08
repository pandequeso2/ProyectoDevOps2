resource "aws_instance" "mysql_srv" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu

    mkdir -p /opt/mysql-init
    cat > /opt/mysql-init/init.sql <<SQL
    CREATE DATABASE IF NOT EXISTS despachosdb;
    CREATE DATABASE IF NOT EXISTS ventasdb;
    GRANT ALL PRIVILEGES ON despachosdb.* TO 'userdb'@'%';
    GRANT ALL PRIVILEGES ON ventasdb.* TO 'userdb'@'%';
    FLUSH PRIVILEGES;
    SQL

    docker run -d \
      --name mysql_db \
      --restart always \
      -p 3306:3306 \
      -v mysql_data:/var/lib/mysql \
      -v /opt/mysql-init:/docker-entrypoint-initdb.d \
      -e MYSQL_ROOT_PASSWORD=rootpassword \
      -e MYSQL_USER=userdb \
      -e MYSQL_PASSWORD=passdb \
      mysql:8.0
  EOF
  )

  tags = { Name = "EC2-MySQL-DevOps" }
}