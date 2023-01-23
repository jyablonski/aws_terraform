<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.24.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.17.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.24.0 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | 1.17.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_airflow_ecs_module"></a> [airflow\_ecs\_module](#module\_airflow\_ecs\_module) | ./modules/ecs | n/a |
| <a name="module_dbt_ecs_module"></a> [dbt\_ecs\_module](#module\_dbt\_ecs\_module) | ./modules/ecs | n/a |
| <a name="module_ecs_task_alarm"></a> [ecs\_task\_alarm](#module\_ecs\_task\_alarm) | ./modules/alarms | n/a |
| <a name="module_fake_ecs_module"></a> [fake\_ecs\_module](#module\_fake\_ecs\_module) | ./modules/ecs | n/a |
| <a name="module_github_iam_ecr_test"></a> [github\_iam\_ecr\_test](#module\_github\_iam\_ecr\_test) | ./modules/iam_github | n/a |
| <a name="module_lambda_test_module_2"></a> [lambda\_test\_module\_2](#module\_lambda\_test\_module\_2) | ./modules/lambda | n/a |
| <a name="module_ml_ecs_module"></a> [ml\_ecs\_module](#module\_ml\_ecs\_module) | ./modules/ecs | n/a |
| <a name="module_rds_alarm"></a> [rds\_alarm](#module\_rds\_alarm) | ./modules/alarms | n/a |
| <a name="module_s3_test_module"></a> [s3\_test\_module](#module\_s3\_test\_module) | ./modules/s3 | n/a |
| <a name="module_webscrape_ecs_module"></a> [webscrape\_ecs\_module](#module\_webscrape\_ecs\_module) | ./modules/ecs | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.jacobs_website_cert](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.jacobs_website_cert_verifiy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/acm_certificate_validation) | resource |
| [aws_api_gateway_deployment.jacobs_api_gateway_deployment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.api_gateway_health_get_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.api_gateway_product_delete_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.api_gateway_product_get_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.api_gateway_product_patch_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.api_gateway_product_post_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.api_gateway_products_get_integration](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.api_gateway_health_get](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.api_gateway_product_delete](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.api_gateway_product_get](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.api_gateway_product_patch](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.api_gateway_product_post](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.api_gateway_products_get](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.api_gateway_health](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.api_gateway_product](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.api_gateway_products](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.jacobs_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api_policy.jacobs_api_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_rest_api_policy) | resource |
| [aws_api_gateway_stage.jacobs_deployment_stage](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/api_gateway_stage) | resource |
| [aws_autoscaling_group.ecs_ec2_cluster_asg](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/autoscaling_group) | resource |
| [aws_cloudfront_distribution.jacobs_website_api_distribution](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.jacobs_website_s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.jacobs_website_origin_identity](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudwatch_event_rule.step_functions_schedule](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.step_function_event_target](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.aws_stepfunction_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_adhoc_sns_ecs_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_adhoc_sns_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_es_cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_glue_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_graphql_api_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_graphql_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_kinesis_firehose_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_lambda_dynamodb_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_rest_api_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.jacobs_sqs_lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.jacobs_es_cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_db_instance.jacobs_rds_tf](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.jacobs_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.jacobs_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/db_subnet_group) | resource |
| [aws_dms_endpoint.jacobs_dms_postgres_source](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/dms_endpoint) | resource |
| [aws_dms_endpoint.jacobs_dms_s3_target](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/dms_endpoint) | resource |
| [aws_dms_replication_instance.jacobs_replication_instance](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/dms_replication_instance) | resource |
| [aws_dms_replication_subnet_group.jacobs_replication_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/dms_replication_subnet_group) | resource |
| [aws_dynamodb_table.jacobs_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/dynamodb_table) | resource |
| [aws_ecr_lifecycle_policy.jacobs_repo_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.jacobs_repo](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecr_repository) | resource |
| [aws_ecs_capacity_provider.ecs_ec2_cluster_config](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.ecs_ec2_cluster](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster.jacobs_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ecs_cluster_provider](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_glue_catalog_database.aws_glue_catalog_database_test](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_table.aws_glue_catalog_table_injuries](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/glue_catalog_table) | resource |
| [aws_iam_group.jacobs_github_group](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.jacobs_github_group_attach](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy_attachment.jacobs_github_group_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_instance_profile.ecs_ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.github_provider](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.ecs_ec2_cs_role_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_ec2_cs_role_policy_sts](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_ec2_role_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_s3_website_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.glue_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.graphql_github_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.jacobs_lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.jacobs_stepfunction_event_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.jacobs_stepfunction_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.jacobs_stepfunction_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_es_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_sns_ecs_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_sns_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rest_api_github_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.website_github_oidc_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_ec2_role_cs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.github_oidc_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.graphql_github_oidc_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_adhoc_sns_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_dms_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_ecs_ecr_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_ecs_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_firehose_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_glue_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_graphql_api_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_graphql_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_lambda_dynamodb_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_lambda_es_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_lambda_s3_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_rest_api_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_stepfunctions_event_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.jacobs_stepfunctions_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.rest_api_github_oidc_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role.website_github_oidc_role](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_ec2_role_attach1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_ec2_role_attach3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_ec2_role_cs_attach1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_adhoc_sns_lambda_log_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_adhoc_sns_lambda_log_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_adhoc_sns_lambda_log_attachment_3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_adhoc_sns_lambda_log_attachment_4](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_adhoc_sns_lambda_log_attachment_5](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_dms_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_dms_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_ecs_ecr_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_ecs_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_ecs_role_attachment_cs_sts](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_ecs_role_attachment_s3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_ecs_role_attachment_ses](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_github_s3_website_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_glue_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_graphql_api_lambda_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_graphql_eventbridge_rule_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_graphql_github_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_graphql_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_graphql_sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_kinesis_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_kinesis_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_kinesis_role_attachment4](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_dynamodb_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_dynamodb_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_es_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_es_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_attachment_4](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_attachment_5](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_attachment_6](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_lambda_s3_role_attachment3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_rest_api_github_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_rest_api_lambda_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_event_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment_cloudwatch_events](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_stepfunctions_role_attachment_ses](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.jacobs_website_github_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.jacobs_airflow_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_deta_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_github_s3_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_github_s3_website_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_github_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_mlflow_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user.jacobs_terraform_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.jacobs_deta_user_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_ecr](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_execution](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_s3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_ses](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_airflow_user_attachment_ssm](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_github_s3_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_github_s3_website_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_mlflow_user_attachment_s3](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.jacobs_terraform_user_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_internet_gateway.jacobs_gw](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/internet_gateway) | resource |
| [aws_key_pair.airflow_ec2_key](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/key_pair) | resource |
| [aws_key_pair.mlflow_ec2_key](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/key_pair) | resource |
| [aws_kinesis_firehose_delivery_stream.jacobs_kinesis_firehose_stream](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_lambda_function.jacobs_adhoc_sns_ecs_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.jacobs_graphql_api_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.jacobs_lambda_dynamodb_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.jacobs_rest_api_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.jacobs_s3_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.jacobs_s3_sqs_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.jacobs_graphql_api_lambda_function_url](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function_url) | resource |
| [aws_lambda_function_url.jacobs_rest_api_lambda_function_url](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.allow_adhoc_sns_ecs_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_alb_graphql_execution](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_bucket1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_health](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_product](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_product_delete](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_product_patch](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_product_post](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.apigw_lambda_products_get](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lambda_permission) | resource |
| [aws_launch_template.ecs_launch_template](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/launch_template) | resource |
| [aws_lb.graphql_alb](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lb) | resource |
| [aws_lb_listener.graphql_alb_https_listener](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.graphql_alb_certificate_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_target_group.graphql_alb_tg](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.graphql_alb_attachment](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.jacobs_website_route53_record](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_record) | resource |
| [aws_route53_record.jacobs_website_route53_record_api](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_record) | resource |
| [aws_route53_record.jacobs_website_route53_record_cert](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_record) | resource |
| [aws_route53_record.jacobs_website_route53_record_graphql](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_record) | resource |
| [aws_route53_record.jacobs_website_route53_record_www](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_record) | resource |
| [aws_route53_zone.jacobs_website_zone](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route53_zone) | resource |
| [aws_route_table.jacobs_public_route_table](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route_table) | resource |
| [aws_route_table_association.jacobs_public_route](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.jacobs_public_route_2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.jacobs_bucket_tf](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jacobs_bucket_tf_dev](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jacobs_bucket_website](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jacobs_bucket_website_link](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jacobs_kinesis_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jacobs_sqs_sns_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jyablonski_lambda_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jyablonski_mlflow_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jyablonski_tf_cicd_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.jyablonski_unhappy_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.jacobs_bucket_website_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jacobs_bucket_website_link_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jacobs_sqs_sns_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jyablonski_bucket_tf_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jyablonski_bucket_tf_acl_dev](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jyablonski_lambda_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jyablonski_tf_cicd_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.jyablonski_unhappy_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.kinesis_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.jacobs_bucket_dev_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.jacobs_bucket_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.allow_access_from_another_account](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.allow_access_from_another_account_dev](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.jacobs_bucket_website_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.jacobs_bucket_tf_access](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.jacobs_bucket_tf_access_dev](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_website_configuration.jacobs_bucket_website_config](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_security_group.jacobs_rds_security_group_tf](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/security_group) | resource |
| [aws_security_group.jacobs_task_security_group_tf](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/security_group) | resource |
| [aws_sfn_state_machine.jacobs_state_machine](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sfn_state_machine) | resource |
| [aws_sns_topic.jacobs_adhoc_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic.jacobs_graphql_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic.jacobs_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.enable_adhoc_lambda_sns_ecs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.jacobs_graphql_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.jacobs_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/sqs_queue) | resource |
| [aws_ssm_parameter.jacobs_ssm_dbt_prac_key](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_prac_public](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_prac_secret](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_rds_db_name](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_rds_host](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_rds_pw](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_rds_schema](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_rds_user](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_sg_task](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_subnet1](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.jacobs_ssm_subnet2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/ssm_parameter) | resource |
| [aws_subnet.jacobs_public_subnet](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/subnet) | resource |
| [aws_subnet.jacobs_public_subnet_2](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/subnet) | resource |
| [aws_vpc.jacobs_vpc_tf](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/resources/vpc) | resource |
| [postgresql_database.nba_db_prod](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/database) | resource |
| [postgresql_grant.rest_api_read_access](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/grant) | resource |
| [postgresql_grant.shiny_read_access](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/grant) | resource |
| [postgresql_grant.shiny_read_access_ml](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/grant) | resource |
| [postgresql_role.dbt_role](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/role) | resource |
| [postgresql_role.python_scrape_role](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/role) | resource |
| [postgresql_role.rest_api_read_role](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/role) | resource |
| [postgresql_role.shiny_read_role](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/role) | resource |
| [postgresql_schema.ad_hoc_analytics](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.ml_models](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.nba_prep](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.nba_prod](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.nba_prod_jy](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.nba_source](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.nba_staging](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.operations](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [postgresql_schema.snapshots](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.17.1/docs/resources/schema) | resource |
| [archive_file.default](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_adhoc_sns_fake_ecs_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_dynamodb_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_sqs](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.github_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.graphql_github_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.jacobs_es_cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rest_api_github_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.website_github_policy](https://registry.terraform.io/providers/hashicorp/aws/4.24.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default Tags for AWS Resources | `map(string)` | <pre>{<br>  "Environment": "Dev",<br>  "Project": "Test Project"<br>}</pre> | no |
| <a name="input_ecs_pagerduty_endpoint"></a> [ecs\_pagerduty\_endpoint](#input\_ecs\_pagerduty\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_es_master_pw"></a> [es\_master\_pw](#input\_es\_master\_pw) | n/a | `string` | n/a | yes |
| <a name="input_es_master_user"></a> [es\_master\_user](#input\_es\_master\_user) | n/a | `string` | n/a | yes |
| <a name="input_grafana_external_id"></a> [grafana\_external\_id](#input\_grafana\_external\_id) | This is your Grafana Cloud identifier and is used for security purposes. | `string` | n/a | yes |
| <a name="input_honeycomb_app_name"></a> [honeycomb\_app\_name](#input\_honeycomb\_app\_name) | n/a | `string` | n/a | yes |
| <a name="input_honeycomb_endpoint"></a> [honeycomb\_endpoint](#input\_honeycomb\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_honeycomb_headers"></a> [honeycomb\_headers](#input\_honeycomb\_headers) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_bucket"></a> [jacobs\_bucket](#input\_jacobs\_bucket) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_cidr_block"></a> [jacobs\_cidr\_block](#input\_jacobs\_cidr\_block) | n/a | `list(string)` | n/a | yes |
| <a name="input_jacobs_client_id_twitch"></a> [jacobs\_client\_id\_twitch](#input\_jacobs\_client\_id\_twitch) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_client_secret_twitch"></a> [jacobs\_client\_secret\_twitch](#input\_jacobs\_client\_secret\_twitch) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_discord_webhook"></a> [jacobs\_discord\_webhook](#input\_jacobs\_discord\_webhook) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_email_address"></a> [jacobs\_email\_address](#input\_jacobs\_email\_address) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_ip"></a> [jacobs\_ip](#input\_jacobs\_ip) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_pw"></a> [jacobs\_pw](#input\_jacobs\_pw) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_db"></a> [jacobs\_rds\_db](#input\_jacobs\_rds\_db) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_pw"></a> [jacobs\_rds\_pw](#input\_jacobs\_rds\_pw) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_schema"></a> [jacobs\_rds\_schema](#input\_jacobs\_rds\_schema) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_schema_ml"></a> [jacobs\_rds\_schema\_ml](#input\_jacobs\_rds\_schema\_ml) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_schema_twitch"></a> [jacobs\_rds\_schema\_twitch](#input\_jacobs\_rds\_schema\_twitch) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_rds_user"></a> [jacobs\_rds\_user](#input\_jacobs\_rds\_user) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_reddit_accesskey"></a> [jacobs\_reddit\_accesskey](#input\_jacobs\_reddit\_accesskey) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_reddit_pw"></a> [jacobs\_reddit\_pw](#input\_jacobs\_reddit\_pw) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_reddit_secretkey"></a> [jacobs\_reddit\_secretkey](#input\_jacobs\_reddit\_secretkey) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_reddit_user"></a> [jacobs\_reddit\_user](#input\_jacobs\_reddit\_user) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_sentry_token"></a> [jacobs\_sentry\_token](#input\_jacobs\_sentry\_token) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_twitter_key"></a> [jacobs\_twitter\_key](#input\_jacobs\_twitter\_key) | n/a | `string` | n/a | yes |
| <a name="input_jacobs_twitter_secret"></a> [jacobs\_twitter\_secret](#input\_jacobs\_twitter\_secret) | n/a | `string` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | n/a | `string` | n/a | yes |
| <a name="input_pagerduty_endpoint"></a> [pagerduty\_endpoint](#input\_pagerduty\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_pg_host"></a> [pg\_host](#input\_pg\_host) | n/a | `string` | n/a | yes |
| <a name="input_pg_pass"></a> [pg\_pass](#input\_pg\_pass) | n/a | `string` | n/a | yes |
| <a name="input_pg_role_pass"></a> [pg\_role\_pass](#input\_pg\_role\_pass) | n/a | `string` | n/a | yes |
| <a name="input_pg_user"></a> [pg\_user](#input\_pg\_user) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->