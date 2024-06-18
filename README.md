# New Project Template
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=alert_status&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)

[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=sqale_index&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=bugs&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=code_smells&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=vulnerabilities&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)

[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=reliability_rating&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=nep-new-project-template&metric=ncloc&token=bbdf07980bf6a2fc403cf10f4292c2cd3a6c0114)](https://sonarcloud.io/summary/new_code?id=nep-new-project-template)

## Scaffolding Project
This repo provides scaffolding to set up a basic NEP project. By forking the project and running the setup script this will produce:
1. a hello world application where an HTTP post can be made to a Java lambda function through the API gateway and the WAF; and,
2. a CI build pipeline setup to deploy the environment and code with 100% test coverage of the hello world application.

### Structure
The project has the following structure:

.   
├── acceptance  
├── api  
├── new-project-template-hello-api-lambda  
├── terraform-acceptance  
├── terraform-application  
├── terraform-build  
├── terraform-release  
├── setup.sh  
├── pom.xml  
└── README.md

These correspond to:
* acceptance: cucumber BDD tests.
* api: OpenAPI specification for Hello API.
* new-project-template-hello-api-lambda: Java Lambda function for Hello API.
* terraform-acceptance: terraform environment setup for the acceptance tests.
* terraform-application: terraform environment setup for the application.
* terraform-build: code to remotely run the build.
* terraform-release: build pipeline setup to release code.
* setup.sh: script to customise the project.
* pom.xml: maven build customised by setup.sh.
* README.md: description and instructions.

### Setup Instructions
1. Fork the project
2. Edit setup.sh script and replace all new_* variable values with project specific values
3. run setup.sh
4. using a terminal session navigate to ./terraform-build/src/main/terraform and run: ```terraform init``` and after that ```terraform apply```
5. The pipeline will deploy to aws but will at first fail and a commit will need to be done to make it pass (A good first commit will be to remove the setup.sh script and change this README.md file to suit the project)

The project should now be deployed to the build pipeline and can be smoke tested using an http request from a terminal session. To do this login to the aws console, find the API client url from the stages and execute a command like the following from a terminal (replacing the url with one from the API Gateway stages):

```bash
curl -H 'Content-Type: application/json' -X POST -d '{"name": "Bob"}' https://9htgxk7ar1.execute-api.ap-southeast-2.amazonaws.com/sandbox/helloworld
```

## IntelliJ
IntelliJ has a known issue picking up the generated test sources using its default Maven imports.  Modifying the below setting should correct this:

Settings -> Maven -> Importing -> Generated sources folders - change to "subdirectories of "target/generated-sources"

