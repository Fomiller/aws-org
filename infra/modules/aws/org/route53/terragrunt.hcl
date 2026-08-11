include "root" {
	path = find_in_parent_folders("root.hcl")
}

dependency "s3" {
    config_path = "../s3"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        s3_bucket_website_domain_fomiller = "MOCK.fomiller.com.s3-website-us-east-1.amazonaws.com"
        s3_bucket_hosted_zone_id_fomiller = "MOCK123456789"
    }
}

inputs = {
    s3_bucket_website_domain_fomiller = dependency.s3.outputs.s3_bucket_website_domain_fomiller
    s3_bucket_hosted_zone_id_fomiller = dependency.s3.outputs.s3_bucket_hosted_zone_id_fomiller
}

