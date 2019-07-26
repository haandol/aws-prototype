resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id = "reids"  
  engine = "redis"
  engine_version = "5.0.4"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis5.0"
  port = 6379
}