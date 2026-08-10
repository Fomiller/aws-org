data "aws_caller_identity" "current" {}

# Identity Center itself can't be created here — enabling the instance, pointing
# it at authentik as an external IdP, and turning on SCIM are all console-only.
# See the homelab repo, infra/units/authentik/global/access/README.md.
data "aws_ssoadmin_instances" "this" {}

# Pushed in over SCIM by authentik. These lookups fail until a sync has run.
data "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "aws-admins"
    }
  }
}

data "aws_identitystore_group" "readonly" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "aws-readonly"
    }
  }
}
