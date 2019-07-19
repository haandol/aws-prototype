resource "aws_dynamodb_table" "product_table" {
  name = "Product"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"
  range_key = "shop"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "shop"
    type = "S"
  }

  attribute {
    name = "from_at"
    type = "N"
  }

  attribute {
    name = "to_at"
    type = "N"
  }

  attribute {
    name = "date"
    type = "N"
  }
  
  global_secondary_index {
    hash_key = "id"
    name = "DateIndex"
    projection_type = "ALL"
    range_key = "date"
    read_capacity = 0
    write_capacity = 0
  }

  global_secondary_index {
    hash_key = "id"
    name = "FromAtIndex"
    projection_type = "KEYS_ONLY"
    range_key = "from_at"
    read_capacity = 0
    write_capacity = 0
  }

  global_secondary_index {
    hash_key = "id"
    name = "ToAtIndex"
    projection_type = "KEYS_ONLY"
    range_key = "to_at"
    read_capacity = 0
    write_capacity = 0
  }

}