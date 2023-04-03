# Infrastructure as Code (IaC)
Microsoft defines it as "the management of infrastructure in a descriptive model, using the same versioning as DevOps team uses for source code."

[IaC on Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code)

# Tools and Languages
- Bicep: a domain specific language that uses declaritive syntax to deploy Azure resources, used instead of json to develop ARM templates
- YAML: a data serialization language used with Azure pipelines, stands for yet another markup langauge
- Azure Pipelines: combines continuous integration (CI) and continuous delivery (cd) to build, deploy, and test code

# Reference App

## Sample code
Sample application code (online toy store) is copied directly from [Microsoft Learning path](https://docs.microsoft.com/en-us/learn/paths/bicep-azure-pipelines/).
IaC code from tutorial has been modified for reference app, source code for website is 'as is'

## Pipeline stages (Flood-Base) 
1. Build database code: build sqlproj, copy files, publish pipeline artifact
2. Lint bicep code: runs `az bicep build` 
3. Validate Azure deployment: runs bicep code in validation mode **requires variables to be set in pipeline library**
4. Deploy bicep code (includes app service): runs bicep code and saves output to pipeline variables 

*note: once this step is compete, create sas key and update pipeline variables*

5. Deploy database code: executes dacpac deployment
6. Deploy SQL script (test data): executes ad-hoc sql script
7. Deploy images to blob storage: uploads images to blob storage 

*note: not crazy about this design, but it used to work without sas-token - fine for poc*

## Pipeline stages (Slotter)
1. Build app code: build web app, copy files, publish pipeline artifact
2. Deploy bicep code (includes slot): run bicep code to create slot
3. Deploy app code: deploy web app to slot
4. Run smoke test: verify slot host is alive

### Running Slotter

1. Run Flood-Base to generate app service and other resources

2. Update pipeline variable group

3. Run Slotter pipeline, by default the pipeline uses the current branch for slot name but that can be overridden.

