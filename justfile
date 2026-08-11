set export 

infraDir := "infra/modules/aws"

clean:
    find . -name "_.*.gen.tf" -type f | xargs -r rm -rv
    find . -name ".terraform.lock.hcl" -type f | xargs -r rm -rv
    find . -name ".terraform" -type d | xargs -r rm -rv
    find . -name ".terragrunt-cache" -type d | xargs -r rm -rv

doppler-switch env:
    doppler setup -p aws-org -c {{env}}

import tfResource awsResource dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt import --tf-path terraform \
    --working-dir {{infraDir}}/{{dir}} \
    {{tfResource}} {{awsResource}}

init dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt init --tf-path terraform \
    --working-dir {{infraDir}}/{{dir}}

init-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run --all --tf-path terraform \
    --working-dir {{infraDir}} \
    -- init

init-migrate dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt init --tf-path terraform -migrate-state \
    --working-dir {{infraDir}}/{{dir}}

validate dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt validate --tf-path terraform \
    --working-dir {{infraDir}}/{{dir}}

validate-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt validate --tf-path terraform \
    --working-dir {{infraDir}}

plan dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt plan --tf-path terraform \
    --working-dir {{infraDir}}/{{dir}}

plan-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt run --all --tf-path terraform \
    --working-dir {{infraDir}} \
    -- plan

apply dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt apply --tf-path terraform \
    -auto-approve \
    --working-dir {{infraDir}}/{{dir}}

apply-all dir=infraDir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt --non-interactive run --all --tf-path terraform \
    --working-dir {{dir}} \
    -- apply

destroy dir:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt --non-interactive destroy --tf-path terraform \
    --working-dir {{infraDir}}/{{dir}}

destroy-all:
    doppler run \
    --name-transformer tf-var  \
    -- terragrunt --non-interactive run --all --tf-path terraform \
    --working-dir {{infraDir}} \
    -- destroy


fmt:
    doppler run \
    --name-transformer tf-var  \
    -- terraform fmt \
    --recursive

@init-org-module dir acct="org":
    mkdir -p {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1
    
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/common.tfvars
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/common.tfvars
    touch {{infraDir}}/{{acct}}/{{dir}}/_outputs.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_inputs.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_data.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_variables.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/{{dir}}.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/main.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/terragrunt.hcl
    
    echo 'asset_name = "{{dir}}"' >> {{infraDir}}/{{acct}}/{{dir}}/env-config/common.tfvars
    echo 'locals {}' >> {{infraDir}}/{{acct}}/{{dir}}/main.tf
    
    touch "{{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/org.tfvars" 
    echo 'environment = "org"' > {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/dev.tfvars
    echo -e 'include "root" {\n\
    \tpath = find_in_parent_folders()\n\
    }' > {{infraDir}}/{{acct}}/{{dir}}/terragrunt.hcl
    @# {{infraDir}}/{{acct}}/{{dir}} created.

@init-member-module dir acct="member":
    mkdir -p {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1
    
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/common.tfvars
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/common.tfvars
    touch {{infraDir}}/{{acct}}/{{dir}}/_outputs.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_inputs.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_data.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/_variables.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/{{dir}}.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/main.tf
    touch {{infraDir}}/{{acct}}/{{dir}}/terragrunt.hcl
    
    echo 'asset_name = "{{dir}}"' >> {{infraDir}}/{{acct}}/{{dir}}/env-config/common.tfvars
    echo 'locals {}' >> {{infraDir}}/{{acct}}/{{dir}}/main.tf
    
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/prod.tfvars
    touch {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/dev.tfvars
    echo 'environment = "dev"' > {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/dev.tfvars
    echo 'environment = "prod"' > {{infraDir}}/{{acct}}/{{dir}}/env-config/us-east-1/prod.tfvars
    echo -e 'include "root" {\n\
    \tpath = find_in_parent_folders()\n\
    }' > {{infraDir}}/{{acct}}/{{dir}}/terragrunt.hcl
    @# {{infraDir}}/{{acct}}/{{dir}} created.
