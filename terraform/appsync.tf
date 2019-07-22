resource "aws_iam_role" "appsync_role" {
  name = "appsync_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "appsync_role_policy" {
  name = "appsync_policy"
  role = "${aws_iam_role.appsync_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.product_table.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_appsync_graphql_api" "product_graphql_api" {
  authentication_type = "API_KEY"
  name = "product_graphql_api"
  schema = <<EOF
type Product {
	id: String!
	shop: String!
	date: Int
	from_at: Int
	to_at: Int
  img: String
  name: String
  link: String
	price: Int
}

type ProductConnection {
  items: [Product]
  nextToken: String
}

type Query {
	getProduct(id: String!, shop: String!, date: Int): Product
	listProducts(filter: TableProductFilterInput, limit: Int, nextToken: String): ProductConnection
  queryProductsByDateIndex(id: String!, first: Int, after: String): ProductConnection
	queryProductsByToAtIndex(id: String!, first: Int, after: String): ProductConnection
	queryProductsByFromAtIndex(id: String!, first: Int, after: String): ProductConnection
}

input TableIntFilterInput {
	ne: Int
	eq: Int
	le: Int
	lt: Int
	ge: Int
	gt: Int
	contains: Int
	notContains: Int
	between: [Int]
}

input TableProductFilterInput {
	price: TableIntFilterInput
	date: TableIntFilterInput
	from_at: TableIntFilterInput
	id: TableStringFilterInput
	shop: TableStringFilterInput
	to_at: TableIntFilterInput
	img: TableStringFilterInput
	name: TableStringFilterInput
	link: TableStringFilterInput
}

input TableStringFilterInput {
	ne: String
	eq: String
	le: String
	lt: String
	ge: String
	gt: String
	contains: String
	notContains: String
	between: [String]
	beginsWith: String
}

schema {
  query: Query
}
EOF
}

resource "aws_appsync_datasource" "product_datasource" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  name = "product_datasource"
  service_role_arn = "${aws_iam_role.appsync_role.arn}"
  type = "AMAZON_DYNAMODB"
  dynamodb_config {
    table_name = "${aws_dynamodb_table.product_table.name}"
  }
}

resource "aws_appsync_api_key" "product_api_key" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
}

resource "aws_appsync_resolver" "get_product" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  field = "getProduct"
  data_source = "${aws_appsync_datasource.product_datasource.name}"
  type = "Query"

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "GetItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id),
    "shop": $util.dynamodb.toDynamoDBJson($ctx.args.shop),
  },
}
EOF

  response_template = <<EOF
$util.toJson($context.result)
EOF
}

resource "aws_appsync_resolver" "list_products" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  field = "listProducts"
  data_source = "${aws_appsync_datasource.product_datasource.name}"
  type = "Query"

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "Scan",
  "filter": #if($context.args.filter) $util.transform.toDynamoDBFilterExpression($ctx.args.filter) #else null #end,
  "limit": $util.defaultIfNull($ctx.args.limit, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
}
EOF

  response_template = <<EOF
$util.toJson($context.result)
EOF
}

resource "aws_appsync_resolver" "query_products_by_date" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  field = "queryProductsByDateIndex"
  data_source = "${aws_appsync_datasource.product_datasource.name}"
  type = "Query"

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "Query",
  "query": {
    "expression": "#id = :id",
    "expressionNames": {
      "#id": "id",
    },
    "expressionValues": {
      ":id": $util.dynamodb.toDynamoDBJson($ctx.args.id),
    },
  },
  "index": "DateIndex",
  "limit": $util.defaultIfNull($ctx.args.first, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.after, null)),
  "scanIndexForward": true,
  "select": "ALL_ATTRIBUTES",
}
EOF

  response_template = <<EOF
$util.toJson($context.result)
EOF
}

resource "aws_appsync_resolver" "query_products_by_to_at" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  field = "queryProductsByToAtIndex"
  data_source = "${aws_appsync_datasource.product_datasource.name}"
  type = "Query"

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "Query",
  "query": {
    "expression": "#id = :id",
    "expressionNames": {
      "#id": "id",
    },
    "expressionValues": {
      ":id": $util.dynamodb.toDynamoDBJson($ctx.args.id),
    },
  },
  "index": "ToAtIndex",
  "limit": $util.defaultIfNull($ctx.args.first, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.after, null)),
  "scanIndexForward": true,
  "select": "ALL_ATTRIBUTES",
}
EOF

  response_template = <<EOF
$util.toJson($context.result)
EOF
}

resource "aws_appsync_resolver" "query_products_by_from_at" {
  api_id = "${aws_appsync_graphql_api.product_graphql_api.id}"
  field = "queryProductsByFromAtIndex"
  data_source = "${aws_appsync_datasource.product_datasource.name}"
  type = "Query"

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "Query",
  "query": {
    "expression": "#id = :id",
    "expressionNames": {
      "#id": "id",
    },
    "expressionValues": {
      ":id": $util.dynamodb.toDynamoDBJson($ctx.args.id),
    },
  },
  "index": "FromAtIndex",
  "limit": $util.defaultIfNull($ctx.args.first, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.after, null)),
  "scanIndexForward": true,
  "select": "ALL_ATTRIBUTES",
}
EOF

  response_template = <<EOF
$util.toJson($context.result)
EOF
}

output "graphql_api_uris" {
  value = "${aws_appsync_graphql_api.product_graphql_api.uris}"
}

output "graphql_api_key" {
  value = "${aws_appsync_api_key.product_api_key.key}"
}
