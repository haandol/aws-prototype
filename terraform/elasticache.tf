resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id = "reids_cluster"  
  engine = "redis"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis3.2"
  port = 6379
}
