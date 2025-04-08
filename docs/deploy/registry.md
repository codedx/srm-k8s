# Downloading Docker Images from the Black Duck Docker Registry

Your SRM configuration requires you to pull SRM Docker images from the Black Duck private Docker registry and push them to your own private registry. You can use a private registry hosted by a cloud provider (e.g., AWS, GCP, Azure, etc.) or deploy your own.

The following sections outline how to copy SRM Docker images to your private registry.

## Request access to Black Duck Community

If you are new to Black Duck, request access to Black Duck Community:

1. Go to https://community.blackduck.com/s/SelfRegistrationForm.
2. Complete and submit the registration form. You should receive access instantaneously.

## Request Black Duck Docker Registry Credentials

Obtain Black Duck docker registry credentials to provide access to download Black Duck images:

1. Login to Black Duck Community at https://community.blackduck.com/s/.
2. Navigate to Licenses > SRM Integrated.
3. Click View/Request Docker Registry Credential.
4. When access to the Black Duck private repository is granted, continue with the next section.

## Docker Registry Login

Log on to the Black Duck Docker registry and your private Docker registry with these steps:

1. Login to Black Duck Community at https://community.blackduck.com/s/.
2. Navigate to Licenses > SRM Integrated.
3. Click on View/Request Docker Registry Credential to open the license pop-up. This pop-up contains
copy buttons to copy the credentials.
4. Log on to the Black Duck registry using the following command, specifying the username and password you copied:
```
$ docker login repo.blackduck.com
```
5. Log on to your private registry:
```
$ docker login your.private.registry
```

## Obtain Docker Images

You must [pull, tag, and push](https://docs.docker.com/registry/deploying/#copy-an-image-from-docker-hub-to-your-registry) each SRM Docker image that your SRM deployment requires.

### Example Pull/Tag/Push

The following example commands use a fictitious private registry hosted in AWS at id.dkr.ecr.us-east-2.amazonaws.com.

The first example stores Black Duck Docker images at the root of your private registry:

```
$ docker pull repo.blackduck.com/containers/codedx/codedx-tomcat:v2025.3.3
$ docker tag repo.blackduck.com/containers/codedx/codedx-tomcat:v2025.3.3 id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2025.3.3
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/codedx/codedx-tomcat:v2025.3.3
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

The following example stores Black Duck images under "my-srm" in your private registry. In this scenario, you must enter "my-srm" as your private registry repository prefix in the Guided Setup:

```
$ docker pull repo.blackduck.com/containers/codedx/codedx-tomcat:v2025.3.3
$ docker tag repo.blackduck.com/containers/codedx/codedx-tomcat:v2025.3.3 id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2025.3.3
$ docker push id.dkr.ecr.us-east-2.amazonaws.com/my-srm/codedx/codedx-tomcat:v2025.3.3
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

See the following sections for the Docker images you must obtain via docker pull/tag/push commands. Pattern your commands after the above examples and run pull/tag/push for each Docker image your SRM deployment requires.

### SRM Web Docker images

The SRM Web pod requires this Docker image:

- repo.blackduck.com/containers/codedx/codedx-tomcat:v2025.3.3

You can use this PowerShell script below to pull, tag, and push the above Black Duck Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tomcat:v2025.3.3' | ForEach-Object {

   docker pull "repo.blackduck.com/containers/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Database Docker images

If you are using an external SRM database, skip this section.

The SRM Database pod requires this Docker image:

- repo.blackduck.com/containers/codedx/codedx-mariadb:v1.38.0

You can use this PowerShell script below to pull, tag, and push the above Black Duck Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-mariadb:v1.38.0' | ForEach-Object {

   docker pull "repo.blackduck.com/containers/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Scan Farm Docker images

If you are not using the SRM Scan Farm feature, skip this section.

The SRM Scan Farm feature requires these Docker images:

- repo.blackduck.com/containers/cache-service:2024.12.0
- repo.blackduck.com/containers/common-infra:2024.12.0
- repo.blackduck.com/containers/scan-service:2024.12.0
- repo.blackduck.com/containers/scan-service-migration:2024.12.0
- repo.blackduck.com/containers/storage-service:2024.12.0
- repo.blackduck.com/containers/storage-service-migration:2024.12.0
- repo.blackduck.com/containers/job-runner:2024.12.0

You can use this PowerShell script below to pull, tag, and push the above Black Duck Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'cache-service:2024.12.0',
'common-infra:2024.12.0',
'scan-service:2024.12.0',
'scan-service-migration:2024.12.0',
'storage-service:2024.12.0',
'storage-service-migration:2024.12.0',
'job-runner:2024.12.0' | ForEach-Object {

   docker pull "repo.blackduck.com/containers/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### SRM Tool Orchestration Docker images

If you are not using the SRM Tool Orchestration feature, skip this section.

The SRM Tool Orchestration feature requires these Docker images:

- repo.blackduck.com/containers/codedx/codedx-tools:v2025.3.3
- repo.blackduck.com/containers/codedx/codedx-prepare:v2.10.0
- repo.blackduck.com/containers/codedx/codedx-newanalysis:v2.10.0
- repo.blackduck.com/containers/codedx/codedx-results:v2.10.0
- repo.blackduck.com/containers/codedx/codedx-tool-service:v2.10.0
- repo.blackduck.com/containers/codedx/codedx-cleanup:v2.10.0
- repo.blackduck.com/containers/argoproj/workflow-controller:v3.5.11
- repo.blackduck.com/containers/argoproj/argoexec:v3.5.11
- repo.blackduck.com/containers/bitnami/minio:2024.11.7-debian-12-r2 (when not using external workflow storage)

You can use this PowerShell script below to pull, tag, and push the above Black Duck Docker image to your private registry; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash):

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tools:v2025.3.3',
'codedx/codedx-prepare:v2.10.0',
'codedx/codedx-newanalysis:v2.10.0',
'codedx/codedx-results:v2.10.0',
'codedx/codedx-tool-service:v2.10.0',
'codedx/codedx-cleanup:v2.10.0',
'bitnami/minio:2024.11.7-debian-12-r2',
'argoproj/workflow-controller:v3.5.11',
'argoproj/argoexec:v3.5.11' | ForEach-Object {

   docker pull "repo.blackduck.com/containers/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

### Powershell Core Docker Pull/Tag/Push All Example

If you are logged in to the Black Duck Docker registry and your private registry, you can use the script below to pull, tag, and push all Black Duck Docker images; you must set the $myPrivateRegistryPrefix variable by replacing `id.dkr.ecr.us-east-2.amazonaws.com` with your Docker registry name and any prefix (e.g., my-srm) you require ($myPrivateRegistryPrefix must end with a forward slash).

```
$myPrivateRegistryPrefix = 'id.dkr.ecr.us-east-2.amazonaws.com/'
if (-not $myPrivateRegistryPrefix.EndsWith('/')) { $myPrivateRegistryPrefix="$myPrivateRegistryPrefix/" }

'codedx/codedx-tomcat:v2025.3.3',
'codedx/codedx-tools:v2025.3.3',
'codedx/codedx-prepare:v2.10.0',
'codedx/codedx-newanalysis:v2.10.0',
'codedx/codedx-results:v2.10.0',
'codedx/codedx-tool-service:v2.10.0',
'codedx/codedx-cleanup:v2.10.0',
'codedx/codedx-mariadb:v1.38.0',
'bitnami/minio:2024.11.7-debian-12-r2',
'argoproj/workflow-controller:v3.5.11',
'argoproj/argoexec:v3.5.11',
'cache-service:2024.12.0',
'common-infra:2024.12.0',
'scan-service:2024.12.0',
'scan-service-migration:2024.12.0',
'storage-service:2024.12.0',
'storage-service-migration:2024.12.0',
'job-runner:2024.12.0' | ForEach-Object {

   docker pull "repo.blackduck.com/containers/$_"
   if($LASTEXITCODE -ne 0){throw "$_ pull failed"} 

   docker tag "repo.blackduck.com/containers/$_" "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ tag failed"} 

   docker push "$myPrivateRegistryPrefix$_"
   if($LASTEXITCODE -ne 0){throw "$_ push failed"} 
}
```

>Note: Your private Docker registry might require creating a repository before adding a Docker image with `docker push`.

## Docker Registry Logout

With your Docker images copied, log out of both registries:

```
$ docker logout repo.blackduck.com
$ docker logout your.private.registry
```




