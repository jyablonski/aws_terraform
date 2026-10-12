# can use this to send a manual, ad hoc message to an sns topic

# sns = boto3.client('sns')
# topic_arn = 'arn:aws:sns:us-east-1:xxx:jacobs-adhoc-sns-topic'
# sns.publish(TopicArn=topic_arn,
#             Message="Hello World!")

locals {
  env_name_adhoc = "Jacobs Practice ad hoc Lambda Trigger"
  env_type_adhoc = "Test" # cant have an apostrophe in the tag name
  adhoc_sns_name = "jacobs-adhoc-sns-topic"
}

resource "aws_sns_topic" "jacobs_adhoc_sns_topic" {
  name       = local.adhoc_sns_name
  fifo_topic = false

  tags = {
    Name        = local.env_name_adhoc
    Environment = local.env_type_adhoc
  }
}
