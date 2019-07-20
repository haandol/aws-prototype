resource "aws_db_instance" "authdb" {
  instance_class = "db.t2.micro"
  allocated_storage = 8
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "9.6.9"
  identifier = "authdb"
  multi_az = false
  name = "authdb"
  username = "master"
  password = "aksekfls123"
  port = 5432
  publicly_accessible = true
  vpc_security_group_ids = ["${aws_security_group.authdb.id}"]
  skip_final_snapshot = true
}

resource "aws_security_group" "authdb" {
  name = "authdb"

  ingress {
    from_port= 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "authdb_public_address" {
  value = "${aws_db_instance.authdb.address}"
}