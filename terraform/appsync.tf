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
  name = "example"
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

resource "aws_appsync_graphql_api" "product_graphql" {
  authentication_type = "API_KEY"
  name = "product appsync graphql"
  schema = <<EOF
type Product {
	date: Int
	from_at: Int
	id: String!
	shop: String!
	to_at: Int
}

type Query {
	product(id: String!, shop: String!): Product
	products(filter: TableProductFilterInput, limit: Int, nextToken: String): [Product]
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
	date: TableIntFilterInput
	from_at: TableIntFilterInput
	id: TableStringFilterInput
	shop: TableStringFilterInput
	to_at: TableIntFilterInput
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
  api_id = "${aws_appsync_graphql_api.product_graphql.id}"
  name = "tf_appsync_example"
  service_role_arn = "${aws_iam_role.appsync_role.arn}"
  type = "AMAZON_DYNAMODB"
  dynamodb_config {
    table_name = "${aws_dynamodb_table.product_table.name}"
  }
}