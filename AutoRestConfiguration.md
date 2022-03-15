### AutoRest Configuration
> see https://aka.ms/autorest

``` yaml
branch: main
require:
  - $(this-folder)/../../readme.azure.noprofile.md
input-file:
  - $(repo)/specification/advisor/resource-manager/Microsoft.Advisor/stable/2017-04-19/advisor.json

title: Aks
module-version: 0.1.0
subject-prefix: $(service-name)
identity-correction-for-post: true
```


find-module Az.Automation -Repository PSgallery -AllVersions

