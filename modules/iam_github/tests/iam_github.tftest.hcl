# Mocked ARN and policy document values are synthetic and are not validated
# against real AWS provider behavior. aws_iam_policy_document is overridden
# because mock_provider does not render a valid IAM JSON document for the
# aws_iam_role assume_role_policy validation.
mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/unit-github-role"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/unit-github-policy"
    }
  }
}

override_data {
  target = data.aws_iam_policy_document.this
  values = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Principal\":{\"Federated\":\"arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com\"}}]}"
  }
}

variables {
  iam_role_name       = "unit-github"
  github_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  github_repo         = "owner/repo"
  iam_role_policy     = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
}

run "valid_inputs_configure_role" {
  command = plan

  assert {
    condition     = aws_iam_role.this.name == "unit-github-role"
    error_message = "IAM role name should append -role."
  }

  assert {
    condition     = aws_iam_role.this.assume_role_policy == data.aws_iam_policy_document.this.json
    error_message = "IAM role trust policy should come from the policy document data source."
  }
}

run "explicit_github_sub_is_accepted" {
  command = plan

  variables {
    github_sub = "repo:owner/repo:ref:refs/heads/main"
  }

  assert {
    condition     = aws_iam_role.this.name == "unit-github-role"
    error_message = "Explicit github_sub should still produce the configured IAM role."
  }
}

run "policy_and_attachment_are_wired" {
  command = plan

  assert {
    condition     = aws_iam_policy.this.name == "unit-github-policy"
    error_message = "IAM policy name should append -policy."
  }

  assert {
    condition     = aws_iam_policy.this.policy == var.iam_role_policy
    error_message = "IAM policy document should come from iam_role_policy."
  }
}
