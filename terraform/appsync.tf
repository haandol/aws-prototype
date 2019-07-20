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

type Query {
	product(id: String!, shop: String!, date: Int): Product
	products(filter: TableProductFilterInput): [Product]
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
  api_id = "${aws_appsync_graphql_api.product_graphql.id}"
  name = "product appsync datasource"
  service_role_arn = "${aws_iam_role.appsync_role.arn}"
  type = "AMAZON_DYNAMODB"
  dynamodb_config {
    table_name = "${aws_dynamodb_table.product_table.name}"
  }
}