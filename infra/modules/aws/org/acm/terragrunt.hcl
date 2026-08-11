include "root" {
    path = find_in_parent_folders("root.hcl")
}

dependency "route53" {
    config_path = "../route53/"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        route53_zone_name_fomiller = "MOCK.aws.fomiller.com"
        route53_zone_id_fomiller = "MOCK567689012"
    }
}

inputs = {
    route53_zone_name_fomiller = dependency.route53.outputs.route53_zone_name_fomiller
    route53_zone_id_fomiller = dependency.route53.outputs.route53_zone_id_fomiller
}
