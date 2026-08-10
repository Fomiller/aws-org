data "aws_caller_identity" "current" {}

# The instance has been active since 2022. Pointing it at authentik as an
# external IdP and turning on SCIM are console-only — no provider resource
# covers either. See the homelab repo,
# infra/units/authentik/global/access/README.md.
data "aws_ssoadmin_instances" "this" {}

# Pushed in over SCIM by authentik, so these 400 until the first sync — hence
# the var.sso_groups_provisioned gate.
data "aws_identitystore_group" "admins" {
  count = var.sso_groups_provisioned ? 1 : 0

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "aws-admins"
    }
  }
}

data "aws_identitystore_group" "readonly" {
  count = var.sso_groups_provisioned ? 1 : 0

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "aws-readonly"
    }
  }
}
