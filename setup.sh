#!/bin/bash
set -x

###################################################################################
# Script to replace names in the scaffolding project with new ones
#
# 1. Copy the nep-scaffolding project and rename the root directory
# 2. Replace the following new_* variables with the new project names
# 3. Run this script from the root directory
#
# This will result in a project ready for development which can be pushed through the build pipeline
# The build pipeline can be run from terraform-build/src/main/terraform using 'terraform apply'


echo -e "\nSet replacement names"
old_project_name=nep-new-project-template
new_project_name=nep-NEW-NAME

old_component_name=new-project-template
new_component_name=NEW-NAME

old_group_name=nz.vts.nep.template
new_group_name=nz.vts.nep.NEW-NAME


echo -e "\nSetup maven pom files"
sed -i -e "s/$old_project_name/$new_project_name/g w /dev/stdout" ./pom.xml
find . -name pom.xml | xargs -i echo {} | xargs sed -i -e "s/$old_group_name/$new_group_name/g w /dev/stdout"
find . -name pom.xml | xargs -i echo {} | xargs sed -i -e "s/$old_component_name/$new_component_name/g w /dev/stdout"

echo -e "\nConfigure build pipeline terraform files"
sed -i -e "s/$old_project_name/$new_project_name/g w /dev/stdout" terraform-build/src/main/terraform/environments/build/*.tf terraform-build/src/main/terraform/*.tf terraform-release/src/main/terraform/terraform.tfvars
sed -i -e "s/$old_component_name/$new_component_name/g w /dev/stdout" terraform-build/src/main/terraform/terraform.tfvars terraform-build/src/main/terraform/environments/build/main.tf terraform-release/src/main/terraform/main.tf
old_component_name_file=$(tr '-' '_' <<< $old_component_name)
new_component_name_file=$(tr '-' '_' <<< $new_component_name)
sed -i -e "s/$old_component_name_file/$new_component_name_file/g w /dev/stdout" terraform-release/src/main/terraform/*.tf*
old_component_name_arn=$(sed 's/-//g' <<< $old_component_name)
new_component_name_arn=$(sed 's/-//g' <<< $new_component_name)
sed -i -e "s/$old_component_name_arn/$new_component_name_arn/g w /dev/stdout" terraform-application/src/main/terraform/outputs.tf terraform-release/src/main/terraform/buildspecs/deploy_infrastructure.yml
old_application_domain_name=$(tr '-' '.' <<< $old_component_name)
new_application_domain_name=$(tr '-' '.' <<< $new_component_name)
sed -i -e "s/$old_application_domain_name/$new_application_domain_name/g w /dev/stdout" terraform-build/src/main/terraform/terraform.tfvars

echo -e "\nConfigure additional configuration location"
sed -i -e "s/$old_component_name/$new_component_name/g w /dev/stdout" terraform-build/src/main/terraform/buildspecs/bundle_release_pipeline_config.yml terraform-build/src/main/terraform/config/application/release-properties.json terraform-release/src/main/terraform/buildspecs/deploy_infrastructure.yml

echo -e "\nSetup Java files with the correct package path"
find . -name *.java | xargs -i echo {} | xargs sed -i -e "s/$old_application_domain_name/$new_application_domain_name/g w /dev/stdout"