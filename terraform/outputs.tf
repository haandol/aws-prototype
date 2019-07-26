output "graphql_api_uris" {
  value = "${aws_appsync_graphql_api.product_graphql_api.uris}"
}

output "graphql_api_key" {
  value = "${aws_appsync_api_key.product_api_key.key}"
}

output "redis_public_address" {
  value = "${aws_elasticache_cluster.redis_cluster.cache_nodes.0.address}"
}

output "authdb_public_address" {
  value = "${aws_db_instance.authdb.address}"
}