resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id = "reids_cluster"  
  engine = "redis"
  engine_version = "3.2.4"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "${aws_elasticache_parameter_group.default.name}"
  security_group_names = ["${aws_elasticache_security_group.redis.name}"]
  port = 6379
}

resource "aws_elasticache_parameter_group" "default" {
  name = "redis-params"
  family = "redis3.2"
}

resource "aws_security_group" "redis" {
  name = "redis"

  ingress {
    from_port= 5379
    to_port = 5379
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

resource "aws_elasticache_security_group" "redis" {
  name = "elasticache-security-group"
  security_group_names = ["${aws_security_group.redis.name}"]
}

output "redis_public_address" {
  value = "${aws_elasticache_cluster.redis_cluster.cache_nodes.0.address}"
}