environment = "org"

# dev and prod. aws-infra-shared-services runs in dev and manages route53
# hosted zones that live in this account.
assuming_account_ids = [
  "695434033664",
  "737133467188",
]
