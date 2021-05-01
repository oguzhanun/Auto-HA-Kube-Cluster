provider "aws" {
  region  = var.region
  profile = "matt"
}

module "iam" {
  source = "./modules/IAM"
}

resource "aws_security_group" "matt-kube-worker-sg" {
  name = "kube-worker-sec-group-for-matt"
  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "udp"
    from_port = 8472
    to_port = 8472
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress{
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kube-worker-secgroup"
    "kubernetes.io/cluster/mattsCluster" = "owned"
  }
}

resource "aws_security_group" "matt-kube-master-sg" {
  name = "kube-master-sec-group-for-matt"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 2380
    to_port = 2380
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 2379
    to_port = 2379
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10250
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 10251
    to_port = 10251
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 10252
    to_port = 10252
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }

  ingress {
    protocol = "udp"
    from_port = 8472
    to_port = 8472
    security_groups = [aws_security_group.matt-kube-worker-sg.id]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kube-master-secgroup"
    # "kubernetes.io/cluster/mattsCluster" = "owned"
  }
}

resource "aws_instance" "kube-master" {
    ami = "ami-013f17f36f8b1fefb"
    instance_type = "t2.medium"
    iam_instance_profile = module.iam.master_profile_name
    vpc_security_group_ids = [aws_security_group.matt-kube-master-sg.id]
    key_name = "mattskey"
    subnet_id = "subnet-c41ba589"
    availability_zone = "us-east-1a"
    tags = {
        Name = "kube-master"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "Auto-HA-Kube-Cluster"
        Role = "master"
        Id = "1"
    }
}

resource "aws_instance" "kube-master-backup" {
    ami = "ami-013f17f36f8b1fefb"
    instance_type = "t2.medium"
    iam_instance_profile = module.iam.master_profile_name
    vpc_security_group_ids = [aws_security_group.matt-kube-master-sg.id]
    key_name = "mattskey"
    subnet_id = "subnet-c41ba589"
    availability_zone = "us-east-1a"
    tags = {
        Name = "kube-master-backup"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "Auto-HA-Kube-Cluster"
        Role = "masterbackup"
        Id = "1"
    }
}

resource "aws_instance" "worker-1" {
    ami = "ami-013f17f36f8b1fefb"
    instance_type = "t2.medium"
        iam_instance_profile = module.iam.worker_profile_name
    vpc_security_group_ids = [aws_security_group.matt-kube-worker-sg.id]
    key_name = "mattskey"
    subnet_id = "subnet-c41ba589"
    # subnet_id = "subnet-077c9758"
    availability_zone = "us-east-1a"
    tags = {
        Name = "worker-1"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "Auto-HA-Kube-Cluster"
        Role = "worker"
        Id = "1"
    }
}

resource "aws_instance" "worker-2" {
    ami = "ami-013f17f36f8b1fefb"
    instance_type = "t2.medium"
    iam_instance_profile = module.iam.worker_profile_name
    vpc_security_group_ids = [aws_security_group.matt-kube-worker-sg.id]
    key_name = "mattskey"
    subnet_id = "subnet-c41ba589"
    # subnet_id = "subnet-3ccd235a"
    availability_zone = "us-east-1a"
    tags = {
        Name = "worker-2"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "Auto-HA-Kube-Cluster"
        Role = "worker"
        Id = "2"
    }
}

output kube-master-ip {
  value       = aws_instance.kube-master.public_ip
  sensitive   = false
  description = "public ip of the kube-master"
}

output kube-master-backup-ip {
  value       = aws_instance.kube-master-backup.public_ip
  sensitive   = false
  description = "public ip of the kube-master-backup"
}

output worker-1-ip {
  value       = aws_instance.worker-1.public_ip
  sensitive   = false
  description = "public ip of the worker-1"
}

output worker-2-ip {
  value       = aws_instance.worker-2.public_ip
  sensitive   = false
  description = "public ip of the worker-2"
}
