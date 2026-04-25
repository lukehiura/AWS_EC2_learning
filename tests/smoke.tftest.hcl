# Terraform Test (CLI 1.6+). Runs a real plan against AWS (needs credentials), so CI runs this in the Plan job after OIDC.
# https://developer.hashicorp.com/terraform/language/tests

run "plan_succeeds" {
  command = plan
}
