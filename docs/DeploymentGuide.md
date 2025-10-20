# Software Risk Manager Kubernetes Deployment

<!-- toc -->

- [Software Risk Manager Features](#software-risk-manager-features)
  * [Core Feature](#core-feature)
  * [Scan Farm Feature](#scan-farm-feature)
  * [Tool Orchestration Feature](#tool-orchestration-feature)
- [Requirements](#requirements)
  * [Kubernetes Requirements](#kubernetes-requirements)
    + [Kubernetes Privileges for Core Feature Deployment](#kubernetes-privileges-for-core-feature-deployment)
    + [Kubernetes Privileges for Scan Farm Feature Deployment](#kubernetes-privileges-for-scan-farm-feature-deployment)
    + [Kubernetes Privileges for Tool Orchestration Feature Deployment](#kubernetes-privileges-for-tool-orchestration-feature-deployment)
  * [Helm Requirements](#helm-requirements)
  * [System Size](#system-size)
  * [Core Feature Requirements](#core-feature-requirements)
    + [Core Web Workload Requirements](#core-web-workload-requirements)
    + [Core Web Database Workload Requirements](#core-web-database-workload-requirements)
    + [Core Web Replica Database Workload Requirements](#core-web-replica-database-workload-requirements)
    + [Core Persistent Storage Requirements](#core-persistent-storage-requirements)
    + [Core Internet Access Requirements](#core-internet-access-requirements)
    + [Core Pod Security Admission Requirements](#core-pod-security-admission-requirements)
  * [Scan Farm Feature Requirements](#scan-farm-feature-requirements)
    + [Scan Farm Database Requirements](#scan-farm-database-requirements)
    + [Scan Farm Cache Requirements](#scan-farm-cache-requirements)
    + [Scan Farm Object Storage Requirements](#scan-farm-object-storage-requirements)
    + [Scan Farm Node Pool Requirements](#scan-farm-node-pool-requirements)
    + [Scan Farm Network Ports](#scan-farm-network-ports)
    + [Scan Farm Private Registry](#scan-farm-private-registry)
    + [Scan Farm Ingress Requirements](#scan-farm-ingress-requirements)
    + [Scan Farm Internet Access Requirements](#scan-farm-internet-access-requirements)
    + [Scan Farm Default Pod Resources](#scan-farm-default-pod-resources)
  * [Tool Orchestration Feature Requirements](#tool-orchestration-feature-requirements)
    + [Tool Service Workload Requirements](#tool-service-workload-requirements)
    + [Workflow Controller Workload Requirements](#workflow-controller-workload-requirements)
    + [On-Cluster Workflow Storage Requirements (MinIO)](#on-cluster-workflow-storage-requirements-minio)
    + [Add-in Tool Workload Requirements](#add-in-tool-workload-requirements)
    + [Tool Orchestration Persistent Storage Requirements](#tool-orchestration-persistent-storage-requirements)
    + [Tool Orchestration Add-in Resource Requirements](#tool-orchestration-add-in-resource-requirements)
    + [Tool Orchestration Pod Security Admission Requirements](#tool-orchestration-pod-security-admission-requirements)
- [External Web Database Pre-work](#external-web-database-pre-work)
  * [External Web Database Pre-work - Instance Configuration](#external-web-database-pre-work---instance-configuration)
  * [External Web Database Pre-work - Password Authentication](#external-web-database-pre-work---password-authentication)
  * [External Web Database Pre-work - RDS IAM Authentication](#external-web-database-pre-work---rds-iam-authentication)
- [Persistent Storage Pre-work](#persistent-storage-pre-work)
  * [Volume Configuration Pre-work](#volume-configuration-pre-work)
  * [AWS Persistent Storage Pre-work](#aws-persistent-storage-pre-work)
    + [AWS EBS Persistent Storage Pre-work](#aws-ebs-persistent-storage-pre-work)
    + [AWS EFS Persistent Storage Pre-work](#aws-efs-persistent-storage-pre-work)
- [Scan Farm Pre-work](#scan-farm-pre-work)
  * [Private Docker Registry](#private-docker-registry)
  * [AWS Scan Farm Pre-work](#aws-scan-farm-pre-work)
    + [EKS Scanner Nodes Pre-work](#eks-scanner-nodes-pre-work)
    + [RDS for PostgreSQL (Database) Pre-work](#rds-for-postgresql-database-pre-work)
    + [ElastiCache for Redis (Cache) Pre-work](#elasticache-for-redis-cache-pre-work)
    + [Simple Storage Service (Object Storage) Pre-work](#simple-storage-service-object-storage-pre-work)
  * [GCP Scan Farm Pre-work](#gcp-scan-farm-pre-work)
    + [GKE Scanner Nodes Pre-work](#gke-scanner-nodes-pre-work)
    + [Cloud SQL for PostgreSQL (Database) Pre-work](#cloud-sql-for-postgresql-database-pre-work)
    + [Memorystore for Redis (Cache) Pre-work](#memorystore-for-redis-cache-pre-work)
    + [Cloud Storage (Object Storage) Pre-work](#cloud-storage-object-storage-pre-work)
  * [Azure Scan Farm Pre-work](#azure-scan-farm-pre-work)
    + [AKS Scanner Nodes Pre-work](#aks-scanner-nodes-pre-work)
    + [Azure Database for PostgreSQL (Database) Pre-work](#azure-database-for-postgresql-database-pre-work)
    + [Azure Cache for Redis (Cache) Pre-work](#azure-cache-for-redis-cache-pre-work)
    + [Azure Cloud Storage (Object Storage) Pre-work](#azure-cloud-storage-object-storage-pre-work)
  * [On-Cluster Scan Farm Pre-work](#on-cluster-scan-farm-pre-work)
    + [Scanner Nodes Pre-work](#scanner-nodes-pre-work)
    + [Bitnami PostgreSQL Chart Pre-work](#bitnami-postgresql-chart-pre-work)
    + [Bitnami Redis Chart Pre-work](#bitnami-redis-chart-pre-work)
    + [Bitnami MinIO Chart Pre-work](#bitnami-minio-chart-pre-work)
- [Tool Orchestration Pre-work](#tool-orchestration-pre-work)
  * [Node Pool Pre-work](#node-pool-pre-work)
  * [Object Storage Pre-work](#object-storage-pre-work)
    + [AWS](#aws)
    + [AWS IRSA](#aws-irsa)
    + [GCP](#gcp)
    + [MinIO](#minio)
- [Password Pre-work](#password-pre-work)
- [Network Policies](#network-policies)
- [TLS Pre-work](#tls-pre-work)
  * [Istio Ambient Mode](#istio-ambient-mode)
    + [Istio - Mesh Visualization](#istio---mesh-visualization)
  * [Cert-Manager Certificates](#cert-manager-certificates)
    + [Cert-Manager Certificates Example](#cert-manager-certificates-example)
  * [Kubernetes CertificateSigningRequests](#kubernetes-certificatesigningrequests)
    + [Kubernetes CertificateSigningRequests Example](#kubernetes-certificatesigningrequests-example)
- [Licensing](#licensing)
- [Installation - Quick Start](#installation---quick-start)
  * [Core Quick Start](#core-quick-start)
  * [Tool Orchestration Quick Start](#tool-orchestration-quick-start)
  * [Fetch Initial Admin Password](#fetch-initial-admin-password)
- [Installation - Full](#installation---full)
  * [Prerequisites](#prerequisites)
    + [Linux Prerequisites](#linux-prerequisites)
    + [macOS Prerequisites](#macos-prerequisites)
    + [Windows Prerequisites](#windows-prerequisites)
    + [PowerShell Module](#powershell-module)
  * [Clone GitHub Repository](#clone-github-repository)
  * [Helm Prep Wizard](#helm-prep-wizard)
  * [Helm Prep Script](#helm-prep-script)
    + [Configuration File Protection](#configuration-file-protection)
    + [Invoking the Helm Prep Script](#invoking-the-helm-prep-script)
  * [Invoke helm/kubectl Commands](#invoke-helmkubectl-commands)
    + [Fetch Initial Admin Password](#fetch-initial-admin-password-1)
- [Deploying with GitOps (Flux)](#deploying-with-gitops-flux)
  * [One-Time Setup Steps](#one-time-setup-steps)
    + [Flux Steps:](#flux-steps)
    + [Bitnami Sealed Secrets Steps:](#bitnami-sealed-secrets-steps)
  * [Software Risk Manager Deployment](#software-risk-manager-deployment)
- [Customizing Software Risk Manager](#customizing-software-risk-manager)
  * [Specify Web Properties (codedx.props)](#specify-web-properties-codedxprops)
    + [Public Web Properties Proxy Example](#public-web-properties-proxy-example)
    + [Private Web Properties Proxy Example](#private-web-properties-proxy-example)
  * [Specify Database Connection Timeout](#specify-database-connection-timeout)
  * [Specify Extra SAML Configuration](#specify-extra-saml-configuration)
  * [Specify LDAP Configuration](#specify-ldap-configuration)
  * [Specify Custom Context Path](#specify-custom-context-path)
  * [Scan Farm Job Resources](#scan-farm-job-resources)
    + [SCA - Buildless Scan](#sca---buildless-scan)
    + [SCA - Bridge-based Scan](#sca---bridge-based-scan)
    + [SAST Scan](#sast-scan)
  * [Tool Orchestration Add-in Tool Configuration](#tool-orchestration-add-in-tool-configuration)
    + [Add-in Example 1 - Project Resource Requirement](#add-in-example-1---project-resource-requirement)
    + [Add-in Example 2 - Global Tool Resource Requirement](#add-in-example-2---global-tool-resource-requirement)
    + [Add-in Example 3 - Node Selector](#add-in-example-3---node-selector)
  * [Specify Scan Farm Engine Versions](#specify-scan-farm-engine-versions)
  * [Add Extra Pod Labels](#add-extra-pod-labels)
  * [Specify MySQL Server Public Key Path](#specify-mysql-server-public-key-path)
- [Maintenance](#maintenance)
  * [System Component Password/Key Resets](#system-component-passwordkey-resets)
  * [Expand Volume Size](#expand-volume-size)
  * [Reset Replication](#reset-replication)
  * [Web Logging](#web-logging)
  * [License Renewal](#license-renewal)
- [Backup and Restore](#backup-and-restore)
  * [About Velero](#about-velero)
  * [Installing Velero](#installing-velero)
    + [Velero Opt-In or Opt-Out Volume Backup](#velero-opt-in-or-opt-out-volume-backup)
  * [Create a Backup Schedule](#create-a-backup-schedule)
    + [Schedule for On-Cluster Database](#schedule-for-on-cluster-database)
    + [Schedule for External Database](#schedule-for-external-database)
  * [Verify Backup](#verify-backup)
  * [Restoring Code Dx](#restoring-code-dx)
    + [Step 1: Restore Cluster State and Volume Data](#step-1-restore-cluster-state-and-volume-data)
    + [Step 2: Restore Software Risk Manager Database](#step-2-restore-software-risk-manager-database)
  * [Removing Backup Configuration](#removing-backup-configuration)
  * [Reset Database Replication](#reset-database-replication)
- [Upgrades](#upgrades)
  * [Applying an Update](#applying-an-update)
    + [TLS](#tls)
  * [Adding the Scan Farm Feature](#adding-the-scan-farm-feature)
  * [Reconfigure the Scan Farm Feature](#reconfigure-the-scan-farm-feature)
  * [Trusting Additional Certificates](#trusting-additional-certificates)
  * [Adding SAML Authentication](#adding-saml-authentication)
- [Code Dx Deployment Model Migration](#code-dx-deployment-model-migration)
  * [Before you Begin](#before-you-begin)
  * [Clone the srm-k8s GitHub Repository](#clone-the-srm-k8s-github-repository)
  * [Upgrade your Code Dx Version](#upgrade-your-code-dx-version)
  * [Stop Code Dx Web](#stop-code-dx-web)
  * [Stop Code Dx Tool Orchestration (if installed)](#stop-code-dx-tool-orchestration-if-installed)
  * [Run the Software Risk Manager Migration Script](#run-the-software-risk-manager-migration-script)
  * [Install Software Risk Manager](#install-software-risk-manager)
  * [Stop Software Risk Manager Web](#stop-software-risk-manager-web)
  * [Stop Software Risk Manager Tool Orchestration (if installed)](#stop-software-risk-manager-tool-orchestration-if-installed)
  * [Work Directory](#work-directory)
  * [Copy Code Dx Web Files Locally](#copy-code-dx-web-files-locally)
  * [Copy Local Code Dx Web Files to Software Risk Manager](#copy-local-code-dx-web-files-to-software-risk-manager)
  * [Backup Code Dx Database](#backup-code-dx-database)
    + [Backup On-Cluster MariaDB Database](#backup-on-cluster-mariadb-database)
    + [Backup External Database](#backup-external-database)
  * [Restore Code Dx Database](#restore-code-dx-database)
    + [Restore On-Cluster MariaDB Database](#restore-on-cluster-mariadb-database)
    + [Restore External Database](#restore-external-database)
  * [Copy Code Dx MinIO Files Locally (if installed)](#copy-code-dx-minio-files-locally-if-installed)
  * [Copy Local Code Dx MinIO Files to Software Risk Manager (if installed)](#copy-local-code-dx-minio-files-to-software-risk-manager-if-installed)
  * [Copy Tool Orchestration Resources from Code Dx to Software Risk Manager (if installed)](#copy-tool-orchestration-resources-from-code-dx-to-software-risk-manager-if-installed)
  * [Start Software Risk Manager Tool Orchestration (if installed)](#start-software-risk-manager-tool-orchestration-if-installed)
  * [Start Software Risk Manager Web](#start-software-risk-manager-web)
- [Cannot Run PowerShell Core](#cannot-run-powershell-core)
- [Moving a Software Risk Manager Deployment](#moving-a-software-risk-manager-deployment)
  * [Deploy a new Software Risk Manager Instance](#deploy-a-new-software-risk-manager-instance)
  * [Stop Source Software Risk Manager Web Workload](#stop-source-software-risk-manager-web-workload)
  * [Copy Source Software Risk Manager Web Volume Files](#copy-source-software-risk-manager-web-volume-files)
  * [Copy Source Software Risk Manager Database Backup](#copy-source-software-risk-manager-database-backup)
  * [Stop Destination Software Risk Manager Web Workload](#stop-destination-software-risk-manager-web-workload)
  * [Replace Destination Software Risk Manager Web Volume Files](#replace-destination-software-risk-manager-web-volume-files)
  * [Replace Destination Software Risk Manager Database](#replace-destination-software-risk-manager-database)
  * [Move Tool Orchestration Resources (if installed)](#move-tool-orchestration-resources-if-installed)
  * [Start Destination Software Risk Manager Web Workload](#start-destination-software-risk-manager-web-workload)
- [Software Risk Manager Helm Chart](#software-risk-manager-helm-chart)
  * [Chart Dependencies](#chart-dependencies)
  * [Values](#values)
- [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)
  * [Core Feature Troubleshooting](#core-feature-troubleshooting)
    + [Table Already Exists](#table-already-exists)
    + [RSA Public Key Unavailable](#rsa-public-key-unavailable)
  * [Scan Farm Feature Troubleshooting](#scan-farm-feature-troubleshooting)
    + [Scan Farm Migration Job Fails](#scan-farm-migration-job-fails)
    + [Scan Service GetAccessToken Fails](#scan-service-getaccesstoken-fails)
    + [Cache Service Startup Fails](#cache-service-startup-fails)
- [Appendix](#appendix)
  * [Config.json](#configjson)
  * [Helm Chart Notes](#helm-chart-notes)
    + [Upgrading to v1.22 - v1.25](#upgrading-to-v122---v125)
    + [Upgrading to v1.26](#upgrading-to-v126)
    + [Upgrading to v1.28](#upgrading-to-v128)
    + [Upgrading to v1.40](#upgrading-to-v140)
    + [Upgrading to v1.42](#upgrading-to-v142)
    + [Upgrading to v1.43](#upgrading-to-v143)
    + [Upgrading to v1.46](#upgrading-to-v146)
    + [Upgrading to v1.49](#upgrading-to-v149)
    + [Upgrading to v1.64](#upgrading-to-v164)
  * [All-in-One Demo Config](#all-in-one-demo-config)
    + [Install and Configure Tools](#install-and-configure-tools)
    + [Create a Certificate](#create-a-certificate)
    + [Create a Local Private Registry](#create-a-local-private-registry)
    + [Clone Repo](#clone-repo)
    + [Load Container Images](#load-container-images)
    + [Create a Cluster](#create-a-cluster)
    + [Install Ingress-Nginx](#install-ingress-nginx)
    + [Deploy Scan Farm Dependencies](#deploy-scan-farm-dependencies)
    + [Deploy SRM](#deploy-srm)
  * [Software Risk Manager Wizards](#software-risk-manager-wizards)
    + [Helm Prep Wizard](#helm-prep-wizard-1)
    + [Add Certificates Wizard](#add-certificates-wizard)
    + [Add SAML Authentication Wizard](#add-saml-authentication-wizard)
    + [Scan Farm Wizard](#scan-farm-wizard)
    + [Set Passwords Wizard](#set-passwords-wizard)

<!-- tocstop -->

# Software Risk Manager Features

The footprint of your Software Risk Manager Kubernetes deployment depends on the licensed features you plan to use. Some features depend on external systems you must configure separately, while others optionally depend on external components. The following sections include feature-related deployment diagrams. Since the parts are additive, you can conflate diagrams to see the entire footprint for your selected feature set.

## Core Feature

The Software Risk Manager web application requires a MariaDB (version 10.6.x) or a MySQL (version 8.0.x) database instance. You can provide a database instance or use what's included in the Software Risk Manager Helm chart. We treat a database you provide as an external one that you are responsible for configuring according to our guidance. An external database can be a standalone instance or one managed on your behalf by a cloud provider like AWS or Azure. A Core deployment using an external database consists of one Software Risk Manager pod.

![Core with External Database](images/diagram-core-external-db.png "Core with External Database")

A Core deployment without an external database includes additional pods for the primary and optional secondary database instances. The MariaDB database instances store data using Kubernetes Persistent Volumes. The web application connects to the primary database instance. Data gets replicated to an optional secondary database instance that supports backups using a script that invokes mariabackup with the option to pause replica SQL threads. The Software Risk Manager Helm chart configures on-cluster database instance(s).

![Core with Replica Database](images/diagram-core-replica-db.png "Core with Replica Database")

Every Software Risk Manager includes the web application that serves the web UI. Additional feature installation will depend on licensing and your Software Risk Manager use case.

## Scan Farm Feature

Deployments that include the Scan Farm feature have built-in SAST and SCA scanning provided by Coverity and Black Duck, respectively. They include additional pods that support scanning, caching, and storage with external dependencies on PostgreSQL (versions 10.16 - 14.x), Redis (version 5.0 or greater), and object storage provided by either GCP, AWS, Azure, or MinIO. You are responsible for configuring external dependencies according to our guidance.

Your Software Risk Manager licensing will determine whether you have SAST, SCA, or both SAST and SCA scanning capability. SCA scanning depends on an external Black Duck server instance hosted by Black Duck Software. You are not responsible for the configuration of this instance or for specifying its endpoint during the Software Risk Manager deployment process.

Scan Farm-related Docker images are unavailable in Docker Hub. You must pull them along with all other Software Risk Manager Docker images from the Black Duck repository (repo.blackduck.com).

![Scan Farm](images/diagram-scan-farm.png "Scan Farm")

The Scan Farm includes an ingress resource for the following services: Storage Service, Cache Service, and Scan Service. The Storage Service provides access to externally provided object storage, the Cache Service provides an interface to an external cache, and the Scan Service provides the Tool API that lets clients download SAST and SCA tools.

The external, Black Duck Software-provided Black Duck SCA scanning endpoint will receive a Black Duck BDIO file used for Black Duck Rapid Scans. The file gets sent to a Code Sight endpoint and is then handled by Black Duck server and Black Duck KnowledgeBase instances. For general [communication with Black Duck services](https://documentation.blackduck.com/bundle/bd-hub/page/Network_Communications/CommunicationWithBDServers.html) information, refer to the Black Duck documentation.

## Tool Orchestration Feature

Deployments that include the Tool Orchestration feature support orchestrated analyses that let you run both built-in and custom [add-ins](https://github.com/codedx/srm-add-ins) on your cluster. They have additional pods that support tool workflows and storage with an optional external dependency on object storage provided by a system with an AWS S3-compatible API (e.g., MinIO, AWS S3, GCS, etc.). 

![Tool Orchestration External Components](images/diagram-tool-orchestration-external.png "Tool Orchestration External Components")

When not opting for external object storage, the Software Risk Manager Helm chart will configure an older MinIO version for you.

![Tool Orchestration](images/diagram-tool-orchestration.png "Tool Orchestration")

# Requirements

Refer to what follows for the supported or tested versions of software that comprise the Software Risk Manager deployment.

## Kubernetes Requirements

The Software Risk Manager deployment supports Kubernetes versions 1.22 through 1.33 and was tested with OpenShift 4.18. If you are not a cluster administrator, your cluster access must include the permissions defined in the sections below before installing Software Risk Manager on your cluster.

### Kubernetes Privileges for Core Feature Deployment

The required Kubernetes privileges for the Core feature deployment will depend on whether or not you use an external database. For external database deployments, refer to the [admin-core-external-db-deployment-role](./roles/admin-core-external-db-deployment-role.yaml) ClusterRole definition. Otherwise, refer to the [admin-core-deployment-role](./roles/admin-core-deployment-role.yaml) ClusterRole definition.

You can use a role YAML file to assign privileges required at deployment time. For example, if you plan to deploy the Core feature using an external database by logging on to your cluster as `user1`, you can do the following:

As a cluster admin, create a ClusterRole resource using the `admin-core-external-db-deployment-role.yaml` file:

```
$ kubectl apply -f /path/to/git/srm-k8s/docs/roles/admin-core-external-db-deployment-role.yaml
```

As a cluster admin, create a ClusterRoleBinding resource:

```
$ kubectl create clusterrolebinding admin-core-external-db-deployment-role-binding --clusterrole=admin-core-external-db-deployment-role --user=user1
```

You can now log on to the cluster as `user1` and deploy the Core feature with an external database.

### Kubernetes Privileges for Scan Farm Feature Deployment

The [required Kubernetes privileges for the Scan Farm feature deployment](https://documentation.blackduck.com/bundle/coverity-docs/page/cnc/topics/infrastructure_prerequisites.html) are documented externally under the `Access privileges` section.

### Kubernetes Privileges for Tool Orchestration Feature Deployment

The required Kubernetes privileges for the Tool Orchestration feature deployment will depend on whether or not you use an external database. For external database deployments, refer to the [admin-tool-orchestration-external-db-deployment-role](./roles/admin-tool-orchestration-external-db-deployment-role.yaml) ClusterRole definition. Otherwise, refer to the [admin-tool-orchestration-deployment-role](./roles/admin-tool-orchestration-deployment-role.yaml) ClusterRole definition.

You can use a role YAML file to assign privileges required at deployment time. For example, if you plan to deploy the Tool Orchestration feature using an external database by logging on to your cluster as `user1`, you can do the following:

As a cluster admin, create a ClusterRole resource using the `admin-tool-orchestration-external-db-deployment-role.yaml` file:

```
$ kubectl apply -f /path/to/git/srm-k8s/docs/roles/admin-tool-orchestration-external-db-deployment-role.yaml
```

As a cluster admin, create a ClusterRoleBinding resource:

```
$ kubectl create clusterrolebinding admin-tool-orchestration-external-db-deployment-role-binding --clusterrole=admin-tool-orchestration-external-db-deployment-role --user=user1
```

You can now log on to the cluster as `user1` and deploy the Tool Orchestration feature with an external database.

## Helm Requirements

The Software Risk Manager deployment requires [helm](https://github.com/helm/helm/releases) version 3.8.0 or later.

## System Size

Although we often get asked what the hardware requirements are, there is no one answer since it largely depends on how many Software Risk Manager projects will be active at the same time, how frequently analyses will be conducted, whether built-in tools are being used, the number of results from tools in use, how many concurrent users are expected to use the system, and what other system interactions might be configured. Taking that into account, you can use some general guidelines to determine the size of your deployment.

| Size | Total Projects | Daily Analyses | Concurrent Analyses |
|:-|-:|-:|-:|
|Small|1 - 100|1,000|8|
|Medium|100 - 2,000|2,000|16|
|Large|2,000 - 10,000|10,000|32|
|Extra Large|10,000+|10,000+|64|

The Helm Prep Wizard (see [Full Installation](#installation---full)) includes a screen where you can specify the system size:

![Helm Prep Wizard Size](images/helm-prep-wizard-size.png "Helm Prep Wizard Size")

And the Helm Prep script will use the system size to set the `sizing.size` Helm values setting, and it will also configure any dependency charts according to the specified size. [Quick Starts](#installation---quick-start) use Unspecified, so they do not support automatic component sizing.

>Note: The system sizing capability does not apply to Scan Farm workloads.

The default system size is Unspecified. A system size specification will override most configurable resource requests. If you want to use specific resource requests, keep the `sizing.size` chart parameter at its default value.

## Core Feature Requirements

This section describes the web and web database requirements based on the system size.

### Core Web Workload Requirements

| Size | CPU Cores | Memory | IOPs | Storage |
|:-|-:|-:|-:|-:|
|Small|4|16 GB|3,000|64 GB|
|Medium|8|32 GB|6,000|128 GB|
|Large|16|64 GB|12,000|256 GB|
|Extra Large|32|128 GB|32,000|512 GB|

### Core Web Database Workload Requirements

| Size | CPU Cores | Memory | IOPs | Storage |
|:-|-:|-:|-:|-:|
|Small|4|16 GB|3,000|192 GB|
|Medium|8|32 GB|6,000|384 GB|
|Large|16|64 GB|12,000|768 GB|
|Extra Large|32|128 GB|32,000|1536 GB|

### Core Web Replica Database Workload Requirements

The replica database is an optional component when using the on-cluster MariaDB component.

| Size | CPU Cores | Memory | IOPs | Storage | Backup Storage |
|:-|-:|-:|-:|-:|-:|
|Small|2|8 GB|3,000|192 GB|576 GB|
|Medium|4|16 GB|6,000|384 GB|1152 GB|
|Large|8|32 GB|12,000|768 GB|2304 GB|
|Extra Large|16|64 GB|32,000|1536 GB|4608 GB|

### Core Persistent Storage Requirements

The Software Risk Manager web workload requires a Persistent Volume resource to store various files: the analysis inputs it receives, including the source code it displays on the Finding Details page, log files, and configuration files, to include data required to decrypt certain database records. By default, the volume will be provisioned dynamically at deployment time. The optional on-cluster MariaDB database usage determines whether additional, dynamically-provisioned Persistent Volume resources are needed.

| Volume | Feature | Description |
|:-|:-:|:-:|
| Web AppData | Core | Required volume for web workload |
| Primary DB Data | Core (w/ On-Cluster Database) | Database volume for primary database |
| Replica DB Data | Core (w/ On-Cluster Database) | Database volume for replica database |
| Replica DB Backup | Core (w/ On-Cluster Database) | Database volume for replica database backups |

### Core Internet Access Requirements

Software Risk Manager uses [internet access](https://documentation.blackduck.com/bundle/srm/page/install_guide/SRMConfiguration/internet-access.html) in the background for some activities, such as keeping tool data up-to-date and periodically checking for a new Software Risk Manager release.

Software Risk Manager does not require internet access; however, internet access is highly recommended to ensure full functionality.

To disable background internet access by Software Risk Manager, [customize your Software Risk Manager deployment](#customizing-software-risk-manager) by setting `codedx.offline-mode = true`. The default is false. Note that this will not disable any internet access that may occur due to user action or configuration settings, such as Tool Connector, Git, or Issue Tracker configurations.

When internet access is enabled, Software Risk Manager will perform the following actions:

- Update notifications - Software Risk Manager will periodically check for newer versions and display an update notification when one is available. Requests for the latest version are sent to https://service.codedx.com/updates/latestVersionData.json.
- Dependency-Check updates - Dependency-Check will periodically download updates from the National Vulnerability Database, the Retire.js repository, or reach out to Maven Central while scanning Java dependencies (this aids in the dependency identification process, to cut down on both false positive and false negative results). 
- If Software Risk Manager is in offline mode, this may lead to lower quality results when running Dependency-Check as a bundled tool.
- Secure Code Warrior - Unless noted elsewhere, Software Risk Manager will reach out to any URLs belonging to the securecodewarrior.com domain.

### Core Pod Security Admission Requirements

When enforcing policy violations with the optional [Kubernetes Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission) feature, the Core feature requires the `baseline` level.

## Scan Farm Feature Requirements

This section covers the requirements you must satisfy with the external dependencies you provide for the database, cache, and object storage layers.

### Scan Farm Database Requirements

The Scan Farm feature depends on a PostgreSQL database supporting versions 13 to 15, including all minor versions. Black Duck recommends using a DBaaS (database as a service) database. Configure your PostgreSQL database by reserving 1 CPU core and 2 GB RAM. The recommended database volume size is 5GB.

### Scan Farm Cache Requirements

Here are the requirements and recommendations for your Redis instance:

- Redis must be configured without eviction. You must ensure the Redis eviction policy is set to noeviction (maxmemory-policy=noeviction). The Cache Service design requires that all metadata be resident in Redis at all times. The Cache Service will refuse to start if Redis is not correctly configured.

- The Redis memory limit should be 1 GB. The Cache Service checks the memory usage of the Redis server at start-up and will not start if memory usage is more than 99% of the server limit.

- The Cache Service does not use Redis persistence; therefore, configure Redis without persistence. If persistence is enabled, the Redis pod memory limit must be significantly higher than the Redis server memory limit.

- Your Redis instance must permit network traffic from the Cache Service.

- Allocate 1 vCPU for on-cluster Redis workloads.

Black Duck recommends configuring your Redis instance with both authentication and TLS.

### Scan Farm Object Storage Requirements

The Scan Farm requires two buckets that must be created before deployment. A storage bucket would be considered a blob container when using Azure object storage.

The first bucket supports the Scan Service, and the second the Cache Service. The overall size requirements for Scan Service storage depend on scanning activity and retention period.

| Object Type | Average Size | Average Number of Scans | Retention Period | Total Average Size |
|:-|-:|-:|-:|-:|
| Scan Objects | M GB | N | T days | (M \* N \* T) GB |
| Client CLI Tools | 10 GB | n/a | 1 Release | 10 GB |
| Logs | 500 MB | n/a | T days | T/2 GB |

For example, if:
M = 0.25 GB per scan
N = 100 scans per day
T = 30-day retention period
CLI tools use 10 GB in total
Logs are .5 GB each
Using the equation: (M \* N \* T) GB + 10GB + T/2 GB

The total Scan Service storage bucket size is 750 GB (scan objects) + 10 GB (CLI tools) + 15 GB (logs) = 775 GB

>Note: Do not set an object expiration/deletion policy on the storage bucket.

The Cache Service bucket should not be geographically distributed and should not enable versioning, retention, or other special features. 

You must configure your Cache Service bucket with an object expiration greater than (not equal to) 7 days. When creating a life cycle policy on Azure, define the policy using the last modified date, not the creation date. The Cache Service checks that this lifecycle rule is present and will not start if a lifecycle policy retention period is not set.

Both buckets must support read/write access from the Cache Service and Storage Service. Additionally, the Cache Service must have permission to download the cache bucket's lifecycle policy. For example, with storage that supports the S3 API, the Cache Service will use the GetBucketLifecycleConfiguration API, which requires the s3:GetLifecycleConfiguration permission.

### Scan Farm Node Pool Requirements

The Scan Farm requires a separate node pool that supports nodes with 6.5 vCPUs and 26 GB of RAM. Meeting this requirement in your infrastructure might require a node pool of 8 vCPU and 32 GB RAM nodes. The nodes must include a Kubernetes taint for NodeType​=​​ScannerNode and a label of pool-type​=​small. A SAST analysis will consume a single node, so you should configure your node pool to scale horizontally as your scanning workload requires.

### Scan Farm Network Ports

The Software Risk Manager web pod communicates with Scan Farm pods using port 9998, and the Scan Farm pods communicate with the web pod using port 8080. For a complete list of network ports, refer to the Software Risk Manager chart and script resources:

- [Core NetworkPolicy](../chart/templates/networkpolicy.yaml)
- [Scan Farm Egress Ports](../ps/build/netpol.ps1)

>Note: If you also use the Tool Orchestration feature, refer to the [Tool Orchestration NetworkPolicy](../chart/templates/to-networkpolicy.yaml).

### Scan Farm Private Registry

When you enable the Scan Farm feature, you must pull Software Risk Manager Docker images from the Black Duck private Docker registry (Black Duck Repo) and push them to your private registry. This includes the Docker images for all the features you plan to install, not just Scan Farm-related ones. 

You can use a private registry hosted by a cloud provider (e.g., AWS, GCP, Azure, etc.) or deploy your own (see [registry.md](deploy/registry.md) for details).

### Scan Farm Ingress Requirements

The Scan Farm feature requires you to use an ingress controller, and your ingress controller must support multiple ingress resources referencing the same hostname. Black Duck recommends using either the [NGINX Community](https://kubernetes.github.io/ingress-nginx/deploy/) ingress controller or [OpenShift Routes](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/networking/configuring-routes).

### Scan Farm Internet Access Requirements

SCA scanning depends on an external Black Duck system hosted by Black Duck at `https://codesight.blackduck.com` (34.8.121.57). SCA scans will fail if this endpoint is inaccessible from your cluster.

The Scan Service also depends on the Black Duck Repo hosted at repo.blackduck.com (34.149.5.115). The service downloads Scan Farm components at boot time and will not work correctly without a Black Duck Repo connection.

### Scan Farm Default Pod Resources

Below are the default CPU and memory assigned to Scan Farm pods.

| Pod | CPU | Memory |
|:-|:-:|:-:|
| Scan Service                     | 100m  |   128Mi |
| Cache Service                    | 500m  |  1000Mi |
| Storage Service                  | 100m  |   128Mi |
| SAST Scan Job                    | 6500m | 26000Mi |
| SCA Scan Job (buildless scan)    | 1500m |  1500Mi |
| SCA Scan Job (Bridge-based scan) | 1500m |   500Mi |

>Note: Refer to the [Scan Farm Job Resources](#scan-farm-job-resources) section for how to customize resource requirements for Scan Farm jobs.

## Tool Orchestration Feature Requirements

The initial MinIO volume size should be 64 GB when not using external object storage. External object storage can be provided by any storage system that supports an AWS S3-compliant API (e.g., AWS, GCP, MinIO, etc.).

### Tool Service Workload Requirements

| Size | CPU Cores | Memory | Replicas
|:-|-:|-:|-:|
|Small|1|1024 Mi|1|
|Medium|2|2048 Mi|2|
|Large|2|2048 Mi|3|
|Extra Large|2|2048 Mi|4|

### Workflow Controller Workload Requirements

| Size | CPU Cores | Memory
|:-|-:|-:|
|Small|.5|500 Mi|
|Medium|1|1000 Mi|
|Large|2|1500 Mi|
|Extra Large|4|2000 Mi|

### On-Cluster Workflow Storage Requirements (MinIO)

The MinIO pod is not applicable when using external workflow object storage (e.g., AWS S3).

| Size | CPU Cores | Memory | Storage
|:-|-:|-:|-:|
|Small|2|5120 Mi|64 GB|
|Medium|4|10240 Mi|128 GB|
|Large|8|20480 Mi|256 GB|
|Extra Large|16|40960 Mi|512 GB|

### Add-in Tool Workload Requirements

Deployments that include the Tool Orchestration feature support orchestrated analyses that let you run both built-in and custom [add-ins](https://github.com/codedx/srm-add-ins) on your cluster. Refer to the [Tool Orchestration Add-in Resource Requirements](#tool-orchestration-add-in-resource-requirements) section for add-in tool pod resources that you can set on a global, tool, project, or project tool basis.

By default, add-in tools use a 500m CPU request with a 2000m CPU limit and make a request for 500Mi memory with a 2G limit.

### Tool Orchestration Persistent Storage Requirements

When using Tool Orchestration without external object storage, a single, dynamically-provisioned Persistent Volume resource is required for orchestrated analysis workflow storage, including analysis inputs, results, and related tool log files. Refer to the [On-Cluster Workflow Storage Requirements](#on-cluster-workflow-storage-requirements) section for default volume capacity based on system size.

By default, Software Risk Manager will automatically remove old analyses and related storage from the tool service. Related tool results and findings will be retained when workflow storage gets cleaned up. Workflow cleanup is enabled by default, allowing storage for 100 completed analyses to exist in a success or failure state, with a maximum of five completed analyses per project.

Additional analyses beyond the limits will remove the storage for the oldest analysis. To adjust workflow cleanup behavior, [customize your Software Risk Manager deployment](#customizing-software-risk-manager) by setting these parameters:

```
- tws.storage.cleanup.enabled = true
- tws.storage.cleanup.max-total-analyses = 100
- tws.storage.cleanup.max-analyses-per-project = 5
```

You can use this expression to estimate your maximum workflow storage requirement:

```
(tws.storage.cleanup.max-total-analyses * average-analysis-input-size) +
(tws.storage.cleanup.max-total-analyses * average-analysis-result-size) +
(tws.storage.cleanup.max-total-analyses * average-tool-log-size)
```

You can use this expression to estimate your workflow storage requirement for completed analyses when the total analysis count is less than tws.storage.cleanup.max-total-analyses:

```
(tws.storage.cleanup.max-analyses-per-project * project-count * average-analysis-input-size) +
(tws.storage.cleanup.max-analyses-per-project * project-count * average-analysis-result-size) +
(tws.storage.cleanup.max-analyses-per-project * project-count * average-tool-log-size)
```

### Tool Orchestration Add-in Resource Requirements

Software Risk Manager can create orchestrated analyses that run one or more application security testing tools where each tool has access to its host's memory and CPU resources. Using Kubernetes tools, you can control the memory and CPU capacity available for analyses. You can also improve Kubernetes scheduling outcomes by requesting CPU or memory capacity for specific tools or projects. Resource requirements can also include a node selector and pod toleration, with taint effects NoSchedule and NoExecute, to influence further where tools run on your cluster.

The resource requirements feature cannot be configured using the Software Risk Manager user interface, but you can use the kubectl command to define configuration maps (ConfigMaps) that cover specific scopes determined by a special naming convention. The tool service will look for and read optional ConfigMaps to determine how resource requirements apply to a particular tool run.

Resource requirements containing CPU and memory instructions translate to Kubernetes resource requests and limits and fit with any other related Kubernetes configuration, such as a resource limit defined for a Kubernetes namespace. You can specify resource requirement data by using the following ConfigMap field names:

- requests.cpu – Kubernetes CPU request (e.g., 1).
- requests.memory – Kubernetes memory request (e.g., 1G).
- limits.cpu – Kubernetes CPU limit (e.g., 2).
- limits.memory – Kubernetes memory limit (e.g., 2G).
- nodeSelectorKey – key portion of a label associated with a node selector (e.g., purpose).
- nodeSelectorValue – value portion of a label associated with a node selector.
- podTolerationKey – key portion of a taint with the NoSchedule and NoExecute taint effects (e.g., dedicated).
- podTolerationValue – value portion of a taint with the NoSchedule and NoExecute taint effects (e.g., tools).
- init.limits.cpu - Kubernetes CPU limit for init workflow containers (e.g., 1).
- init.limits.memory - Kubernetes memory limit for init workflow containers (e.g., 1G).
- wait.limits.cpu - Kubernetes CPU limit for init workflow containers (e.g., 1).
- wait.limits.memory - Kubernetes memory limit for init workflow containers (e.g., 1G).

Below are the default CPU and memory settings for add-in tools. Refer to the [Tool Orchestration Add-in Tool Configuration](#tool-orchestration-add-in-tool-configuration) section for how to customize resource requirements for your Software Risk Manager deployment.

| Resource | Request | Limit |
|:-|:-:|:-:|
| CPU | 500m | 2000m |
| Memory | 500Mi | 2G |

>Note: There are no defaults for add-in node selectors, pod tolerations, or the CPU and memory limits for init/wait containers.

If you are using a ResourceQuota definition, you should set the limits for the CPU and memory of init/wait containers, which support a tool's main container.

### Tool Orchestration Pod Security Admission Requirements

When enforcing policy violations with the optional [Kubernetes Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission) feature, the Tool Orchestration feature requires the `privileged` level.

# External Web Database Pre-work

Software Risk Manager includes a MariaDB database that requires no configuration on your part. You can skip this section if you plan to use the on-cluster database instance.

If you prefer an external database, the web workload supports MariaDB version 10.6.x and MySQL version 8.0.x. Complete the following pre-work before installing Software Risk Manager with an external web database.

## External Web Database Pre-work - Instance Configuration

Your MariaDB/MySQL database must include the following variable configuration.

- optimizer_search_depth=0
- character_set_server=utf8mb4
- collation_server=utf8mb4_general_ci
- lower_case_table_names=1
- log_bin_trust_function_creators=1

The log_bin_trust_function_creators parameter is required when using replication, enabled by default with the AWS MariaDB/MySQL Production template.

If you are using a database instance hosted by AWS, Azure, or GCP, refer to [how to create a new AWS parameter group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html), [how to configure Azure Database for MySQL parameters](https://learn.microsoft.com/en-us/azure/mysql/single-server/how-to-server-parameters), or [how to configure GCP Cloud SQL MySQL database flags](https://cloud.google.com/sql/docs/mysql/flags).

Refer to the Web Database Workload Requirements section for database instance configuration details. You must pre-create the database catalog and the Software Risk Manager database user with the following steps.

## External Web Database Pre-work - Password Authentication

If you plan to have the SRM web application authenticate with a username and password, follow the steps in this section after completing the [instance configuration](#external-web-database-pre-work---instance-configuration).

>Note: If you have to reinstall Software Risk Manager and purge your Software Risk Manager data, you must repeat Steps 2 and 3 after deleting your Software Risk Manager Persistent Volume.

1. Create a database user. You can customize the following statement that creates a user named "srm," remove 'REQUIRE SSL' when not using TLS (your database instance may require transport security).
    ```
    CREATE USER 'srm'@'%' IDENTIFIED BY 'enter-a-password-here' REQUIRE SSL;
    ```

    >Note: If your database sets the `require_secure_transport` parameter to true, include `REQUIRE SSL`.

2. Create a database catalog. The following statement creates a catalog named srmdb.
    ```
    CREATE DATABASE srmdb;
    ```
3. Grant required privileges on the database catalog to the database user you created. The following statements grant permissions to the srm database user.
    ```
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, ALTER, REFERENCES, INDEX, DROP, TRIGGER ON srmdb.* to 'srm'@'%';
    FLUSH PRIVILEGES;
    ```
4. If your database configuration requires Software Risk Manager to trust a certificate (e.g., the [Amazon RDS root certificate](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions)), download the certificate to make it available later in the Helm Prep Wizard.

    >Note 1: If your database sets the `require_secure_transport` parameter to true, you must ensure that Software Risk Manager trusts its certificate.

    >Note 2: Using an external database with TLS is recommended. If you plan to use an unencrypted connection to an external MySQL database with the `caching_sha2_password` default_authentication_plugin, refer to [Specify MySQL Server Public Key Path](#specify-mysql-server-public-key-path).

5. Apply any configuration changes required to allow a cluster workload to reach your external database instance over the network.

## External Web Database Pre-work - RDS IAM Authentication

If you plan to have the SRM web application authenticate to an AWS RDS database via AWS IAM workload identity, follow the steps in this section after completing the [instance configuration](#external-web-database-pre-work---instance-configuration).

>Note: If you have to reinstall Software Risk Manager and purge your Software Risk Manager data, you must repeat Steps 3 and 4 after deleting your Software Risk Manager Persistent Volume.

1. [Enable RDS IAM authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Enabling.html) on your RDS database instance.

2. Create a database user. You can customize the following statements that create an "srm" database user.
    ```
    CREATE USER 'srm' IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';
    ALTER USER 'srm'@'%' REQUIRE SSL;
    ```

3. Create a database catalog. The following statement creates a catalog named srmdb.
    ```
    CREATE DATABASE srmdb;
    ```

4. Grant required privileges on the database catalog to the database user you created. The following statements grant permissions to the srm database user.
    ```
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, ALTER, REFERENCES, INDEX, DROP, TRIGGER ON srmdb.* to 'srm'@'%';
    FLUSH PRIVILEGES;
    ```

5. [Download the AWS certificate](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions) for your database instance to make it available later in the Helm Prep Wizard.

6. Apply any configuration changes (security group, network connectivity, etc.) required to allow a cluster workload to reach your RDS instance over the network.

7. [Create an IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) for your cluster.

8. [Create an IAM Policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html) using the policy JSON below after replacing the placeholders with your AWS subscription and database details.

    You must make the following replacements in the below policy JSON:
    - \<your-aws-account-id>: replace with your AWS subscription account number (e.g. 111111111111)
    - \<db-user-name>: replace with the AWSAuthenticationPlugin database username you created (e.g., srm)
    - \<your-rds-DbClusterResourceId>: replace with the Resource ID (e.g., see your RDS' instance Configuration tab)
    - \<your-rds-db-user-name>: replace with your AWS region name (e.g., us-east-2)
    ```
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "rds-db:connect"
          ],
          "Resource": [
            "arn:aws:rds-db:<your-aws-region>:<your-aws-account-id>:dbuser:<your-rds-DbClusterResourceId>/<your-rds-db-user-name>"
          ]
        }
      ]
    }
    ```

9. Create an IAM Role using of the `Web identity` trusted entity type. Specify your clusters OIDC provider, with an `sts.amazonaws.com` audience, and link the IAM Policy you created above.

10. Update your new IAM Role by editing its trusted entity JSON to include an additional criterion that references the Kubernetes namespace and ServiceAccount name that you will eventually create and link to the role. 

    The example below uses the following placeholders to show what your role's trust policy will look like by default.

    - account-id: 111111111111
    - region: aws-region
    - oidc-id: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    - namespace: srm
    - service-account-name: srm-svc-acct

    ```
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Federated": "arn:aws:iam::111111111111:oidc-provider/oidc.eks.aws-region.amazonaws.com/id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
              },
              "Action": "sts:AssumeRoleWithWebIdentity",
              "Condition": {
                  "StringEquals": {
                      "oidc.eks.aws-region.amazonaws.com/id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:aud": "sts.amazonaws.com"
                  }
              }
          }
      ]
    }
    ```

    Edit your role by adding a criterion that references the SRM Kubernetes namespace and ServiceAccount name you plan to associate with the role. Note that you will create the namespace and service account resources later. Below is an updated example with an extra criterion that uses the `oidc-id` placeholder mentioned earlier, an `srm` namespace, and an `srm-svc-acct` ServiceAccount name. Specify your OIDC identifier and the namespace and service account name you plan to use.

    ```
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Federated": "arn:aws:iam::111111111111:oidc-provider/oidc.eks.aws-region.amazonaws.com/id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
              },
              "Action": "sts:AssumeRoleWithWebIdentity",
              "Condition": {
                  "StringEquals": {
                      "oidc.eks.aws-region.amazonaws.com/id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:sub": "system:serviceaccount:srm:srm-svc-acct",
                      "oidc.eks.aws-region.amazonaws.com/id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:aud": "sts.amazonaws.com"
                  }
              }
          }
      ]
    }
    ```

11. Create a new file named `sa.yaml` with the following content, replacing the \<iam-role-arn> placeholder with the AWS ARN that represents your IAM role. If you used alternate namespace or service account names in the previous step, specify those values in place of what is shown below.

    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: srm-svc-acct
      namespace: srm
      annotations:
        eks.amazonaws.com/role-arn: <iam-role-arn> 
    ```

12. Create the namespace and service account that will be linked to your IAM role, replacing the namespace name if you used a value other than `srm`.

    ```
    $ kubectl create ns srm
    $ kubectl apply -f /path/to/sa.yaml
    ```

13. Note the Kubernetes ServiceAccount name, namespace, and the certificate to trust when connecting to your RDS database to enter them in the Helm Prep Wizard when you select RDS IAM database authentication.

# Persistent Storage Pre-work

Software Risk Manager depends on one or more Persistent Volume resources, depending on the features you install and how you configure them. You will always have at least one volume for the Core feature's web component. Dynamic volume provisioning is required by default. Refer to the following sections for Kubernetes provider-specific instructions.

## Volume Configuration Pre-work

Consider using Persistent Volumes with a [Retain reclaim policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#retain). Volumes associated with a [Delete reclaim policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#delete) will be lost if a Persistent Volume Claim is inadvertently deleted. Dynamic volume provisioning will use the [reclaim policy](https://kubernetes.io/docs/concepts/storage/storage-classes/#reclaim-policy) specified by the [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource).

>Note: You can edit Persistent Volume resources to change the retention policy of existing volumes.

Should volume resizing be necessary in the future, consider using Persistent Volumes that [allow volume expansion](https://kubernetes.io/docs/concepts/storage/storage-classes/#allow-volume-expansion).

## AWS Persistent Storage Pre-work

Software Risk Manager supports EBS and EFS storage volumes for the web workload. Do not use AWS EFS for database-related volumes.

### AWS EBS Persistent Storage Pre-work

If you plan to use AWS EBS storage, install the [AWS EBS CSI Driver EKS Addon](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) before continuing.

### AWS EFS Persistent Storage Pre-work

This section describes using AWS EFS storage for your Software Risk Manager Web volume. The AWS EFS CSI driver supports dynamic provisioning. This example uses static provisioning and demonstrates how the Software Risk Manager chart can reference a bound Persistent Volume Claim resource.

>Note: These steps assume that you are using the Software Risk Manager Core feature with an external database. 

1) Create and configure an [EFS filesystem](https://aws.amazon.com/pm/efs). Ensure that available network mounts exist in each Availability Zone before continuing and that inbound network rules permit network traffic on port 2049 from your cluster workloads.

2) Install the [AWS EFS CSI Driver EKS Addon](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)

3) Save this StorageClass content to a file named efs-storageclass.yaml:

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
```

4) Create the StorageClass resource with the following command:

```
kubectl apply -f ./efs-storageclass.yaml
```

5) Replace the \<volume-handle-id\> (e.g., fs-07b385603296a82db) placeholder and save the below YAML to a file named srm-web-appdata-pv.yaml:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: srm-web-appdata
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: <volume-handle-id>
```

6) Create the PersistentVolume resource with the following command:

```
kubectl apply -f ./srm-web-appdata-pv.yaml
```

7) Create the Software Risk Manager namespace, replacing the namespace name as necessary:

```
kubectl create ns srm
```

8) Save this PersistentVolumeClaim content to a file named srm-web-appdata-pvc.yaml, replacing the namespace name as necessary:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: srm-web-appdata
  namespace: srm
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 1Gi
```

9) Create the PersistentVolumeClaim resource with the following command:

```
kubectl apply -f ./srm-web-appdata-pvc.yaml
```

10) Wait for the PersistentVolumeClaim to reach a Bound status, check by periodically running the following command, replacing the namespace name as necessary:

```
kubectl -n srm get pvc srm-web-appdata
```

11) Save this Job content to a file named srm-web-appdata-job.yaml, replacing the namespace name as necessary:

```
apiVersion: batch/v1
kind: Job 
metadata:
  name: srm-web-appdata
  namespace: srm
spec:
  template:
    spec:
      containers:
      - name: srm-web-appdata
        image: busybox
        command: ["/bin/sh"]
        args: ["-c", "cd /data && chmod 2775 . && chown root:1000 ."]
        volumeMounts:
        - name: srm-web-appdata-storage
          mountPath: /data
      restartPolicy: Never
      volumes:
      - name: srm-web-appdata-storage
        persistentVolumeClaim:
          claimName: srm-web-appdata
```

12) Create the Job resource with the following command:

```
kubectl apply -f ./srm-web-appdata-job.yaml
```

13) Wait for the Job to complete, check by periodically running the following command, replacing the namespace name as necessary:

```
kubectl -n srm get job srm-web-appdata
```

14) If you already have an srm-extra-props.yaml file, merge the below content into your existing file. Otherwise, create your srm-extra-props.yaml file (see [Customizing Software Risk Manager](#customizing-software-risk-manager)) and add the following content:

```
web:
  persistence:
    existingClaim: srm-web-appdata
```

15) Refer to [Customizing Software Risk Manager](#customizing-software-risk-manager) for how to rerun helm with your srm-extra-props.yaml file.
 
# Scan Farm Pre-work

Software Risk Manager does not include the dependencies required for the Scan Farm features. You can skip this section if you do not plan to use the Scan Farm feature. Complete the following pre-work before installing the Scan Farm.

## Private Docker Registry

When using the Scan Farm feature, you must have access to a private registry where you will store Software Risk Manager Docker images. Determine whether your private registry requires a Kubernetes Image Pull Secret. Your private registry may not require an explicit username and password if your cluster's configuration already includes access. If you need a registry credential, identify the username and password, but do not pre-create the Kubernetes Image Pull Secret.

Determine whether you will use a prefix for repositories added to your private registry. Your registry may require one, or you may create one to simplify pushing Docker images by pre-creating a single repository. For example, if you use Google Cloud Platform Artifact Registry in the us-central1 region, your registry host will be us-central1-docker.pkg.dev, but your repository prefix could be my-gcp-project-name/srm (assuming a GCP project named "my-gcp-project-name"). In that case, you should pre-create the srm repository before pushing Docker images from Black Duck Repo to us-central1-docker.pkg.dev/my-gcp-project-name/srm.

You can find instructions for pulling the latest Software Risk Manager Docker images for Scan Farm deployments [here](deploy/registry.md).

## AWS Scan Farm Pre-work

You can satisfy Scan Farm feature dependencies with AWS services.

### EKS Scanner Nodes Pre-work

Create a new [EKS node group](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) for your Scan Farm nodes. Select an instance type that includes 8 vCPUs and 32 GiB of RAM. 

![EKS Node Group](images/aws-node-group.png "EKS Node Group")

In the "Kubernetes label" section, add a label with Key=pool-type and Value=small.

![EKS Node Group Label](images/aws-node-group-label.png "EKS Node Group Label")

In the "Kubernetes taint" section, add a taint with Key=NodeType, Value=ScannerNode, and Effect=NoSchedule.

![EKS Node Group Taint](images/aws-node-group-taint.png "EKS Node Group Taint")

### RDS for PostgreSQL (Database) Pre-work

Create a new [RDS for PostgreSQL database](https://aws.amazon.com/rds/postgresql) instance to host the Scan Farm's database catalogs for the Scan Service and Storage Service.

![AWS PostgreSQL](images/aws-postgresql.png "AWS PostgreSQL")

Allocate storage capacity and specify an instance size that meets the CPU and memory requirements in the Scan Farm Database Requirements section.

![AWS PostgreSQL Instance](images/aws-postgresql-instance.png "AWS PostgreSQL Instance")

Your PostgreSQL database instance must permit network traffic from the Storage Service and Scan Service pods. For example, if your database is in the same VPC as your EKS cluster, update your RDS security group by adding your EKS cluster security group.

![AWS PostgreSQL Network](images/aws-postgresql-network.png "AWS PostgreSQL Network")

### ElastiCache for Redis (Cache) Pre-work

You will create a new [ElastiCache for Redis](https://aws.amazon.com/elasticache/redis) instance to host the Scan Farm cache. First you must create a custom parameter group to apply required settings to your cluster.

![AWS Redis Parameter Group](images/aws-redis-parameter-group.png "AWS Redis Parameter Group")

Specify "noeviction" for the maxmemory-policy parameter. The Cache Service will fail to start with the default value for maxmemory-policy.

![AWS Redis Parameter Value](images/aws-redis-parameter-value.png "AWS Redis Parameter Value")

Create a new Redis cluster using an option where you can specify your parameter group and choose your instance size.

![AWS Redis](images/aws-redis.png "AWS Redis")

The memory limit should be 1 GB, however, this should be adjusted based on your requirements. The Cache Service checks the memory usage of the Redis server at start-up and will not start if memory usage is more than 99% of the server limit.

![AWS Redis Details](images/aws-redis-details.png "AWS Redis Details")

Your cache instance must permit network traffic from the Cache Service pod.

![AWS Redis Network](images/aws-redis-network.png "AWS Redis Network")

Consider enabling authentication and TLS for your cache instance. If you enable TLS, you must download the certificate file for your Redis instance. Running openssl with the s_client parameter from a system with cache connectivity is one way to obtain your Redis certificate file.

![AWS Redis Auth](images/aws-redis-auth.png "AWS Redis Auth")

### Simple Storage Service (Object Storage) Pre-work

Create two new [Simple Storage Service](https://aws.amazon.com/s3) buckets, one for the Storage Service and one for the Cache Service.

![AWS Storage Storage Bucket](images/aws-object-storage-storage.png "AWS Storage Storage Bucket")

After creating the cache bucket, open the bucket details page.

![AWS Storage Cache Bucket](images/aws-object-storage-cache.png "AWS Storage Cache Bucket")

You must define a cache bucket lifecycle policy with an object expiration greater than (not equal to) 7 days. The Cache Service checks that this lifecycle rule is present and will not start if a lifecycle policy retention period is not set. The bucket details screen allows you to create a new lifecycle policy rule. Define a new "Delete object" rule that expires current versions of objects after 8 days or more.

![AWS Storage Cache Bucket Add Rule](images/aws-object-storage-cache-lifecycle.png "AWS Storage Cache Bucket Add Rule")

Ensure that the Cache Service and Storage Service have network connectivity to their buckets.

Software Risk Manager requires read/write bucket access, and access to the cache bucket's lifecycle policy is required (s3:GetLifecycleConfiguration permission). You can use an AWS account's access and secret key or you can configure [AWS IAM Roles for Service Account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to link an IAM role to a Kubernetes service account that the Cache Service and Storage Service will use for bucket access.

## GCP Scan Farm Pre-work

You can satisfy Scan Farm feature dependencies with GCP services.

### GKE Scanner Nodes Pre-work

Create a new [GKS node pool](https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools) for your Scan Farm nodes. Select an instance type that includes 8 vCPUs and 32 GiB of RAM. 

![GKE Node Pool](images/gcp-node-pool.png "GKE Node Pool")

Visit the "Metadata" page before clicking "Create" to generate your node pool. In the "Kubernetes labels" section (not the "Labels" section), click "ADD KUBERNETES LABEL" and specify Key=pool-type and Value=small.

![GKE Node Pool Label](images/gcp-node-pool-label.png "GKE Node Pool Label")

 In the "Node taints" section, click "ADD TAINT" and specify Key=NodeType, Value=ScannerNode, and Effect=NoSchedule.

![GKE Node Pool Taint](images/gcp-node-pool-taint.png "GKE Node Pool Taint")

### Cloud SQL for PostgreSQL (Database) Pre-work

Create a new [PostgreSQL database](https://cloud.google.com/sql/docs/postgres) instance to host the Scan Farm's database catalogs for the Scan Service and Storage Service.

![GCP PostgreSQL](images/gcp-postgresql.png "GCP PostgreSQL")

Allocate storage capacity and specify an instance size that meets the CPU and memory requirements in the Scan Farm Database Requirements section.

![GCP PostgreSQL Instance](images/gcp-postgresql-instance.png "GCP PostgreSQL Instance")

Your PostgreSQL database instance must permit network traffic from the Storage Service and Scan Service pods.

![GCP PostgreSQL Network](images/gcp-postgresql-network.png "GCP PostgreSQL Network")

### Memorystore for Redis (Cache) Pre-work

Create a new [Memorystore for Redis](https://cloud.google.com/memorystore) instance to host the Scan Farm cache.

![GCP Redis](images/gcp-redis.png "GCP Redis")

The memory limit should be 1 GB, however, this should be adjusted based on your requirements. The Cache Service checks the memory usage of the Redis server at start-up and will not start if memory usage is more than 99% of the server limit.

![GCP Redis Capacity](images/gcp-redis-capacity.png "GCP Redis Capacity")

Your cache instance must permit network traffic from the Cache Service pod.

![GCP Redis Network](images/gcp-redis-network.png "GCP Redis Network")

Your instance must include a maxmemory-policy that is set to noeviction. The Cache Service design requires that all metadata be resident in Redis at all times. The Cache Service will refuse to start if Redis is not correctly configured.

![GCP Redis MemPolicy](images/gcp-redis-mempolicy.png "GCP Redis MemPolicy")

Consider enabling authentication and TLS for your cache instance.

![GCP Redis Auth](images/gcp-redis-auth.png "GCP Redis Auth")

If you enable TLS, open your instance configuration details and download the instance's CA certificate from the TLS Certificate Authority section of the Security page.

![GCP Redis Cert Download](images/gcp-redis-cert-download.png "GCP Redis Cert Download")

### Cloud Storage (Object Storage) Pre-work

Create two new [Cloud Storage](https://cloud.google.com/storage) buckets, one for the Storage Service and one for the Cache Service.

![GCP Storage Storage Bucket](images/gcp-object-storage-storage.png "GCP Storage Storage Bucket")

After creating the cache bucket, open the bucket details page.

![GCP Storage Cache Bucket](images/gcp-object-storage-cache.png "GCP Storage Cache Bucket")

You must define a cache bucket lifecycle policy with an object expiration greater than (not equal to) 7 days. The Cache Service checks that this lifecycle rule is present and will not start if a lifecycle policy retention period is not set. The bucket details screen allows you to create a new lifecycle policy rule. Define a new "Delete object" rule that uses an "Age" condition to remove objects older than 8+ days. 

![GCP Storage Cache Bucket Add Rule](images/gcp-object-storage-cache-lifecycle-add-rule.png "GCP Storage Cache Bucket Add Rule")

Ensure that the Cache Service and Storage Service have network connectivity to their buckets. Software Risk Manager requires read/write bucket access, and access to the cache bucket's lifecycle policy is required. Grant bucket permission to a GCP service account that the Software Risk Manager will use for bucket access.

![GCP Storage Permissions](images/gcp-object-storage-permissions.png "GCP Storage Permissions")

Create a new JSON key for the GCP service account with bucket access.

![GCP Storage Key](images/gcp-object-storage-key.png "GCP Storage Key")

## Azure Scan Farm Pre-work

You can satisfy Scan Farm feature dependencies with Azure services. 

### AKS Scanner Nodes Pre-work

Create a new [AKS node pool](https://learn.microsoft.com/en-us/azure/aks/create-node-pools) for your Scan Farm nodes. Select an instance type that includes 8 vCPUs and 32 GiB of RAM. 

![Azure Node Pool](images/azure-node-pool.png "Azure Node Pool")

Visit the "Optional settings" page before clicking "Review + Create" to generate your node pool. In the "Labels" section, specify Key=pool-type and Value=small.

![Azure Node Pool Label](images/azure-node-pool-label.png "Azure Node Pool Label")

In the "Taints" section, specify Key=NodeType, Value=ScannerNode, and Effect=NoSchedule.

![Azure Node Pool Taint](images/azure-node-pool-taint.png "Azure Node Pool Taint")

### Azure Database for PostgreSQL (Database) Pre-work

Create a new [PostgreSQL database](https://azure.microsoft.com/en-us/products/postgresql) instance to host the Scan Farm's database catalogs for the Scan Service and Storage Service.

![Azure PostgreSQL](images/azure-postgresql.png "Azure PostgreSQL")

Allocate storage capacity and specify an instance size that meets the CPU and memory requirements in the Scan Farm Database Requirements section.

![Azure PostgreSQL Instance](images/azure-postgresql-instance.png "Azure PostgreSQL Instance")

Your PostgreSQL database instance must permit network traffic from the Storage Service and Scan Service pods.

![Azure PostgreSQL Network](images/azure-postgresql-network.png "Azure PostgreSQL Network")

### Azure Cache for Redis (Cache) Pre-work

You will create a new [Azure Cache for Redis](https://azure.microsoft.com/en-us/products/cache/) instance to host the Scan Farm cache. The memory limit should be 1 GB, however, this should be adjusted based on your requirements. The Cache Service checks the memory usage of the Redis server at start-up and will not start if memory usage is more than 99% of the server limit.

![Azure Redis](images/azure-redis.png "Azure Redis")

Your cache instance must permit network traffic from the Cache Service pod.

Your instance must include a maxmemory-policy that is set to noeviction. The Cache Service design requires that all metadata be resident in Redis at all times. The Cache Service will refuse to start if Redis is not correctly configured.

![Azure Redis MemPolicy](images/azure-redis-mempolicy.png "Azure Redis MemPolicy")

Your instance must include a maxmemory-policy that is set to noeviction. The Cache Service design requires that all metadata be resident in Redis at all times. The Cache Service will refuse to start if Redis is not correctly configured.

You can obtain your Redis key by clicking the "Access keys" link for your Azure Cache for Redis instance.

![Azure Redis Auth](images/azure-redis-auth.png "Azure Redis Auth")

Your Azure Cache for Redis will use a certificate issued by DigiCert Global G2 CA Root ([as of May 2022](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-whats-new#tls-certificate-change)). You can find Azure certificates [here](https://learn.microsoft.com/en-us/azure/security/fundamentals/azure-ca-details).

### Azure Cloud Storage (Object Storage) Pre-work

>Note: Scan Farm support for Azure object storage will be available with SRM 2023.12.0.

Create a new [Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create) to host two containers, one for the Storage Service and one for the Cache Service.

![Azure Storage Account](images/azure-create-storage.png "Azure Storage Account")

The storage account name you specify will become part of the URL used to access your storage containers.

![Azure Storage Account](images/azure-storage-account-name.png "Azure Storage Account")

Create a [blob container](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-containers-portal) in your storage account for the Storage Service.

![Azure Storage Container](images/azure-object-storage-storage.png "Azure Storage Container")

Create a second [blob container](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-containers-portal) in your storage account for the Cache Service.

![Azure Cache Container](images/azure-object-storage-cache.png "Azure Cache Container")

You must define a storage account lifecycle policy that deletes cache container blobs greater than (not equal to) 7 days old. The Cache Service checks that this lifecycle rule is present and will not start if a lifecycle policy retention period is not set. Create a new [Lifecycle management policy](https://learn.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-policy-configure) for your storage account. The lifecycle management rule must specify a rule scope that uses a filter set to limit scope to the cache blob.

![Azure Lifecycle Rule Details](images/azure-object-storage-cache-lifecycle-add-rule-details.png "Azure Lifecycle Rule Details")

Set the if-then rule to delete blobs whose last modified date is 8 days or older. Define the policy using Last modified (the Cache Service validation will not accept a policy based on Created).

![Azure Lifecycle Rule Base](images/azure-object-storage-cache-lifecycle-add-rule-base.png "Azure Lifecycle Rule Base")

The lifecycle rule should not apply to the Storage Service blob container, so enter your Cache Storage blob container name as the Blob prefix of your filter set.

![Azure Lifecycle Rule Filter](images/azure-object-storage-cache-lifecycle-add-rule-filter-set.png "Azure Lifecycle Rule Filter")

To configure Azure object storage, you will need the following information:

- Subscription ID
- Tenant ID
- Storage Account Azure Resource Group
- Storage Account Name
- Storage Account Access Key
- Storage Account Endpoint
- Azure Microsoft Entra ID Application (client) ID
- Azure Microsoft Entra ID Client Secret

>Note: Microsoft Entra ID is the new name for Azure Active Directory.

You can find your subscription ("id" field) and tenant identifiers ("tenantId" field) using the following command.

```
az account show
```

You can obtain your Storage Account Access Key by clicking the "Access keys" link for your storage account.

![Azure Storage Account Key](images/azure-object-storage-access-keys.png "Azure Storage Account Key")

You can obtain your Storage Account Endpoint by clicking the "Endpoints" link for your storage account. The "Blob service" field contains your endpoint.

![Azure Storage Endpoints](images/azure-object-storage-endpoints.png "Azure Storage Endpoints")

The Scan Farm depends on a [Microsoft Entra ID app registration](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) with read/write access to your Azure storage containers. You must register a new application with Microsoft Entra ID.

![Azure App Registration](images/azure-object-storage-app-register.png "Azure App Registration")

You can obtain your App Registration "application (client) ID" by clicking the "Overview" link for your registration.

![Azure App Registration Client ID](images/azure-object-storage-app-register-client-id.png "Azure App Registration Client ID")

You can obtain your App Registration client secret value by clicking the "Certificates & secrets" link for your registration.

![Azure App Registration Client Secret](images/azure-object-storage-app-register-client-secret.png "Azure App Registration Client Secret")

You must grant your app registration read/write access to your storage account containers along with access to read the delete blob policy you created. You can add a new role assignment by clicking the "Access Control (IAM)" link for your storage account.

![Azure App Registration Access](images/azure-object-storage-app-register-access.png "Azure App Registration Access")

Your storage account role assignment should reference your app registration. As an example, you can grant read/write blob container policy with the Azure Storage Blob Data Contributor role and policy access with the Storage Account Contributor role.

![Azure App Registration Role](images/azure-object-storage-app-role-assignment.png "Azure App Registration Role")

Ensure that the Cache Service and Storage Service have network connectivity to their blob containers.

## On-Cluster Scan Farm Pre-work

You can satisfy Scan Farm feature dependencies with components you install on your cluster. Note the license type for the components listed below. You are responsible for compliance with the licenses of third-party components.

### Scanner Nodes Pre-work

Scan Farm SAST or SCA analyses require a dedicated node pool with a specific node label and taint. You can run more than one SCA scan on a single node, but a single SAST analysis requires exclusive node access during the scan. You can assign a node label and taint using the following command where "scan-farm-worker-node-name" represents the name of a cluster node.

```
kubectl label --overwrite node scan-farm-worker-node-name pool-type=small
kubectl taint node scan-farm-worker-node-name NodeType=ScannerNode:NoSchedule
```

If using a cloud-hosted node pool, specify the node label and taint with your node pool configuration so that generated nodes meet Scan Farm requirements.

### Bitnami PostgreSQL Chart Pre-work

The PostgreSQL license is available [here](https://www.postgresql.org/about/licence/). The Bitnami PostgreSQL Helm chart license is available [here](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#license).

Allocate storage capacity and specify an instance size that meets the CPU and memory requirements in the Scan Farm Database Requirements section. The following is an example of the PostgreSQL chart parameters for version 11.6.2 that customizes PostgreSQL to meet Scan Farm requirements:

```
image:
  repository: bitnamilegacy/postgresql
primary:
  persistence:
    size: 5Gi
  resources:
    limits:
      memory: 2Gi
      cpu: 1000m
```

If you store the above YAML in a file named postgresql.yaml, you can run helm like this:

```
helm -n srm upgrade --create-namespace --install --repo https://charts.bitnami.com/bitnami --version 12.12.10 postgresql postgresql -f postgresql.yaml
```

>Note: The chart notes explain how to obtain the initial password.

### Bitnami Redis Chart Pre-work

The Redis license is available [here](https://redis.io/docs/about/license/). The Bitnami Redis Helm chart license is available [here](https://github.com/bitnami/charts/tree/main/bitnami/redis#license).

Set the Redis architecture to standalone using the redis.architecture Helm chart parameter. You can enable authentication using the redis.auth.enabled chart parameter after setting the auth.existingSecret and auth.existingSecretPasswordKey parameters by referencing a Kubernetes Secret resource with the authentication password. The following is an example of the Redis chart parameters for version 17.3.17 that customizes Redis to meet Scan Farm requirements:

```
architecture: standalone
auth:
  enabled: true
commonConfiguration: |-
  save ""
  appendonly no
  maxmemory 1gb
  maxmemory-policy noeviction
image:
  repository: bitnamilegacy/redis
master:
  persistence:
    enabled: false
  resources:
    limits:
      cpu: 1
      memory: 1100Mi
```

If you store the above YAML in a file named redis.yaml, you can run helm like this:

```
helm -n srm upgrade --create-namespace --install --repo https://charts.bitnami.com/bitnami --version 17.3.17 redis redis -f redis.yaml
```

>Note: The chart notes explain how to obtain the initial password.

Set the redis.tls Helm chart configuration based on whether you plan to enable TLS for your Redis instance. You can find the Redis TLS certificate in its pod at /opt/bitnami/redis/certs/tls.crt.

### Bitnami MinIO Chart Pre-work

The MinIO software is licensed under the [GNU Affero General Public License v3.0](https://github.com/minio/minio/blob/master/LICENSE) or a commercial enterprise license. The Bitnami MinIO Helm chart license is available [here](https://github.com/bitnami/charts/tree/main/bitnami/minio#license).

The following is an example of the MinIO chart parameters for version 17.0.16 that customizes MinIO to meet Scan Farm requirements (refer to the requirements section to identify the storage size suitable for your environment):

```
defaultInitContainers:
  volumePermissions:
    image:
      repository: bitnamilegacy/os-shell
image:
  repository: bitnamilegacy/minio
provisioning:
  enabled: true
  buckets:
  - name:  "storage"
    region: us-east-1
  - name: "cache"
    region: us-east-1
    lifecycle:
    - id: cache
      disabled: false
      expiry:
        days: 8
persistence:
  size: 100Gi
```

If you store the above YAML in a file named minio.yaml, you can run helm like this:

```
helm -n srm upgrade --create-namespace --install --repo https://charts.bitnami.com/bitnami --version 11.10.24 minio minio -f minio.yaml
```

>Note: The chart notes explain how to obtain the initial password.

Set MinIO's root username and password using the minio.auth.rootUser and minio.auth.rootPassword Helm chart parameters. You can define default buckets for the Storage Service and Cache Service using the minio.defaultBuckets chart parameter, or you can create them by hand after installing MinIO.  

You must configure a lifecycle policy on the cache bucket. If you did not configure the policy during deployment, you can use the following command with an "srm" mc alias you can define using the MinIO endpoint and root credential, replacing the cache-bucket name and day count (must be greater than, not equal to, 7) as necessary:

```
$ mc alias set srm <MinIO endpoint> <MinIO root username> <MinIO root password>
$ mc ilm add --expiry-days 8 srm/cache-bucket
```

If your Scan Farm storage runs on the same cluster where you plan to install Software Risk Manager, the Software Risk Manager web component can access your storage using the in-cluster storage URL. This optional optimization works only when both components run on the same cluster.

You can make MinIO available at a URL different from your Software Risk Manager URL. For example, if your Software Risk Manager hostname is srm.local, you can make MinIO available at a different URL like https://minio.local:9000/.

Alternatively, you can proxy MinIO by using the same hostname for both Software Risk Manager and MinIO. For example, if your Software Risk Manager hostname is srm.local, you can make MinIO available at https://srm.local/upload/.

The following two examples show Ingress and Route examples that use hostname `srm.local` to make a `minio` Kubernetes service available at http://srm.local/upload/. Note the use of the rewrite-related annotations in both examples to drop "/upload/" when routing a request to the MinIO service.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 500m
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: minio
  namespace: srm
spec:
  ingressClassName: nginx
  rules:
  - host: srm.local
    http:
      paths:
      - backend:
          service:
            name: minio
            port:
              number: 9000
        path: /upload/(.*)
        pathType: ImplementationSpecific
```

```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
  name: minio
spec:
  host: srm.local
  path: /upload/
  port:
    targetPort: 9000
  tls:
    caCertificate: |-
      ...
    certificate: |-
      ...
    key: |-
      ...
    termination: ...
  to:
    kind: Service
    name: minio
```

Note your external MinIO URL and your in-cluster URL if you plan to specify that optimization in the Helm Prep Wizard.

# Tool Orchestration Pre-work

You can skip this section if you do not plan to use the Tool Orchestration feature or if you plan to use the feature without external workflow storage. Complete the following pre-work before installing the Tool Orchestration feature with external workflow storage.

## Node Pool Pre-work

Tool Orchestration does not require a dedicated node pool, but you can establish one using Kubernetes labels and node taints. You can skip this section if you plan to run Tool Orchestration workloads alongside other Software Risk Manager workloads. The Software Risk Manager Helm chart includes a PodDisruptionBudget to help ensure that tool runs do not block higher-priority workloads.

## Object Storage Pre-work

When you opt for external workflow storage for Tool Orchestration workloads, you will not use the older MinIO version referenced by the Software Risk Manager Helm chart. You are responsible for configuring external object storage that supports the AWS S3 API and for creating a single bucket that you will use to store all Tool Orchestration workflow data.

### AWS

[Amazon S3](https://aws.amazon.com/s3/) is supported for tool orchestration workflow storage when your bucket is accessible using an access and secret key. The bucket must be accessible from the cluster running orchestrated analyses.

You can opt for this storage type by selecting `External (Access Key)` from the Orchestrated Analysis Storage screen of the Helm Prep Wizard.

>Note: Using [AWS IRSA](#aws-irsa) is preferred to using `External (Access Key)`.

The following AWS permissions are required for the AWS sevice account:

- s3:GetObject
- s3:DeleteObject
- s3:PutObject
- s3:ListBucket

You can follow the below example, which includes bash commands that shows one way to configure bucket access.

1. Define variables used for this example

```
account_id=$(aws sts get-caller-identity --query "Account" --output text)
username='username'
bucket='srm-bucket'
```

2. Create a policy

```
cat > srm-tool-orchestration-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$bucket",
                "arn:aws:s3:::$bucket/*"
            ]
        }
    ]
}
EOF

aws iam create-policy --policy-name srm-tool-orchestration-policy --policy-document file://srm-tool-orchestration-policy.json
```

3. Attach policy to account

```
aws iam attach-user-policy --user-name=$username --policy-arn=arn:aws:iam::$account_id:policy/srm-tool-orchestration-policy
```

If you want to uninstall what you created above, run the following commands:

```
account_id=$(aws sts get-caller-identity --query "Account" --output text)
username='username'

policy_arn="arn:aws:iam::$account_id:policy/srm-tool-orchestration-policy"

aws iam detach-user-policy --user-name=$username --policy-arn=$policy_arn
aws iam delete-policy      --policy-arn $policy_arn
```

### AWS IRSA

[AWS IAM Roles for Service Account (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) is supported for tool orchestration workflow storage when your bucket is accessible from the AWS cluster running orchestrated analyses.

You can opt for this storage type by selecting `External (AWS IAM)` from the Orchestrated Analysis Storage screen of the Helm Prep Wizard.

You must provision Kubernetes ServiceAccount resources for both the SRM Tool Service and tool workflows and link them to the IAM permissions below. The Helm Prep Wizard will prompt for the account names.

The following AWS permissions are required for the tool service:

- s3:GetObject
- s3:DeleteObject
- s3:PutObject
- s3:ListBucket

The following AWS permissions are required for the workflow service:

- s3:GetObject
- s3:PutObject
- s3:ListBucket

After you have an [IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html), you can follow the below example, which includes bash commands that show one way to configure AWS IRSA for two service accounts named `toolsvc-sa` and `workflow-sa`.

1. Define variables used for this example

```
account_id=$(aws sts get-caller-identity --query "Account" --output text)
awsRegion='us-east-2'

clusterName='srm'
oidc_provider=$(aws eks describe-cluster --name $clusterName --region $awsRegion --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

namespace='srm'
tool_svc_service_account='toolsvc-sa'
workflow_service_account='workflow-sa'

bucket='srm-bucket'
```

2. Create Tool Service policy

```
cat > tool-service-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$bucket",
                "arn:aws:s3:::$bucket/*"
            ]
        }
    ]
}
EOF

aws iam create-policy --policy-name srm-tool-service-bucket-policy --policy-document file://tool-service-policy.json
```

3. Create Workflow policy

```
cat > workflow-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$bucket",
                "arn:aws:s3:::$bucket/*"
            ]
        }
    ]
}
EOF

aws iam create-policy --policy-name srm-workflow-bucket-policy --policy-document file://workflow-policy.json
```

4. Create Tool Service role

```
cat > tool-service-role.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$tool_svc_service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name srm-tool-service-bucket-role --assume-role-policy-document file://tool-service-role.json --description "srm-tool-service-bucket-role"
```

5. Create Workflow role

```
cat > workflow-role.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$workflow_service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name srm-workflow-bucket-role --assume-role-policy-document file://workflow-role.json --description "srm-workflow-bucket-role"
```

6. Attach policies to roles

```
aws iam attach-role-policy --role-name srm-tool-service-bucket-role --policy-arn=arn:aws:iam::$account_id:policy/srm-tool-service-bucket-policy

aws iam attach-role-policy --role-name srm-workflow-bucket-role --policy-arn=arn:aws:iam::$account_id:policy/srm-workflow-bucket-policy
```

7. Create Service Accounts

```
kubectl create namespace $namespace

kubectl -n $namespace create serviceaccount $tool_svc_service_account
kubectl -n $namespace create serviceaccount $workflow_service_account

kubectl -n $namespace annotate serviceaccount $tool_svc_service_account eks.amazonaws.com/role-arn=arn:aws:iam::$account_id:role/srm-tool-service-bucket-role
kubectl -n $namespace annotate serviceaccount $workflow_service_account eks.amazonaws.com/role-arn=arn:aws:iam::$account_id:role/srm-workflow-bucket-role
```

If you want to uninstall what you created above, run the following commands:

```
account_id=$(aws sts get-caller-identity --query "Account" --output text)

tool_service_policy_arn="arn:aws:iam::$account_id:policy/srm-tool-service-bucket-policy"
workflow_policy_arn="arn:aws:iam::$account_id:policy/srm-workflow-bucket-policy"

aws iam detach-role-policy --role-name=srm-tool-service-bucket-role --policy-arn=$tool_service_policy_arn
aws iam delete-role        --role-name=srm-tool-service-bucket-role
aws iam delete-policy      --policy-arn $tool_service_policy_arn

aws iam detach-role-policy --role-name=srm-workflow-bucket-role --policy-arn=$workflow_policy_arn
aws iam delete-role        --role-name=srm-workflow-bucket-role
aws iam delete-policy      --policy-arn $workflow_policy_arn

kubectl annotate serviceaccount -n $namespace $tool_svc_service_account eks.amazonaws.com/role-arn-
kubectl annotate serviceaccount -n $namespace $workflow_service_account eks.amazonaws.com/role-arn-

kubectl -n $namespace delete serviceaccount $tool_svc_service_account $workflow_service_account
```

### GCP

[Cloud Storage](https://cloud.google.com/storage/docs/introduction) is supported for tool orchestration workflow storage when your bucket is accessible using an [HMAC key](https://cloud.google.com/storage/docs/authentication/hmackeys) with an Access ID and Secret. The bucket must be accessible from the cluster running orchestrated analyses.

You can opt for this storage type by selecting `External (Access Key)` from the Orchestrated Analysis Storage screen of the Helm Prep Wizard.

### MinIO

[MinIO](https://min.io/) is supported for tool orchestration workflow storage when your bucket is accessible using an access and secret key. The bucket must be accessible from the cluster running orchestrated analyses.

You can opt for this storage type by selecting `External (Access Key)` from the Orchestrated Analysis Storage screen of the Helm Prep Wizard.

# Password Pre-work

How many passwords you must set will depend on how you deploy Software Risk Manager. The Helm chart will auto-generate unspecified passwords where support is available.

| Password/Key | Feature | Auto-generate Support |
|:-|:-:|:-:|
| Software Risk Manager Web Admin Password | Core | Y |
| Web Database User Password | Core | Y |
| | | |
| Web Database Root Password | Core (On-Cluster DB) | Y |
| Web Database Replication Password | Core (On-Cluster DB) | Y |
| | | |
| Private Docker Registry Password | Core (Private Registry) | Y |
| | | |
| SAML Java Keystore Password | Core (SAML Authentication) | Y |
| SAML Java Private Key Password | Core (SAML Authentication) | Y |
| | | |
| Black Duck Password | Scan Farm | N |
| | | |
| Scan Farm PostgreSQL Password | Scan Farm | N |
| | | |
| Scan Farm Redis Auth Password | Scan Farm | N |
| | | |
| Scan Farm S3 Password | Scan Farm (AWS) | N |
| Scan Farm MinIO Root Password | Scan Farm (MinIO) | N |
| Scan Farm Azure Storage Access Key | Scan Farm (Azure) | N |
| Scan Farm Azure Storage Application Client Secret | Scan Farm (Azure) | N |
| | | |
| Tool Orchestration Tool Service Key | Tool Orchestration | Y |
| Tool Orchestration MinIO Admin Password | Tool Orchestration | Y |
| Tool Orchestration External Workflow Storage Password | Tool Orchestration | Y |

# Network Policies

The Software Risk Manager deployment supports network policies for non-Scan Farm components.

# TLS Pre-work

The Software Risk Manager deployment includes optional support for TLS connections between components using Istio, or between non-Scan Farm components using cert-manager. You can use cert-manager's [support for Kubernetes Certificate Signing Requests (CSR)](https://cert-manager.io/docs/usage/kube-csr) or [Certificate resources](https://cert-manager.io/docs/usage/certificate).

>Note: Using Istio Ambient Mode is the recommended approach for establishing TLS connections between SRM components.

## Istio Ambient Mode

You can use [Istio Service Mesh Ambient Mode](https://istio.io/latest/docs/ambient/) to enable mTLS between Software Risk Manager components. Do not enable Software Risk Manager network policies when using Istio Ambient because the current policies do not include the [required network policy configuration for Istio Ambient](https://istio.io/latest/docs/ambient/usage/networkpolicy/).

Use helm to deploy Istio by following the [Istio Ambient installation instructions](https://istio.io/latest/docs/ambient/install/helm-installation/).

When you run the Helm Prep Wizard, select Istio Ambient on the Configure TLS screen. The Helm Prep Script will generate a command similar to the following that will add the `istio.io/dataplane-mode=ambient` namespace label to your SRM namespace.

```
kubectl label namespace srm istio.io/dataplane-mode=ambient
```

>Note: The examples in this section use the default `srm` namespace.

By default, Istio uses [PERMISSIVE](https://istio.io/latest/docs/concepts/security/#peer-authentication) as the default mTLS mode. You can switch to [STRICT](https://istio.io/latest/docs/concepts/security/#peer-authentication) mode with the following PeerAuthentication resource:

```
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: srm
spec:
  mtls:
    mode: STRICT
```

If you enable STRICT mode for the SRM namespace and you are using an ingress controller, you must either add the ingress controller to the mesh (preferred) or enable PERMISSIVE mode for your SRM services.

### Istio - Mesh Visualization

You can install [Prometheus](https://istio.io/latest/docs/ops/integrations/prometheus/) and [Kiali](https://istio.io/latest/docs/ops/integrations/kiali/) to [Visualize Your Mesh](https://istio.io/latest/docs/tasks/observability/kiali/#generating-a-graph).

Once installed, open the Kiali dashboard and select Traffic Graph. Enable the Security badge under Display, use Software Risk Manager, and return to the traffic graph to confirm the expected mTLS connections.

## Cert-Manager Certificates

The Helm Prep Wizard and Script (see [Full Installation](#installation---full)) includes support for certificates issued with [cert-manager](https://cert-manager.io/) for Software Risk Manager Core and Tool Orchestration components. There is no support for issuing certificates via CSRs for Scan Farm feature components.

Before running the Helm Prep Wizard, you must follow the [cert-manager installation instructions](https://cert-manager.io/docs/installation/) and define either an Issuer or ClusterIssuer [resource](https://cert-manager.io/docs/concepts/issuer/). The wizard will also prompt you for the public key of your certificate authority.

### Cert-Manager Certificates Example

This example configuration uses cert-manager and creates a cluster-scoped ClusterIssuer with a self-signed CA.

1. Install cert-manager v1.17.0

```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
```

2. Create a signing key and certificate with the common name Private CA:

```
$ openssl genrsa -out ca.key 2048
$ openssl req -x509 -new -key ca.key -subj "/CN=Private CA" -days 3650 -out ca.crt
```

3. Create a Kubernetes Secret named ca-key-pair in the cert-manager namespace:

```
$ kubectl -n cert-manager create secret tls ca-key-pair --cert=ca.crt --key=ca.key
```

4. Create a new file named clusterissuer.yaml with the following contents:

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair
```

5. Run the following command to create the ca-issuer ClusterIssuer:

```
kubectl apply -f ./clusterissuer.yaml
```

6. Wait for the following command to show a Ready status:

```
kubectl get clusterissuer ca-issuer -o wide
```

When you run the Helm Prep Wizard, select `Cert-Manager Certificates` on the Configure TLS screen, enter the path to your ca.crt file, specify your cluster issuer name as `ca-issuer`, and select `ClusterIssuer` as your cluster issuer type.

## Kubernetes CertificateSigningRequests

The Helm Prep Wizard and Script includes support for certificates issued via [Certificate Signing Requests](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/) for Software Risk Manager Core and Tool Orchestration components. There is no support for issuing certificates via CSRs for Scan Farm feature components.

Before running the Helm Prep Wizard, you must install and configure a certificate signer whose name you will provide after selecting `K8s CSR` on the Configure TLS screen of the wizard. The wizard will also prompt you for the public key of your certificate authority.

Refer to the following section for an example that uses cert-manager's kube-csr component.



You can use the cert-manager support for Kubernetes CSRs, which is in an experimental state, to issue certificates for Software Risk Manager Core and Tool Orchestration components. .

Follow the cert-manager kube-csr [installation instructions]() and then define either an Issuer or ClusterIssuer [resource](https://cert-manager.io/docs/configuration/)
### Kubernetes CertificateSigningRequests Example

This example [installs cert-manager's kube-csr](https://cert-manager.io/docs/usage/kube-csr/) component, with the experimental ExperimentalCertificateSigningRequestControllers feature gate enabled, to process CertificateSigningRequests with a cluster-scoped ClusterIssuer and a self-signed CA.

1. Install cert-manager v1.17.0:

```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.crds.yaml
$ helm repo add jetstack https://charts.jetstack.io --force-update
$ helm repo update
$ helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.17.0 --set featureGates="ExperimentalCertificateSigningRequestControllers=true"
```

2. Create a signing key and certificate with the common name Private CA:

```
$ openssl genrsa -out ca.key 2048
$ openssl req -x509 -new -key ca.key -subj "/CN=Private CA" -days 3650 -out ca.crt
```

3. Create a Kubernetes Secret named ca-key-pair in the cert-manager namespace:

```
$ kubectl -n cert-manager create secret tls ca-key-pair --cert=ca.crt --key=ca.key
```

4. Create a new file named clusterissuer.yaml with the following contents:

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair
```

5. Run the following command to create the ca-issuer ClusterIssuer:

```
kubectl apply -f ./clusterissuer.yaml
```

6. Wait for the following command to show a Ready status:

```
kubectl get clusterissuer ca-issuer -o wide
```

When you run the Helm Prep Wizard, select `K8s CSR` on the Configure TLS screen, enter the path to your ca.crt file, and specify `clusterissuers.cert-manager.io/ca-issuer` for your CSR signer name.

# Licensing

You will receive a license zip file with four files if you purchased Software Risk Manager with the Scan Farm feature, including SAST and SCA.

| File | Purpose |
|:-|:-|
| 00000000-SRM-CDX.txt | Software Risk Manager Web license |
| 00000000-SRM-SAVE.dat | Software Risk Manager Scan Farm SAST license |
| 00000000-SRM-SCA.json | Software Risk Manager Scan Farm SCA license |
| 00000000-SRM-CodeSight.json | Software Risk Manager Code Sight license |

The Quick Start installation method described in the next section does not accept a license file, so you will enter your 00000000-SRM-CDX.txt file in the Software Risk Manager UI when prompted. The full installation process will prompt for a Web license file and the SAST and SCA licenses if you plan to use those Scan Farm features.

# Installation - Quick Start

You can follow the Quick Start instructions if you want to deploy Software Risk Manager using default settings and either the Core or Tool Orchestration features. If you want to customize your deployment or use the Scan Farm feature, you cannot use the Quick Start deployment method.

The Software Risk Manager Helm chart creates multiple Kubernetes Secret resources. Refer to [Good practices for Kubernetes Secrets](https://kubernetes.io/docs/concepts/security/secrets-good-practices/) for configuration recommendations and for how to [configure encryption at rest](https://kubernetes.io/docs/concepts/security/secrets-good-practices/#configure-encryption-at-rest).

## Core Quick Start

Run the following commands to install Software Risk Manager Core using the default configuration:

```
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://codedx.github.io/srm-k8s srm srm # --set openshift.createSCC=true
```

>Note: If you are using OpenShift, remove `#` when running the last command.

## Tool Orchestration Quick Start

Run the following commands to install Software Risk Manager with Tool Orchestration using the default configuration:

```
$ git clone https://github.com/codedx/srm-k8s
$ kubectl apply -f srm-k8s/crds/v1
$ helm -n srm upgrade --reset-values --install --create-namespace --repo https://codedx.github.io/srm-k8s -f srm-k8s/chart/values/values-to.yaml srm srm # --set openshift.createSCC=true
```

>Note 1: If you are installing in a namespace other than srm, you must specify that namespace by replacing "srm" in the following helm --set command: `argo-workflows.controller.workflowNamespaces={srm}`.

>Note 2: If you are using OpenShift, remove `#` when running the last command.

## Fetch Initial Admin Password

You can retrieve the initial Software Risk Manager admin password using a command in the helm release notes, which appear when a helm install/upgrade concludes. You can view the helm release notes at any time by running this command, replacing the namespace and helm release name as necessary:

```
helm -n srm get notes srm
```

# Installation - Full

The full installation method supports all Software Risk Manager features and customizations. This GitHub repository contains tools to help simplify deploying Software Risk Manager on your cluster.

Your first Software Risk Manager Kubernetes deployment is a four-step process:

- Clone this GitHub Repository
- Run Helm Prep Wizard (once)
- Run Helm Prep Script
- Invoke helm/kubectl Commands

>Note: Software Risk Manager upgrades require three steps; you will not rerun the Help Prep Wizard when upgrading Software Risk Manager.

The Software Risk Manager Helm chart creates multiple Kubernetes Secret resources. Refer to [Good practices for Kubernetes Secrets](https://kubernetes.io/docs/concepts/security/secrets-good-practices/) for configuration recommendations and for how to [configure encryption at rest](https://kubernetes.io/docs/concepts/security/secrets-good-practices/#configure-encryption-at-rest).

## Prerequisites

The deployment scripts in the [srm-k8s GitHub repository](https://github.com/codedx/srm-k8s) require [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/overview), which runs on macOS, Linux, and Windows. 

>Note: PowerShell Core differs from Windows PowerShell, which is available on Windows only.

See the following sections for operating system-specific prerequisites. 

### Linux Prerequisites

Use the following links to install the prerequisite software on your Linux system.

- [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)
- [Java JRE](https://adoptium.net/temurin/releases/?package=jre&version=11) (specifically, keytool in your PATH)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (version should match your cluster's Kubernetes version)

The scripts in the repository depend on the `keytool` program, bundled with the Java JRE, and the `kubectl` program, both of which must be included in your PATH.

>Note: You do not need to be connected to your cluster to run the Helm Prep Wizard or Helm Prep Script because both use client-side kubectl capabilities. If your kubectl context is not empty, it should be a valid configuration.

### macOS Prerequisites

Use the following links to install the prerequisite software on your macOS system.

- [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos)
- [Java JRE](https://adoptium.net/temurin/releases/?package=jre&version=11) (specifically, keytool in your PATH)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/) (version should match your cluster's Kubernetes version)

The scripts in the repository depend on the `keytool` program, bundled with the Java JRE, and the `kubectl` program, both of which must be included in your PATH.

>Note: You do not need to be connected to your cluster to run the Helm Prep Wizard or Helm Prep Script because both use client-side kubectl capabilities. If your kubectl context is not empty, it should be a valid configuration.

### Windows Prerequisites

Use the following links to install the prerequisite software on your Windows system.

- [PowerShell Core](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows) (not [Windows PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell))
- [Java JRE](https://adoptium.net/temurin/releases/?package=jre&version=11) (specifically, keytool in your PATH)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) (version should match your cluster's Kubernetes version)

The scripts in the repository depend on the `keytool` program, bundled with the Java JRE, and the `kubectl` program, both of which must be included in your PATH.

>Note: You do not need to be connected to your cluster to run the Helm Prep Wizard or Helm Prep Script because both use client-side kubectl capabilities. If your kubectl context is not empty, it should be a valid configuration.

Ensure you can run PowerShell Core scripts on Windows by switching your PowerShell Execution Policy to RemoteSigned (recommended) or Unrestricted. To do so, you must run the Set-ExecutionPolicy -ExecutionPolicy RemoteSigned command from an elevated/administrator Command Prompt:

```
1. Locate Command Prompt in your Start menu
2. Click "Run as administrator"
3. C:\> pwsh
4. PS C:\> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

### PowerShell Module

The Helm Prep Wizard has a dependency on a Black Duck PowerShell module published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/guided-setup) and [NuGet Repository](https://www.nuget.org/packages/guided-setup). The wizard will automatically download and install the module when it starts. If you would prefer to download and install the module by hand, refer to the [manual installation note](../.install-guided-setup-module.ps1#L12) in the module installation script.

## Clone GitHub Repository

The [srm-k8s GitHub repository](https://github.com/codedx/srm-k8s) repository contains what you need to start your Software Risk Manager Kubernetes deployment. Clone the repository to a stable directory on your system. You will use your cloned repository for both your initial deployment and for deploying future Software Risk Manager software upgrades.

```
$ git clone https://github.com/codedx/srm-k8s
```

## Helm Prep Wizard

You can think of the Helm Prep Wizard as an interactive installation document that gets you ready to deploy Software Risk Manager using Helm. It is a [PowerShell Core 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) script you can run on macOS, Linux, or Windows to select Software Risk Manager deployment features and gather required deployment parameters. The Helm Prep Wizard depends on the "guided-setup" PowerShell module, which gets downloaded automatically from the PowerShell Gallery. Alternatively, you can download the module from NuGet. If you prefer to download/install manually, refer to the instructions in the installation script.

The Helm Prep Wizard displays a series of questions to help you select Software Risk Manager features and specify related deployment parameters. If you need to return to a previous screen to correct an error or revisit a question, enter 'B' to choose the "Back to Previous Step" option. If you are responding to a prompt that is not multiple choice, press Enter to reveal the "Back to Previous Step" choice.

You typically run the Helm Prep Wizard once at the outset of your initial deployment. Start the wizard after [cloning](#clone-github-repository) this GitHub repository by running the helm-prep-wizard.ps1 script from the srm-k8s directory.

```
$ cd /path/to/srm-k8s
$ pwsh ./helm-prep-wizard.ps1
```

![Helm Prep Wizard](images/helm-prep-wizard.png "Helm Prep Wizard")

## Helm Prep Script

The Helm Prep Wizard concludes by creating a run-helm-prep.ps1 script that calls the Software Risk Manager Helm Prep Script with your deployment parameters to generate Helm command and values files with dependent Kubernetes YAML resource files suitable for your Software Risk Manager deployment.

Your deployment parameters end up in a file named config.json stored in the working directory you specified in the wizard.

### Configuration File Protection

The wizard prompts for a password when necessary to encrypt specific config.json files such as passwords and keys.

If you ever want to edit protected fields in config.json, first run the unlock-config.ps1 script to replace specific config.json encrypted field values with unencrypted values, leaving your config.json file unlocked.

```
$ pwsh /path/to/git/admin/config/unlock-config.ps1 -configPath /path/to/config.json
Enter config file password:
```

Run the lock-config.ps1 script to re-encrypt config.json field values, locking your config.json file.

```
$ pwsh /path/to/git/admin/config/lock-config.ps1 -configPath /path/to/config.json
Enter config file password:
```

### Invoking the Helm Prep Script

The Software Risk Manager Helm Prep Script outputs the kubectl/helm commands and installation notes to invoke your initial deployment. The contents of the run-helm-prep.ps1 script reference the Helm Prep Script and your config.json file.

The Helm Prep Script will prompt for the password you entered because it must unlock config.json before processing its contents. You can skip the prompt by either using script's -configFilePwd parameter or by setting the HELM_PREP_CONFIGFILEPWD environment variable.

```
$ cd /path/to/srm-k8s-work-dir # selected during Helm Prep Wizard
$ pwsh ./run-helm-prep.ps1
```

## Invoke helm/kubectl Commands

Your deployment occurs when you run the commands the Helm Prep Script generates. The output of the Helm Prep Script will look similar to the following. 

```
----------------------
K8s Installation Notes
----------------------
- Your deployment includes the scan farm feature. Remember to complete the following tasks:
  * Configure external dependencies (PostgreSQL, Redis, Object Storage)
  * Define your "small" scan job node pool:
  *   Assign a pool-type label (pool-type=small) to analysis node(s).
  *   Assign a scanner node taint (NodeType=ScannerNode:NoSchedule) to analysis node(s).
  *   NOTE: A "small" pool-type requires one or more nodes with 6.5 vCPUs and 26 GB of memory
- Follow instructions at https://github.com/codedx/srm-k8s/blob/main/docs/deploy/registry.md to pull/push Black Duck Docker images to your private registry.


----------------------
Required K8s Namespace
----------------------
kubectl create namespace srm

----------------------
Required K8s Resources
----------------------
kubectl apply -f "/path/to/.k8s-srm/chart-resources"

----------------------
Required Helm Commands
----------------------
helm dependency update /path/to/git/srm-k8s/chart
helm -n srm upgrade --reset-values --install srm -f "/path/to/.k8s-srm/chart-values-combined/values-combined.yaml" --timeout 30m0s /path/to/git/srm-k8s/chart

INFO: If you use an srm-extra-props.yaml file, include '-f /path/to/srm-extra-props.yaml' as your helm command's last values file parameter.
```

- The optional `K8s Installation Notes` section will include steps you should take before creating K8s resources and running helm.
- The `Required K8s Namespace` contains the kubectl command to create your SRM namespace. If the namespace already exists, you can ignore that section.
- Running the kubectl command in the `Required K8s Resources` section will generate any K8s resources upon which your helm chart configuration depends.
- The `Required Helm Commands` section includes the helm commands you must run to deploy (or upgrade) SRM.

See the next section if you want to deploy Software Risk Manager using GitOps, specifically the Flux software. Otherwise, run the commands generated by the Helm Prep Script to deploy Software Risk Manager in your desired configuration.

>Note: If you decide to [customize your Software Risk Manager deployment](#customizing-software-risk-manager), remember to append the `-f /path/to/srm-extra-props.yaml` parameter to the helm upgrade command generated by the Helm Prep Script. If your srm-extra-props.yaml file is found alongside your config.json file, the `-f /path/to/srm-extra-props.yaml` parameter will be included automatically.

### Fetch Initial Admin Password

You can retrieve the initial Software Risk Manager admin password using a command in the helm release notes, which appear when a helm install/upgrade concludes. You can view the helm release notes at any time by running this command, replacing the namespace and helm release name as necessary:

```
helm -n srm get notes srm
```

# Deploying with GitOps (Flux)

After running the Helm Prep Wizard and Helm Prep scripts, you can optionally deploy Software Risk Manager using Flux, which is one way to implement GitOps. The Software Risk Manager deployment includes support for generating Flux-related resources. You can use an alternative GitOps solution, like [Argo CD](https://argo-cd.readthedocs.io/en/stable/), by hand-creating the related GitOps resources.

This section describes how to configure a fictitious GitHub repository named "srm-gitops" for use with [Flux](https://fluxcd.io/flux/) and [Bitnami's Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). The configuration in the git repository will manage a Kubernetes cluster referred to as the "demo" cluster where a Software Risk Manager deployment can be managed using GitOps.

Instructions that follow refer to a fictitious GitHub repository at https://github.com/codedx/srm-gitops and a made-up "srm" kubectl context. To follow along with the instructions, replace the following content:

- replace the demo directory references with a directory name that represents your cluster
- replace the srm-gitops GitHub repository references with the location of your GitHub repository
- replace the srm kubectl context references with the context name associated with your cluster

## One-Time Setup Steps

For the most up-to-date instructions, refer to the [Flux bootstrap instructions](https://fluxcd.io/flux/installation/bootstrap/). Here are the one-time Flux v2.1 steps that will bootstrap the GitHub demo cluster:

### Flux Steps:

1) Switch to the srm context:

    ```
    kubectl config use-context srm
    ```

2) Provision a GitHub PAT for a user with all GitHub 'repo' permissions. Establish a GITHUB_TOKEN environment variable:

    ```
    export GITHUB_TOKEN=<PAT>
    ```

3) Download the flux CLI tool (v2.1) and verify prerequisites:

    ```
    flux check --pre
    ```

4) Download the repo:

    ```
    git clone https://github.com/codedx/srm-gitops
    ```

5) Bootstrap flux components on cluster (--token-auth bootstraps Flux for HTTPS repo access):

    ```
    cd ~/git/srm-gitops
    flux bootstrap github --token-auth --owner=sysnopsys-sig --repository=srm-gitops --branch=main --path=./demo
    ```

6) Pull latest for srm-deployment:

    ```
    cd ~/git/srm-gitops
    git pull --rebase
    ```

### Bitnami Sealed Secrets Steps:

1) Create directories for the sealed-secrets release:

    ```
    cd ~/git/srm-gitops
    mkdir -p ./demo/Releases/SealedSecrets/HelmRepository
    mkdir -p ./demo/Releases/SealedSecrets/HelmRelease
    ```

2) Generate the sealed-secrets HelmRepository resource file:

    ```
    cd ~/git/srm-gitops
    flux create source helm sealed-secrets --interval=1h --url=https://bitnami-labs.github.io/sealed-secrets --export > ./demo/Releases/SealedSecrets/HelmRepository/repo.yaml
    ```

3) Generate the sealed-secrets HelmRelease resource:

    ```
    cd ~/git/srm-gitops
    flux create helmrelease sealed-secrets --interval=1h --release-name=sealed-secrets-controller --target-namespace=flux-system --source=HelmRepository/sealed-secrets --chart=sealed-secrets --chart-version=">=1.15.0-0" --crds=CreateReplace --export > ./demo/Releases/SealedSecrets/HelmRelease/release.yaml
    ```

4) Commit files to deploy SealedSecrets:

    ```
    cd ~/git/srm-gitops
    git add ./demo/Releases/SealedSecrets
    git commit
    git push
    ```

5) Download Bitnami's [kubeseal](https://github.com/bitnami-labs/sealed-secrets/releases) and fetch public key:

    ```
    cd ~/git/srm-gitops
    kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=flux-system > ./demo/sealed-secrets.pem
    ```

6) Commit the public key:

    ```
    cd ~/git/srm-gitops
    git add ./demo/sealed-secrets.pem
    git commit
    git push
    ```

## Software Risk Manager Deployment

With Flux and Bitnami's SealedSecrets deployed, after running the Helm Prep Wizard and Helm Prep script, run the new-flux.ps1 script in the /path/to/git/srm-k8s/admin/gitops directory, specifying the following script parameters:

```
param (
	[string]   $workDir = "$HOME/.k8s-srm",
	[Parameter(Mandatory=$true)][string] $namespace,
	[Parameter(Mandatory=$true)][string] $releaseName,
	[string]   $helmChartRepoUrl = 'https://codedx.github.io/srm-k8s',
	[string[]] $extraValuesFiles = @(),
	[switch]   $useSealedSecrets,
	[string]   $sealedSecretsNamespace = 'flux-system',
	[string]   $sealedSecretsControllerName = 'sealed-secrets-controller',
	[string]   $sealedSecretsPublicKeyPath
)
```

Use the `-extraValuesFiles` script parameter to include any extra SRM values files you use. Specify `-useSealedSecrets` to use the installed Sealed Secrets software and reference your Sealed Secrets public key file with the `-sealedSecretsPublicKeyPath` parameter. If you decide not to use Sealed Secrets, use an alternative solution to avoid storing Kubernetes secret resources in your git repository.

The new-flux.ps1 script will generate a flux-v2 directory under your work directory (`-workDir` parameter). The contents of flux-v2 will typically look like this:

```
├───ConfigMap
├───CRD
├───HelmRelease
├───HelmRepository
├───Namespace
└───SealedSecret
```

The flux-v2 directory contains the Kubernetes resources you can commit to your git repository to deploy Software Risk Manager with Flux. You can commit namespace-scoped resources to a Releases/SRM folder and cluster-scoped resources, like CRDs, under the demo folder representing your cluster:

```
├───demo
│   └───CRD
│   └───Releases
│       ├───SRM
│       │   ├───ConfigMap
│       │   ├───HelmRelease
│       │   ├───HelmRepository
│       │   ├───Namespace
│       │   └───SealedSecret
│       └───SealedSecrets
│           ├───HelmRelease
│           └───HelmRepository
```

Consider adding your *locked* config.json file and any files it references to your GitOps repository. Making your config.json file available to others will let them re-generate your work directory files and rerun new-flux.ps1 if and when that's required.

Be sure to run kubeseal by hand before adding extra Kubernetes secret resources referenced indirectly by config.json. You should drop the ".yaml" file extension from extra Helm values files to prevent Flux from trying to generate a related Kubernetes resource.

You can replace absolute paths in config.json by using paths relative to config.json's directory or `~` to reference paths relative to a home directory. For example, you can switch your work directory config.json parameter from `/Users/me/.k8s-srm` to `~/.k8s-srm`.

Below is an example showing config.json and srm-extra-props, renamed from srm-extra-props.yaml, in a HelmPrep folder under Releases/SRM. Also included is an srm-proxy-private-props.yaml SealedSecret resource created using kubeseal from the srm-proxy-private-props Kubernetes secret resource referenced by srm-extra-props.yaml:

```
├───demo
│   └───CRD
│   └───Releases
│       ├───SRM
│       │   ├───ConfigMap
│       │   ├───HelmPrep
│       │   ├───HelmPrep
│       │   |   ├─── config.json
│       │   |   ├─── srm-extra-props
│       │   |   ├─── srm-proxy-private-props.yaml
│       │   ├───HelmRelease
│       │   ├───HelmRepository
│       │   ├───Namespace
│       │   └───SealedSecret
│       └───SealedSecrets
│           ├───HelmRelease
│           └───HelmRepository
```

# Customizing Software Risk Manager

You can use a Helm values file to customize your Software Risk Manager deployment. Add custom helm property values to a file named `srm-extra-props.yaml`, and store this file alongside your config.json file when using the Helm Prep Script. You should include any custom chart settings and any web component property values you would specify in a [Software Risk Manager "props" file like codedx.props](https://documentation.blackduck.com/bundle/srm/page/install_guide/SRMConfiguration/config-files.html).

If you store your `srm-extra-props.yaml` file alongside your config.json file generated by the Helm Prep Wizard, when you run your `run-helm-prep.ps1` script, the Helm Prep Script will automatically include `-f /path/to/srm-extra-props.yaml` in the `helm upgrade` command it generates.

```
$ pwsh /path/to/run-helm-prep.ps1
  ...
  ...
  helm -n srm upgrade --reset-values --install srm ... -f /path/to/srm-extra-props.yaml
```

If you store the file elsewhere or you deployed using a Quick Start, include `-f /path/to/srm-extra-props.yaml` as the last parameter when you run `helm upgrade`:

```
helm -n srm upgrade --reset-values --install srm ... -f /path/to/srm-extra-props.yaml
```

>Note: Append `-f /path/to/srm-extra-props.yaml` to the end of your helm command to ensure your changes override other values files in the helm command.

## Specify Web Properties (codedx.props)

You can change the behavior of Software Risk Manager's web component by adding configuration properties to your `srm-extra-props.yaml` file. The Software Risk Manager Helm chart will add your properties to the Kubernetes equivalent of a `codedx.props` file.

There are two types of `codedx.props` property values you may want to configure. Private property values are those that should be protected, such as passwords, and they get stored in a Kubernetes Secret. Public property values are stored and loaded from a Kubernetes ConfigMap.

To explain the configuration of public and private properties, the following example shows how to configure a [proxy server](https://documentation.blackduck.com/bundle/srm/page/install_guide/SRMConfiguration/proxy.html) for Software Risk Manager. When you are finished configuring the public and private proxy configuration, rerun `helm upgrade` as described in the previous section.

### Public Web Properties Proxy Example

The steps in this section show you how to configure public property values by specifying values for proxy.host and proxy.port.

1. Create a file named `srm-extra-props.yaml` and add the proxy.host, proxy.port, and proxy.nonProxyHosts property values as a new section with key srm-public-props (use spaces for the indents, tab characters will cause a failure at install-time):

```
web:
  props:
    extra:
    - key:  srm-public-props
      type: values
      values:
      - "proxy.host = squid-restricted-http-proxy.squid"
      - "proxy.port = 3128"
      - "proxy.nonProxyHosts = srm-to.srm.svc.cluster.local|srm-web|localhost|*.internal.codedx.com"
```

>Note: Add non-proxy hosts as needed, separating each one with a pipe character. Software Risk Manager deployments using Tool Orchestration must include the fully qualified name of the Software Risk Manager tool service (srm-to.srm.svc.cluster.local in the above example). Software Risk Manager deployments using the Triage Assistant must include the Software Risk Manager web service name (srm-web in the above example).

2. The proxy accepts requests at port 3128. If you configured network policy, you must update your egress TCP port list using the networkPolicy property shown here:

```
web:
  props:
    extra:
    - key:  srm-public-props
      type: values
      values:
      - "proxy.host = squid-restricted-http-proxy.squid"
      - "proxy.port = 3128"
      - "proxy.nonProxyHosts = srm-to.srm.svc.cluster.local|srm-web|localhost|*.internal.codedx.com"
networkPolicy:
  web:
    egress:
      extraPorts:
        tcp: [22, 53, 80, 389, 443, 636, 7990, 7999, 8443, 3128]
```

>Note: Your egress extraPorts list may differ depending on installed features, so append 3128 as appropriate.

### Private Web Properties Proxy Example

The steps in this section show you how to configure private property values by specifying the proxy.username and proxy.password values.

1. Create a file named `srm-proxy-private-props` (no file extension) and add the proxy.username and proxy.password properties:

```
proxy.username = codedx
proxy.password = password
```

2. If necessary, pre-create the Kubernetes Software Risk Manager namespace.

```
kubectl create ns srm
```

3. Generate a Kubernetes Secret named `srm-proxy-private-props` in the Software Risk Manager namespace. For example, if your Software Risk Manager namespace is srm, run the following command from the directory containing srm-proxy-creds-props:

```
kubectl -n srm create secret generic srm-proxy-private-props --from-file=srm-proxy-private-props
```

4. Edit your `srm-extra-props.yaml` file you created in the previous section and add a reference to the srm-proxy-private-props Kubernetes Secret you just created by appending an entry named srm-proxy-private-props to the extra array (last three lines shown below under web.props.extra):

```
web:
  props:
    extra:
    - key:  srm-public-props
      type: values
      values:
      - "proxy.host = squid-restricted-http-proxy.squid"
      - "proxy.port = 3128"
      - "proxy.nonProxyHosts = srm-to.srm.svc.cluster.local|srm-web|localhost|*.internal.codedx.com"
    - key: srm-proxy-private-props
      type: secret
      name: srm-proxy-private-props
networkPolicy:
  web:
    egress:
      extraPorts:
        tcp: [22, 53, 80, 389, 443, 636, 7990, 7999, 8443, 3128]
```

## Specify Database Connection Timeout

You can alter the database connection timeout using the web.props section of your `srm-extra-props.yaml` file. For example, you can switch from the 60-second default to a 120-second connection timeout with the following configuration:

```
web:
  props:
    limits:
      database:
        timeout: 120000
```

## Specify Extra SAML Configuration

Selecting SAML authentication in the Helm Prep Wizard will generate a config.json file with the following fields configured (field values are for illustrative purposes):

```
  ...
  "useSaml": true,
  "useLdap": false,
  "samlHostBasePath": "http://localhost:9090/srm",
  "samlIdentityProviderMetadataPath": "/path/to/idp-metadata.xml",
  "samlAppName": "srm-app",
  "samlKeystorePwd": "password",
  "samlPrivateKeyPwd": "password",
  ...
```

Running helm-prep.ps1 with a config.json file like the above will generate a Software Risk Manager props file with the following SAML properties:

- auth.saml2.identityProviderMetadataPath
- auth.saml2.entityId
- auth.saml2.keystorePassword
- auth.saml2.privateKeyPassword
- auth.hostBasePath

If you want to configure additional SAML properties described in the Software Risk Manager Install Guide, add them to your srm-extra-props.yaml file. 

>Note: Refer to the [Customizing Software Risk Manager](#customizing-software-risk-manager) section if you are unfamiliar with an srm-extra-props.yaml file.

Here's an example srm-extra-props.yaml with two SAML-specific props:

```
web:
  props:
    extra:
    - type: values
      key: srm-public-props
      values:
      - "ui.auth.samlLabel = Keycloak"
      - "auth.autoExternalRedirect = false"
```

## Specify LDAP Configuration

1. Complete the Helm Prep Wizard to generate the config.json file suitable for your Software Risk Manager deployment and invoke the resulting run-helm-prep.ps1 script.

2. Create a file named srm-ldap-private-props and add your LDAP props values. For example, you can set the LDAP URL, systemUsername, systemPassword, and authenticationMechanism by adding these values to your srm-ldap-private-props file:

```
auth.ldap.url = ldap://10.0.1.27
auth.ldap.systemUsername = CN=Code Dx Service Account,CN=Managed Service Accounts,DC=dc,DC=codedx,DC=local
auth.ldap.systemPassword = ************
auth.ldap.authenticationMechanism = simple
```

Note: If you plan to use LDAPS, switch `ldap://` to `ldaps://`, and, if necessary, add your LDAP server certificate to the web component's cacerts file.

3. If necessary, pre-create the Kubernetes Software Risk Manager namespace.

```
kubectl create ns srm
```

4. Generate a Kubernetes secret named srm-ldap-private-props in your Software Risk Manager namespace. For example, if your namespace is srm, run the following command from the directory containing srm-ldap-private-props:

```
kubectl -n srm create secret generic srm-ldap-private-props --from-file=srm-ldap-private-props
```

5. Reference your srm-ldap-private-props Kubernetes secret by adding a new entry to your srm-extra-props.yaml file.

```
web:
  props:
    extra:
    - key: srm-ldap-private-props
      type: secret
      name: srm-ldap-private-props
```

>Note: Refer to the [Customizing Software Risk Manager](#customizing-software-risk-manager) section if you are unfamiliar with an srm-extra-props.yaml file.

## Specify Custom Context Path

By default, Software Risk Manager is accessible at `/srm`. For backward compatibility, requests to `/codedx/api` and `/codedx/x` will be rewritten to `/srm/api` and `/srm/x` respectively, and requests to `/codedx` will be redirected to /srm.

You can change Software Risk Manager's context path by setting the web.appName Helm property. URL rewrites and redirects from /codedx get disabled when using a custom context path. Here's an example srm-extra-props.yaml that changes the default context path from `/srm` to `/mysrm`:

```
web:
  appName: mysrm
```

>Note: Refer to the [Customizing Software Risk Manager](#customizing-software-risk-manager) section if you are unfamiliar with an srm-extra-props.yaml file.

If you use SAML authentication, you must also update the web.authentication.saml.hostBasePath chart parameter by specifying your custom context path. Here is an example for the `/mysrm` context path where you would replace the `<hostname>` placeholder:

```
web:
  appName: mysrm
  authentication: 
    saml: 
      hostBasePath: https://<hostname>/mysrm
```

If you use the Scan Farm feature, you must also update the `scan-services.srm.url` helm chart parameter. Here is an example for the `/mysrm` context path where you would replace `srm-web` as necessary:

```
web:
  appName: mysrm
scan-services:
  srm:
    url: http://srm-web:9090/mysrm
```

>Note: Bridge CLI requires an /srm context path, so do not use a custom context path if you plan to use Bridge CLI.

If you are using the Ingress-NGINX controller, refer to this ingress resource example that uses path-based/fanout routing to make Software Risk Manager available at `/mysrm`:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  name: srm
  namespace: srm
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - backend:
          service:
            name: srm-web
            port:
              number: 9090
        path: /mysrm
        pathType: Prefix
```

## Scan Farm Job Resources

You can change the CPU and memory required for SAST and SCA scan jobs. Custom sizes are applied using helm chart values that alter Scan Service environment variables.

### SCA - Buildless Scan

To control the amount of CPU and memory used for SCA buildless scans, add the following content to your srm-extra-props.yaml file:

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKSCAN_CPU: cpu-in-millicores
      BLACKDUCKSCAN_MEM: memory-in-mebibytes
```

For example, to configure three vCPUs (3000m) and 3500Mi of memory, specify the following values:

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKSCAN_CPU: 3000
      BLACKDUCKSCAN_MEM: 3500
```

The above configuration will run on the default node pool (see [Scan Farm Node Pool requirements](#scan-farm-node-pool-requirements)), so your CPU and memory configuration must not exceed the capacity of nodes in that pool. If you want to use a custom node pool with higher capacity nodes, use the below configuration after creating a node pool with the label pool-type=custom with taint NodeType=ScannerNode (refer to [Scan Farm Node Pool requirements](#scan-farm-node-pool-requirements)).

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKSCAN_LABEL: "custom"
      BLACKDUCKSCAN_CPU: cpu-in-millicores
      BLACKDUCKSCAN_MEM: memory-in-mebibytes
```

### SCA - Bridge-based Scan

To control the amount of CPU and memory used for SCA scans started with Bridge, add the following content to your srm-extra-props.yaml file:

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKBDIO_CPU: cpu-in-millicores
      BLACKDUCKBDIO_MEM: memory-in-mebibytes
```

For example, to configure two vCPUs (2000m) and 2500Mi of memory, specify the following values:

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKBDIO_CPU: 2000
      BLACKDUCKBDIO_MEM: 2500
```

The above configuration will run on the default node pool (see [Scan Farm Node Pool requirements](#scan-farm-node-pool-requirements)), so your CPU and memory configuration must not exceed the capacity of nodes in that pool. If you want to use a custom node pool with higher capacity nodes, use the below configuration after creating a node pool with the label pool-type=custom with taint NodeType=ScannerNode (refer to [Scan Farm Node Pool requirements](#scan-farm-node-pool-requirements)).

```
scan-services:
  scan-service:
    environment:
      BLACKDUCKBDIO_LABEL: "custom"
      BLACKDUCKBDIO_CPU: cpu-in-millicores
      BLACKDUCKBDIO_MEM: memory-in-mebibytes
```

### SAST Scan

To control the amount of CPU and memory used for SAST scans, add the following content to your srm-extra-props.yaml file:

```
scan-services:
  scan-service:
    environment:
      COVCAPTURE_DEFAULTPOOLTYPE: "custom"
      COVANALYSIS_DEFAULTPOOLTYPE: "custom"
      CUSTOMNODEPOOL_LABEL: "custom"
      CUSTOMNODEPOOL_CPU: cpu-in-millicores
      CUSTOMNODEPOOL_MEM: memory-in-mebibytes
```

>Note: The above configuration references a "custom" CUSTOMNODEPOOL_LABEL, which requires a node pool having pool-type=custom with taint NodeType=ScannerNode (refer to [Scan Farm Node Pool requirements](#scan-farm-node-pool-requirements)).

For example, to configure four vCPUs (4000m) and 8000Mi of memory, specify the following values after creating a custom node pool that can support workloads of that size.

```
scan-services:
  scan-service:
    environment:
      COVCAPTURE_DEFAULTPOOLTYPE: "custom"
      COVANALYSIS_DEFAULTPOOLTYPE: "custom"
      CUSTOMNODEPOOL_LABEL: "custom"
      CUSTOMNODEPOOL_CPU: 4000
      CUSTOMNODEPOOL_MEM: 8000
```

## Tool Orchestration Add-in Tool Configuration

There are four types of ConfigMaps that can contain resource requirements:

- Global
- Global Tool
- Project
- Project Tool

Software Risk Manager deployment creates the Global Resource Requirement, providing default resource requirements for tools across every project. Global Tool requirements override Global requirements for specific tools. Project requirements override Global and Global Tool requirements by providing default resource requirements for tools associated with a given project. Project Tool requirements override other requirements by specifying values for a specific tool in a particular project.

The following is an example of how the scopes can overlap:

Global Resource Requirement:
- CPU Request = 1
- CPU Limit = 4
- Memory Request = 11G
- Memory Limit = 12G

Global Tool Resource Requirement:
- CPU Request = 3

Project Resource Requirement:
- Memory Request = 13G

Project Tool Resource Requirement:
- Memory Limit = 14G

Here are the effective resource requirements resulting from the above:

Effective Resource Requirement:
- CPU Request = 3
- CPU Limit = 4
- Memory Request = 13G
- Memory Limit = 14G

The naming convention determines the scope of a resource requirement ConfigMap:

- Global: cdx-toolsvc-resource-requirements
- Global Tool: cdx-toolsvc-ToolName-resource-requirements
- Project: cdx-toolsvc-project-ProjectID-resource-requirements
- Project Tool: cdx-toolsvc-project-ProjectID-ToolName-resource-requirements

ProjectID is the integer value representing the Software Risk Manager project identifier and ToolName is the tool name converted to an acceptable k8s resource name by the following rules:

  - Uppercase letters must be converted to lowercase.
  - Any character other than a lowercase letter, number, dash, or period must be converted to a dash.
  - An initial character that is neither a number nor a lowercase letter must be preceded by the letter "s."
  - A name whose length is greater than 253, must be truncated to 253 characters.

### Add-in Example 1 - Project Resource Requirement

To create a resource requirement for all tool runs of a Software Risk Manager project represented by ID 21, create a file named cdx-toolsvc-project-21-resource-requirements.yaml and enter the following data:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cdx-toolsvc-project-21-resource-requirements
data:
  requests.cpu: "1"
  limits.cpu: "2"
  requests.memory: "1G"
  limits.memory: "2G"
```
>Note: You can find a project's ID at the end of its Findings page URL. For example, a project with the ID 21 will have a Findings page URL that ends with /srm/projects/21.

Run the following command to create the ConfigMap resource, replacing the namespace name as necessary:

```
kubectl -n cdx-svc create -f ./cdx-toolsvc-project-21-resource-requirements.yaml
```

### Add-in Example 2 - Global Tool Resource Requirement

To create a Global Tool resource requirement for ESLint, create a file named cdx-toolsvc-eslint-resource-requirements.yaml and enter the following data:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cdx-toolsvc-eslint-resource-requirements
data:
  requests.cpu: "2"
  limits.cpu: "3"
  requests.memory: "4G"
  limits.memory: "5G"
```

Run the following command to create the configmap resource, replacing the namespace name as necessary:

```
kubectl -n cdx-svc create -f ./cdx-toolsvc-eslint-resource-requirements.yaml
```

### Add-in Example 3 - Node Selector

To create a Global Tool resource requirement for running a tool named MyTool on cluster nodes labeled with `canrunmytool=yes`, create a file named cdx-toolsvc-mytool-resource-requirements.yaml and enter the following data:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cdx-toolsvc-mytool-resource-requirements
data:
  nodeSelectorKey: canrunmytool
  nodeSelectorValue: yes
```

Run the following command to create the configmap resource, replacing the namespace name as necessary:

```
kubectl -n cdx-svc create -f ./cdx-toolsvc-mytool-resource-requirements.yaml
```

## Specify Scan Farm Engine Versions

Each Software Risk Manager version depends on a specific SAST and SCA engine version. If you upgrade to a new Software Risk Manager version with a different SAST and SCA engine version, you can retain the previous versions by specifying helm values.

Specify the SAST version by entering the version number in the following properties:

- web.scanfarm.sast
- scan-services.scan-service.environment.TOOL_COVERITY_VERSION

Specify the SCA version by entering the version number in the following properties:

- web.scanfarm.sca
- scan-services.scan-service.environment.TOOL_DETECT_VERSION

>Note: The previous SCA versions of 8.9.0 and 9.2.0 will not be supported after March 31, 2025.

For example, if you want to continue using SAST 2024.3.0 after upgrading Software Risk Manager, add the following to your srm-extra-props.yaml file:

```
web:
  scanfarm:
    sast:
      version: 2024.3.0
scan-services:
  scan-service:
    environment:
      TOOL_COVERITY_VERSION: "2024.3.0"
```

>Note: You must specify SAST/SCA versions that are compatible with Software Risk Manager.

## Add Extra Pod Labels

You can add extra labels to pods associated with the Core and Tool Orchestration features.

>Note: Refer to the [Customizing Software Risk Manager](#customizing-software-risk-manager) section if you are unfamiliar with an srm-extra-props.yaml file.

Here's an example srm-extra-props.yaml that adds the tool=software-risk-manager label to Core and Tool Orchestration pods:

```
podLabels:
  tool: software-risk-manager
mariadb:
  podLabels:
    tool: software-risk-manager
minio:
  podLabels:
    tool: software-risk-manager
argo-workflows:
  commonLabels:
    tool: software-risk-manager
```

>Note: Your extra label(s) will apply to all labeled resources generated by the argo-workflows chart.

## Specify MySQL Server Public Key Path

Using an external database with TLS is recommended. If you plan to use an unencrypted connection to an external MySQL database with the `caching_sha2_password` default_authentication_plugin, you can specify a public key file for the RSA key pair-based password exchange.

You can find the path to your MySQL server's public key file by entering `show variables like 'caching_sha2_password_public_key_path'` at a MySQL prompt. A value without a directory path refers to a file in the server's data directory.

Copy the public key file from your MySQL server and run this command, specifying the file's location (e.g., /path/to/public_key.pem):

```
kubectl -n srm create configmap srm-web-db-public-key-configmap --from-file db-public-key=/path/to/public_key.pem
```

Reference the above Kubernetes resource in your `srm-extra-props.yaml` file:

```
web:
  database:
    publicKeyConfigMap: "srm-web-db-public-key-configmap"
```

>Note: Refer to the [Customizing Software Risk Manager](#customizing-software-risk-manager) section if you are unfamiliar with an srm-extra-props.yaml file.

# Maintenance

Refer to this section for details on operating your Software Risk Manager deployment.

## System Component Password/Key Resets

Software Risk Manager workloads mount system passwords and API keys from Kubernetes Secrets established at deployment time. Some workloads can use a new password/key by restarting after updating a Kubernetes Secret resource on which they depend. Other workloads require a component-specific procedure followed by a corresponding update to related Kubernetes Secret resources.

If you previously deployed Software Risk Manager using the Quick Start method, you must switch to the Full Installation at this time. You can create a new config.json file by running the New Config script.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/new-config.ps1
```

You can update passwords and keys for the Software Risk Manager Core and Tool Orchestration features by using the Set Passwords wizard.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/set-passwords.ps1 -configPath /path/to/work/directory/config.json
```

## Expand Volume Size

Before expanding the volume size of a Software Risk Manager volume, verify that you are using a [storage class configured for volume expansion](https://kubernetes.io/docs/concepts/storage/storage-classes/#allow-volume-expansion). The number of volumes you have in your Software Risk Manage deployment depends on what features you installed and how they were configured. This section assumes that you installed both the Core and Tool Orchestration features, opting for on-cluster database and object storage workloads, but you can ignore content that does not apply to your deployment.

Expanding the on-cluster MariaDB database volumes requires special care because the workload resources use immutable database size references. Follow these steps to handle the necessary pre-work for MariaDB:

1. Scale the StatefulSet resources for the master and replica (if installed) to 0
2. Delete the StatefulSet resources for the master and replica (if installed), but do *not* delete the related PVC resources
3. Edit the PVC resources for the master, replica (if installed), and replica backup (if installed), setting the storage capacity to the new size. If using the System Size feature, refer to the System Size tables to determine the new sizes.
4. Invoke the describe command on each PVC to review resize-related Kubernetes events and conditions to know when to move on.

If you used the Helm Prep Script and the System Size feature, edit your config.json by changing the value of the systemSize field and rerun your run-helm-prep.ps1 script and related helm commands.

If you used the Helm Prep Script and did not use the System Size feature, edit your config.json by changing these fields: `webVolumeSizeGiB`, `dbVolumeSizeGiB`, `dbSlaveVolumeSizeGiB`, `dbSlaveBackupVolumeSizeGiB`, and `minioVolumeSizeGiB`. Then rerun your run-helm-prep.ps1 script and related helm commands.

If you used the Quick Start deployment, either include the following helm chart values in your srm-extra-props.yaml file or specify them with "--set" parameters, and rerun your helm command: `web.persistence.size`, `mariadb.master.persistence.size`, `mariadb.slave.persistence.size`, `mariadb.slave.persistence.backup.size`, and `minio.persistence.size`.

## Reset Replication

You can use an external MariaDB/MySQL database with Software Risk Manager or the on-cluster MariaDB database configuration with an optional replica database supporting system backups.

When replication is enabled, you can run the `SHOW REPLICA STATUS \G;` command on the replica to confirm that data replication is running correctly. If you observe an error with MariaDB replication, you can reset data replication using the below procedure. You will use three terminal windows to reset replication.

>Note: The steps in the following section assume two statefulsets, srm-mariadb-master and srm-mariadb-slave, and an srm-web deployment, all in the srm namespace. They also assume that you have a single replica instance, as you would not want to run RESET MASTER with other replicas in replication.

Terminal 1 (Stop web workload):

1.	kubectl -n srm scale --replicas=0 deployment/srm-web

Terminal 1 (Stop replication on replica):

2.	kubectl -n srm exec -it srm-mariadb-slave-0 -- bash
3.	mysql -uroot -p
4.	STOP SLAVE;
5.	exit # mysql
6.  exit # pod

Terminal 2 (Prepare for primary backup)

7.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
    >Note: Confirm zero database writers
8.	mysql -uroot -p
9.	RESET MASTER;
    >Note: RESET MASTER deletes previous binary log files, creating a new binary log file.
10.	FLUSH TABLES WITH READ LOCK;
11. SHOW MASTER STATUS;
    >Note: Record starting position in master log

Terminal 3 (Create primary backup):

12.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
13.	mysqldump -u root -p codedx > /bitnami/mariadb/codedx-dump.sql
    >Note: The above command assumes you have adequate space at /bitnami/mariadb to store your database backup. Use an alternate path as necessary, and adjust paths in subsequent steps accordingly.
14.	exit # pod
15.	exit # terminal

Terminal 2 (Unlock primary tables):

16.	UNLOCK TABLES;
17.	exit # mysql

Terminal 1 (Move primary backup to replica):

18.	kubectl -n srm cp srm-mariadb-master-0:/bitnami/mariadb/codedx-dump.sql ./codedx-dump.sql
19.	kubectl -n srm cp ./codedx-dump.sql srm-mariadb-slave-0:/bitnami/mariadb/codedx-dump.sql

>Note: Above commands are one option for moving the backup from the primary to the replica.

Terminal 2 (Delete primary backup):

20.	kubectl -n srm exec srm-mariadb-master-0 -- rm /bitnami/mariadb/codedx-dump.sql
21.	exit # terminal

Terminal 1 (Restore replication):

22. kubectl -n srm exec -it srm-mariadb-slave-0 -- bash
23.	mysql -u root -p codedx < /bitnami/mariadb/codedx-dump.sql
24.	mysql -uroot -p
25.	RESET SLAVE;
    >Note: RESET SLAVE deletes relay log files.
26. Remove old binary log files by running "FLUSH BINARY LOGS;", "SHOW BINARY LOGS;", and "PURGE BINARY LOGS TO 'name';"
27.	CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=position-from-step-11-goes-here;
    >Note: Replace position-from-step-11-goes-here before running the above command.
28.	START SLAVE;
29.	SHOW SLAVE STATUS \G;
30.	exit # mysql
31.	rm /bitnami/mariadb/codedx-dump.sql
32.	exit # pod

Terminal 1 (Start web workload):

33. kubectl -n srm scale --replicas=1 deployment/srm-web
34.	exit # terminal

## Web Logging

The Software Risk Manager Web component writes log messages to its log file and standard out using [Logback](https://logback.qos.ch/manual/introduction.html). The component's Logback configuration file gets mounted at /opt/codedx/logback.xml and looks like this:

```
<configuration>
  <appender name="logFile" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>${codedx.log.dir}/codedx.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <!-- rollover daily -->
      <fileNamePattern>${codedx.log.dir}/codedx-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
      <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
        <!-- or whenever the file size reaches 100MB -->
        <maxFileSize>100MB</maxFileSize>
      </timeBasedFileNamingAndTriggeringPolicy>
      <!-- keep 7 days worth of history -->
      <maxHistory>7</maxHistory>
      <cleanHistoryOnStart>true</cleanHistoryOnStart>
    </rollingPolicy>
    <encoder>
      <pattern>%-5level %d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>
  <appender name="stdout" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%-5level %d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>
  <logger name="net.liftweb" level="WARN" />
  <root level="INFO">
    <appender-ref ref="logFile" />
    <appender-ref ref="stdout" />
  </root>
</configuration>
```
You can alter the configuration file with the following procedure:

1. Save your configuration file to /path/to/srm-k8s-work-dir/logback.xml

2. Create a new ConfigMap containing your configuration file by running the following command, replacing the namespace as necessary:

```
kubectl -n srm create configmap srm-web-logging-cfgmap --from-file logback.xml=/path/to/srm-k8s-work-dir/logback.xml
```

3. If you already have an srm-extra-props.yaml file, merge the below content into your existing file. Otherwise, create your srm-extra-props.yaml file (see [Customizing Software Risk Manager](#customizing-software-risk-manager)) and add the following content:

```
web:
  loggingConfigMap: srm-web-logging-cfgmap
```

4. Refer to [Customizing Software Risk Manager](#customizing-software-risk-manager) for how to rerun helm with your srm-extra-props.yaml file.

## License Renewal

When you renew your Software Risk Manager license, Black Duck Software will issue a new license file. If your license includes the Scan Farm feature, you will receive a ZIP file containing multiple [Software Risk Manager licenses](#licensing).

While you can replace the Software Risk Manager license using the [web interface](https://documentation.blackduck.com/bundle/srm/page/user_guide/Settings/license_information.html) or API, the same is not possible for the Scan Farm feature license(s).

If you are using the Software Risk Manager Scan Farm feature, or prefer to update the Software Risk Manager Web license using the Helm Prep Script, update the following config.json fields, then rerun the Helm Prep Script along with the resulting kubectl commands:

| License | Field Name (config.json) | Field Value |
|:-|:-|:-|
| Software Risk Manager Web license | srmLicenseFile | /path/to/00000000-SRM-CDX.txt |
| Software Risk Manager Scan Farm SAST license | scanFarmSastLicenseFile | /path/to/00000000-SRM-SAVE.dat |
| Software Risk Manager Scan Farm SCA license | scanFarmScaLicenseFile | /path/to/00000000-SRM-SCA.json |

# Backup and Restore

Software Risk Manager depends on [Velero](https://velero.io) for cluster state and volume data backups. When not using an external web database, you must deploy with at least one MariaDB subordinate database so that a database backup occurs before Velero runs a backup.

If you are using an external web database, your database will not be included in the Velero-based backup. You must create a database backup schedule on your own. To minimize data loss, schedule your database backups to coincide with your cluster backups to help align your Kubernetes volume and database data after a restore.

> Note: The overall backup process is not an atomic operation, so it's possible to capture inconsistent state in a backup. For example, the web AppData volume backup could include a file that was unknown at the time the database backup occurred. The likelihood of capturing inconsistent state is a function of multiple factors including system activity and the duration of backup operations.

## About Velero

Velero can back up Kubernetes state stored in etcd and Kubernetes volume data. Volume data gets backed up using either [storage provider plugins](https://velero.io/docs/main/supported-providers/), or Velero's integration with [Restic](https://restic.net/) or [Kopia](https://kopia.io/). Refer to [How Velero Works](https://velero.io/docs/main/how-velero-works/), [How Velero integrates with Restic](https://velero.io/docs/main/file-system-backup/#how-velero-integrates-with-restic), and [How Velero integrates with Kopia](https://velero.io/docs/main/file-system-backup/#how-velero-integrates-with-kopia) for more details.

> Note: Use Velero's Restic or Kopia integration when a storage provider plugin is unavailable for your environment.

## Installing Velero

Install the [Velero CLI](https://velero.io/docs/main/basic-install/#install-the-cli) and then follow the Velero installation documentation for your scenario. You can find links to provider-specific documentation in the Setup Instructions column on the [Providers](https://velero.io/docs/main/supported-providers/) page, which includes links to the [Azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup) and [AWS](https://github.com/vmware-tanzu/velero-plugin-for-aws#setup) instructions. If you're not using a storage provider plugin, [enable file system backup](https://velero.io/docs/main/customize-installation/#enable-file-system-backup) at install time.

> Note: If your Velero backup unexpectedly fails, you may need to increase the amount of memory available to the Velero pod. Use the --velero-pod-mem-limit parameter with the velero install command as described [here](https://velero.io/docs/main/customize-installation/#customize-resource-requests-and-limits).

### Velero Opt-In or Opt-Out Volume Backup

If your Velero configuration requires opt-in (velero.io/backup-name=volume-name) or opt-out (velero.io/backup-volumes-excludes=volume-name) volume annotations, you can [customize your Software Risk Manager deployment](#customizing-software-risk-manager) by specifying pod annotations as shown below (opt-in example). Replace the volume name placeholders with your volume names.

```
web:
  podAnnotations:
    backup.velero.io/backup-volumes: appdata-volume-name

mariadb:
  slave:
    annotations:
      backup.velero.io/backup-volumes: backup-volume-name

minio:
  podAnnotations:
    backup.velero.io/backup-volumes: minio-volume-name
```

## Create a Backup Schedule

After installing Velero, you can create a [Schedule resource](https://velero.io/docs/main/api-types/schedule/).

### Schedule for On-Cluster Database

If you are using an on-cluster Software Risk Manager database, create a Schedule resource using the following YAML, replacing namespace names `velero` and `srm` as necessary.

```
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: srm-schedule
  namespace: velero
spec:
  schedule: 0 3 * * *
  template:
    hooks:
      resources:
      - includedNamespaces:
        - srm
        labelSelector:
          matchLabels:
            app: mariadb
            component: slave
        name: database-backup
        pre:
        - exec:
            command:
            - /bin/bash
            - -c
            - /bitnami/mariadb/scripts/backup.sh && sleep 1m
            container: mariadb
            timeout: 30m
    includeClusterResources: true
    includedNamespaces:
    - srm
    storageLocation: default
    ttl: 720h0m0s
```

>Note: The above Schedule requires a replica Software Risk Manager database whose backup.sh script will be invoked as a pre-backup hook.

### Schedule for External Database

If you are using an external Software Risk Manager database, create a Schedule resource using the following YAML, replacing namespace names `velero` and `srm` as necessary. Ensure that the external database backup occurs at the same time indicated by `spec.schedule`.

```
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: srm-schedule
  namespace: velero
spec:
  schedule: 0 3 * * *
  template:
    includeClusterResources: true
    includedNamespaces:
    - srm
    storageLocation: default
    ttl: 720h0m0s
```

## Verify Backup

Once backups start running, use the velero commands that [describe backups and fetch logs](https://velero.io/docs/v1.5/troubleshooting/#general-troubleshooting-information) to confirm that the backups are completing successfully and that they include Software Risk Manager volumes.

When using Velero with Storage Provider Plugins, the volume snapshots initiated by a plugin may finish after the Backup resource reports a completed status. Wait for the volume snapshot process to finish before starting a restore.

If applicable, you should also confirm that the database backup script runs correctly and produces database backups with each Velero backup in the /bitnami/mariadb/backup/data directory. Use the following command after replacing placeholder parameters to list recent backups for a MariaDB subordinate database instance:

```
$ kubectl -n srm-namespace-placeholder exec srm-mariadb-slave-pod-placeholder -- ls /bitnami/mariadb/backup/data
```

> Note: Older backup files get removed from the database volume when backups complete.

You can use this command to view the backup log on a MariaDB slave database instance.

```
$ kubectl -n srm-namespace-placeholder exec srm-mariadb-slave-pod-placeholder -- cat /bitnami/mariadb/backup/data/backup.log
```

The backup.log file should have a "completed OK!" message above the log entries indicating that old backups are getting removed.

> Note: To confirm that a backup includes the volume holding your Software Risk Manager database backup, test a backup by running a restore.

You should periodically check your Velero backups based on your backup schedule to ensure that backups are succeeding.

## Restoring Code Dx

Velero will skip restoring resources that already exist, so delete those you want to restore from a backup. You can delete the Software Risk Manager namespace to remove all namespaced resources, and you can delete cluster scoped Software Risk Manager resources to remove Software Risk Manager entirely. Since Software Risk Manager depends on multiple PersistentVolume (PV) resources, you will typically want to delete Software Risk Manager PVs when restoring Software Risk Manager to a previous known good state.

There are two steps required to restore Software Risk Manager from a Velero backup. The first step is to use the velero CLI to restore a specific backup. For the second step, you will run the restore-db.ps1 script to restore a local Software Risk Manager database. If you're using an external database, you will skip the second step by restoring your Software Risk Manager database on your own.

>Note: When using Velero with Storage Provider Plugins, wait for the volume snapshot process to finish before restoring a backup.

### Step 1: Restore Cluster State and Volume Data

During Step 1, you will use Velero to restore cluster and volume state from an existing backup. You can see a list of available backups by running the following command:

```
$ velero get backup
```

Assuming you want to restore a backup named 'my-backup', run the following command to install the PriorityClass resources from that backup:

```
$ velero restore create --from-backup my-backup --include-resources=PriorityClass
```

Wait for the restore started by the previous command to finish. You can use the describe command it prints to check progress.

A restore may finish with warnings and errors indicating that one or more resources could not be restored. Velero will not delete resources during a restore, so you may see warnings about Velero failing to create resources that already exist. Review any warnings and errors displayed by Velero's describe and log commands to determine whether they can be ignored.

> Note: You can use Velero's log command to view the details of a restore after it completes.

After waiting for the restore operation to finish, run the following command to restore the remaining resources from your backup:

```
$ velero restore create --from-backup my-backup
```

> Note: Running two velero commands works around an issue discovered in Velero v1.3.2 that blocks the restoration of Software Risk Manager pods. If you run only the second command, Software Risk Manager priority classes get restored, but pods depending on those classes do not.

When using Velero with storage provider plugins, your Software Risk Manager and MariaDB pods may not return to a running state. Step 2 will resolve that issue.

> Note: Software Risk Manager is not ready for use at the end of Step 1.

### Step 2: Restore Software Risk Manager Database

During Step 2, you will run the admin/restore-db.ps1 script to restore the Software Risk Manager database from a backup residing on the volume data you restored. If you are using an external Software Risk Manager database, restore your external database to a time that coincides with your Software Risk Manager backup and skip this section.

At this point, you can find the database backup corresponding to the backup you want to restore. Refer to the Verify Backup section for the command to list backup files on a MariaDB slave database instance. Note the name of the database backup that coincides with the Velero backup you restored (e.g., '20200523-020200-Full'). You will enter this name when prompted by the restore-db.ps1 script.

You must add both the helm and kubectl programs to your path before running the restore database script. Start a new PowerShell Core 7 session and change directory to where you downloaded the setup scripts from the [srm-k8s repository](https://github.com/codedx/srm-k8s).

```
/$ pwsh
PS /> cd ~/git/srm-k8s/admin
```

Start the restore-db.ps1 script by running the following command after replacing parameter placeholders:

```
PS /git/srm-k8s/admin/db> ./restore-db.ps1 `
        -namespace 'srm-namespace-placeholder' `
        -releaseName 'srm-helm-release-name-placeholder'
```

> Note: You can pull the Software Risk Manager Restore Database Docker image from an alternate Docker registry using the -imageDatabaseRestore parameter and from a private Docker registry by adding the -dockerImagePullSecretName parameter.

When prompted by the script, enter the name of the database backup you want to restore and the passwords for the MariaDB database root and replicator users. The script will search for the database backup, copy it to a folder in your profile, and use the backup to restore both master and slave database(s). It will then restart database replication, and it will manage the running instances of MariaDB and Software Risk Manager, so when the script is finished, all Software Risk Manager pods will be online. Depending on your ingress type and what was restored, you may need to update your DNS configuration before using the new Software Risk Manager instance.

> Note: The restore-db.ps1 script requires that your work directory (default is your profile directory) not already include a folder named backup-files. The script will stop if it finds that directory, so delete it before starting the script.

## Removing Backup Configuration

If you need to uninstall the backup configuration and Velero, do the following:

- Remove the Velero Schedule resource for your Software Risk Manager instance and related Backup and Restore resources (you can remove *all* Velero backup and restore objects by running `velero backup delete --all` and `velero restore delete --all`)
- [Uninstall Velero](https://velero.io/docs/main/uninstalling/)

## Reset Database Replication

Velero backups configured with an on-cluster MariaDB Web database depend on properly functioning replication. You can run the following command on a MariaDB replica database to see the replication status:

```
$ mysql -uroot -p
Enter password:
MariaDB [(none)]> SHOW REPLICA STATUS \G;
```

If the replication state shows an error permanently blocking data from moving between the primary and replica instances, replication should be reset to ensure proper backups. You can reset replication with the following steps that use four different terminal windows.

>Note: The steps assume two statefulsets named srm-mariadb-master and srm-mariadb-slave and a deployment named srm-web in the srm namespace with one subordinate database. It also assumes a database named codedx.

Terminal 1 (Subordinate DB):

1.	kubectl -n srm scale --replicas=0 deployment/srm-web
2.	kubectl -n srm exec -it srm-mariadb-slave-0 -- bash
3.	mysql -uroot -p
4.	STOP SLAVE;
5.	exit # mysql

Terminal 2 (Master DB):

6.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
7.	mysql -uroot -p
8.	RESET MASTER;
>Note: RESET MASTER deletes previous binary log files, creating a new binary log file.
9.	FLUSH TABLES WITH READ LOCK;

Terminal 3 (Master DB):

10.	kubectl -n srm exec -it srm-mariadb-master-0 -- bash
11.	mysqldump -u root -p codedx > /bitnami/mariadb/srm-dump.sql

>Note: The above command assumes you have adequate space at /bitnami/mariadb to store your database backup. Use an alternate path as necessary, and adjust paths in subsequent steps accordingly.

Terminal 2 (Master DB)

12.	UNLOCK TABLES;

Terminal 4:

13.	kubectl -n srm cp srm-mariadb-master-0:/bitnami/mariadb/srm-dump.sql ./srm-dump.sql
14.	kubectl -n srm cp ./srm-dump.sql srm-mariadb-slave-0:/bitnami/mariadb/srm-dump.sql

Terminal 1 (Subordinate DB):

15.	mysql -u root -p codedx < /bitnami/mariadb/srm-dump.sql
16.	mysql -uroot -p
17.	RESET SLAVE;
>Note: RESET SLAVE deletes relay log files.
18. Remove old binary log files by running "FLUSH BINARY LOGS;", "SHOW BINARY LOGS;", and "PURGE BINARY LOGS TO 'name';"
19.	CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=1;
20.	START SLAVE;
21.	SHOW SLAVE STATUS \G;
22.	exit # mysql
23.	rm /bitnami/mariadb/srm-dump.sql
24.	exit # pod
25.	exit # terminal

Terminal 2 (Master DB):

26.	exit # mysql
27.	rm /bitnami/mariadb/srm-dump.sql
28.	exit # pod
29.	exit # terminal

Terminal 3 (Master DB):

30.	exit # pod
31.	exit # terminal

Terminal 4:

32.	kubectl -n srm scale --replicas=1 deployment/srm-web
33.	exit # terminal

# Upgrades

Software Risk Manager has four major releases typically spaced evenly throughout the year. Minor releases are published on the second Tuesday of each month, with hotfixes released as needed. Updates to the Software Risk Manager Core feature get advertised with a notification in the Software Risk Manager web interface.

## Applying an Update

The [srm-k8s GitHub repository](https://github.com/codedx/srm-k8s) is updated with each Software Risk Manager release. Additional Kubernetes-specific releases may occur between planned Software Risk Manager releases. Each release has a version number based on [Semantic Versioning](https://semver.org/) with release notes published on the [releases page](https://github.com/codedx/srm-k8s/releases). 

>Note: It is essential to read release notes associated with releases introducing breaking changes.

The Helm chart version number (i.e., the chart's version field) will always reference an associated srm-k8s release, and the chart's appVersion field will always reference the version number of the associated Software Risk Manager Core feature.

A Software Risk Manager upgrade typically starts by updating your repository clone. If you open your run-helm-prep.ps1 script, you'll notice how it points to the Helm Prep Script in your repo clone. Rerunning your run-helm-prep.ps1 script reruns the Helm Prep script version associated with the Software Risk Manager version you're upgrading to, and that will generate kubectl/helm commands suitable for your upgraded instance.

>Note: You will not rerun the Helm Prep Wizard when upgrading Software Risk Manager.

An upgrade occurs with this four-step process:

1. Pull the latest from this GitHub Repository
   ```
   $ cd /path/to/git/srm-k8s
   $ git pull
   ```
   >Note: The above command assumes you are upgrading to the latest version. You can update to a specific version by running `git checkout version-number` instead.

2. If you previously pulled Software Risk Manager Docker images from the Black Duck Docker registry or you copied Docker images from Docker Hub to your private Docker registry, refer to the [registry deployment script](deploy/registry.md) to re-pull/push required Docker images.

3. Rerun the Helm Prep Script
   ```
   $ cd /path/to/srm-k8s-work-dir # the directory you entered into the Helm Prep Wizard - see your config.json's workDir field
   $ pwsh ./run-helm-prep.ps1
   ```

4. Follow the instructions printed by the Helm Prep script and rerun the printed helm/kubectl commands

>Note: The Helm Prep script instructions may include pulling updated Docker images from Black Duck Repo, which you must do before running the recommended helm commands.

### TLS

The TLS configuration for the Scan Farm Cache Service and the optional inter-component TLS will get regenerated during a helm install or upgrade. It may be necessary to restart pods configured for TLS if they do not restart during a helm upgrade.

## Adding the Scan Farm Feature

You can add the Scan Farm feature to an existing Software Risk Manager deployment, provided that you are using the latest deployment model (srm-k8s, not codedx-kubernetes). You will update your config.json file by running the Add Scan Farm Wizard. Next, you will rerun the Helm Prep Script via your run-helm-prep.ps1 script and invoke the recommended helm and kubectl commands.

>Note: The Add Scan Farm Wizard will create a backup of your config.json file by saving a copy with the file extension `.json.bak`.

You should complete all of the [Scan Farm Pre-work](#scan-farm-pre-work) before running the add-scanfarm.ps1 script.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/add-scanfarm.ps1 -configPath /path/to/work/directory/config.json
```

## Reconfigure the Scan Farm Feature

You can run the Add Scan Farm Wizard to reconfigure the Scan Farm feature. The wizard will update your config.json file so that you can rerun the Helm Prep Script via your run-helm-prep.ps1 script and invoke the recommended helm and kubectl commands.

>Note: The Add Scan Farm Wizard will create a backup of your config.json file by saving a copy with the file extension `.json.bak`.

You should complete all of the [Scan Farm Pre-work](#scan-farm-pre-work) before running the add-scanfarm.ps1 script.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/add-scanfarm.ps1 -configPath /path/to/work/directory/config.json
```

## Trusting Additional Certificates

You can have the Software Risk Manager web pod trust additional certificates by running the Add Trusted Certificates Wizard to update your config.json file before rerunning the Helm Prep Script via your run-helm-prep.ps1 script and invoking the recommended helm command.

>Note: The Add Trusted Certificates Wizard will create a backup of your config.json file by saving a copy with the file extension `.json.bak`.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/add-trustedcerts.ps1 -configPath /path/to/work/directory/config.json
```

## Adding SAML Authentication

You can opt for SAML authentication when you run the Helm Prep Wizard. If you did not, you can alter your Software Risk Manager configuration to authenticate users against a SAML 2.0 IdP (Identity Provider) by running the Add SAML Authentication Wizard. The wizard will update your config.json file, allowing you to rerun the Helm Prep Script via your run-helm-prep.ps1 script and invoke the recommended helm command to apply your SAML configuration.

>Note: The Add SAML Authentication Wizard will create a backup of your config.json file by saving a copy with the file extension `.json.bak`.

```
$ cd /path/to/srm-k8s
$ pwsh ps/features/add-samlauth.ps1 -configPath /path/to/work/directory/config.json
```

# Code Dx Deployment Model Migration

Code Dx was renamed the Software Risk Manager with the 2023.8.0 release, which introduced a new deployment model that supports a separately licensed Scan Farm feature with built-in SAST and SCA scanning powered by Coverity and Black Duck.

The new deployment model differs from the legacy one in the following ways:

| Deployment Detail | Old Model | New Model |
|:-|:-:|:-:|
| Wizard | Guided Setup | Helm Prep Wizard |
| Script | Deployment Script | Helm Prep Script |
| Requires Connected Cluster | Yes | No |
||||
| Git Repo | [codedx-kubernetes](https://github.com/codedx/codedx-kubernetes) | [srm-k8s](https://github.com/codedx/srm-k8s) |
| Chart Repo | n/a | https://codedx.github.io/srm-k8s |
||||
| Helm Charts | 2 | 1 |
| Namespaces | 2 | 1 |
||||
| Core Feature | Yes | Yes |
| Tool Orchestration Feature | Yes | Yes |
| Scan Farm Feature | No | Yes |
||||
| Manual Helm Deployment | Yes | Yes |
| Automated Helm Deployment | Yes | No |
| Flux v1 GitOps Deployment | Yes | No |
| Flux v2 GitOps Deployment | Yes | Yes |
| YAML Deployment | Yes | No |
||||
| Pre-work Deployment Guide | No | Yes |
| Quick Start Deployments | 0 | 2 |
| Full Deployment Prereqs | 7 | 3 |
| Full Deployment Configuration | run-setup.ps1 parameters | config.json file (conditionally password-protected) |

The legacy deployment model available at [codedx-kubernetes](https://github.com/codedx/codedx-kubernetes) contains the Guided Setup that you previously ran to populate your initial run-setup.ps1 file with the Code Dx Deployment Script parameters suitable for your Code Dx installation. This section explains how to switch from the legacy deployment model to the new one, using your run-setup.ps1 as input into the migration process.

Installing Software Risk Manager from scratch without a data migration is a four-step process:

- Clone this GitHub Repository
- Run the Helm Prep Wizard (once)
- Run the Helm Prep Script
- Invoke helm/kubectl Commands

Migrating from your legacy Code Dx deployment to Software Risk Manager requires these steps:

- Clone this GitHub Repository
- Run the Software Risk Manager Migration Script
- Run the Helm Prep Script
- Invoke helm/kubectl Commands (to install a brand-new, empty system)
- Copy Code Dx Data to Software Risk Manager

Note how the Software Risk Manager Migration Script replaces the Helm Prep Wizard and how the migration process has an extra step to copy data between your Code Dx and Software Risk Manager deployments.

In the new deployment model, the Helm Prep Wizard replaces the Code Dx Guided Setup. Whereas the Guided Setup stored Deployment Script parameters in a run-setup.ps1 file, the wizard generates a config.json file with your deployment parameters. The Helm Prep Script replaces the Code Dx Deployment script and takes as input the config.json file generated by the wizard.

You will not run the Helm Prep Wizard when migrating your Code Dx deployment because your Software Risk Manager configuration gets inferred from the content of your legacy deployment's run-setup.ps1 script.

## Before you Begin

Before you get started, make sure that you have satisified the Software Risk Manager deployment [prerequisites](#prerequisites) and understand the [requirements](#requirements).

Back up your Code Dx system now so that you can restore its state should something go wrong with your data migration.

>Note: Data migration for external workflow storage is unsupported because it will be reused with your Software Risk Manager deployment. Contact Black Duck if you would like guidance on how to avoid reuse for external workflow storage.

## Clone the srm-k8s GitHub Repository

The [srm-k8s GitHub repository](https://github.com/codedx/srm-k8s) includes the scripts you need to migrate from the Code Dx deployment model to the Software Risk Manager one. Run the following command to clone the repository by fetching the files required to install the latest Software Risk Manager release:

```
$ git clone https://github.com/codedx/srm-k8s
$ cd /path/to/git/srm-k8s
```

## Upgrade your Code Dx Version

If your legacy Code Dx version differs from the Software Risk Manager version you plan to install, upgrade your Code Dx system to match the Software Risk Manager version before you continue. For example, if you are running Code Dx 2023.4.0 and planning to install Software Risk Manager 2024.6.0, upgrade your Code Dx 2023.4.0 system to Code Dx 2024.6.0 before continuing. Since the 2024.6.0 upgrade may involve data migrations and other upgrades, avoid conflating those upgrade activities with your migration to the Software Risk Manager Helm chart.

Verify that your upgraded Code Dx system works as expected, and then back up your Code Dx system so that you can restore its state should something go wrong with your migration.

## Stop Code Dx Web

You must turn off the Code Dx Web workload, leaving it offline during the migration process.

1) Scale down your source Code Dx web workload, replacing the `cdx-app` namespace and `codedx` deployment name as necessary:

```
$ kubectl -n cdx-app scale --replicas=0 deployment/codedx
```

## Stop Code Dx Tool Orchestration (if installed)

You must turn off Code Dx Tool Orchestration workloads, leaving them offline during the migration process.

1) Scale down your source Code Dx Tool Orchestration workloads, replacing the `cdx-svc` namespace, `codedx-tool-orchestration` and `codedx-tool-orchestration-minio` deployment names as necessary:

```
$ kubectl -n cdx-svc scale --replicas=0 deployment/codedx-tool-orchestration
$ kubectl -n cdx-svc scale --replicas=0 deployment/codedx-tool-orchestration-minio
```

## Run the Software Risk Manager Migration Script

Your Code Dx to Software Risk Manager migration starts with the migrate.ps1 script whose command-line interface matches the Code Dx deployment script parameters you will find in your run-setup.ps1 file.

Locate your run-setup.ps1 file before continuing. The script should be runnable from its current location. For example, any files it references must be present on your local system.

Make a copy of your run-setup.ps1 file:

```
$ cp /path/to/run-setup.ps1 /path/to/run-migrate.ps1
```

Edit run-migrate.ps1 by prepending the path to the migrate.ps1 script (e.g., `/path/to/git/srm-k8s/admin/migrate/migrate.ps1`) followed by ` -codeDxSetupScriptPath`. For example, your edited file will look like this:

```
/path/to/git/srm-k8s/admin/migrate/migrate.ps1 -codeDxSetupScriptPath /path/to/git/codedx-kubernetes/setup/steps/../core/setup.ps1 -workDir '/home/user/.k8s-codedx' -kubeContextName 'cluster' -kubeApiTargetPort '443' -namespaceCodeDx 'cdx-app' -releaseNameCodeDx 'codedx' ...
```

Before continuing, verify that the `-codeDxAdminPwd` parameter value matches the current admin password for your Code Dx instance. If the password matches the initial admin password, update the parameter by specifying the current password.

```
/path/to/git/srm-k8s/admin/migrate/migrate.ps1 -codeDxSetupScriptPath /path/to/git/codedx-kubernetes/setup/steps/../core/setup.ps1 -workDir '/home/user/.k8s-codedx' -kubeContextName 'cluster' -kubeApiTargetPort '443' -namespaceCodeDx 'cdx-app' -releaseNameCodeDx 'codedx' -codeDxAdminPwd 'current-admin-password-goes-here' ... 
```

Invoke your run-migrate.ps1 script to generate a config.json file.

```
$ pwsh /path/to/run-migrate.ps1
```

>Note: You should specify a new, unique namespace and release name to avoid conflating legacy Code Dx Kubernetes resources with Software Risk Manager ones. You can reuse your Code Dx license when prompted for a Software Risk Manager Web license.

Address any warnings or instructions printed by the migration script. When complete, invoke the generated run-helm-prep.ps1 file to stage the resources required for your Software Risk Manager deployment.

## Install Software Risk Manager

Invoke the run-helm-prep.ps1 script generated by your run-migrate.ps1 script, which you will find in the new work directory you specified. 

```
$ pwsh /path/to/run-helm-prep.ps1
```

Follow the instructions printed by run-helm-prep.ps1 and wait for Software Risk Manager to come online before continuing to the next section to import your Code Dx data into Software Risk Manager.

## Stop Software Risk Manager Web

Wait for all Software Risk Manager pods to reach a ready state before stopping Software Risk Manager workloads. You must turn off the Software Risk Manager Web workload, leaving it offline during the migration process.

1) Scale down your destination Software Risk Manager Web workload, replacing the `srm` namespace and `srm-web` deployment name as necessary:

```
$ kubectl -n srm scale --replicas=0 deployment/srm-web
```

## Stop Software Risk Manager Tool Orchestration (if installed)

1) Scale down your destination Software Risk Manager Tool Orchestration instance, replacing the `srm` namespace, `srm-to` and `srm-minio` deployment names as necessary:

```
$ kubectl -n srm scale --replicas=0 deployment/srm-to
$ kubectl -n srm scale --replicas=0 deployment/srm-minio
```

## Work Directory

You will be copying files between remote pods and your local system, so start by switching to a local directory with sufficient disk space. We'll refer to this directory as your work directory.

```
$ cd /path/to/local/work/directory
```

## Copy Code Dx Web Files Locally

You must copy data from your Code Dx Web volume(s) to your Software Risk Manager Web volume. 

1) Save the following content to a file named host-code-dx-appdata-volume.yaml in /path/to/local/work/directory, replacing the `cdx-app` namespace, `codedx/codedx-tomcat:v2023.8.0` Docker image name (with the version you are running), and `codedx-appdata` volume name as necessary:

>Note: You can find your Code Dx AppData volume name with this command, replacing the `cdx-app` namespace as necessary: kubectl -n cdx-app get pvc

```
apiVersion: v1
kind: Pod
metadata:
  name: host-code-dx-appdata-volume
  namespace: cdx-app
spec:
  containers:
    - image: codedx/codedx-tomcat:v2023.8.0
      name: host-code-dx-appdata-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/cdx"
        name: volume
  securityContext:
    fsGroup: 1000
    runAsGroup: 1000
    runAsUser: 1000
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: codedx-appdata
```

2) Run the following command to start the host-code-dx-appdata-volume pod, replacing the `cdx-app` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl apply -f host-code-dx-appdata-volume.yaml
$ kubectl -n cdx-app wait --for=condition=Ready pod/host-code-dx-appdata-volume
```

3) Run the following commands to copy your Code Dx files locally, replacing the `cdx-app` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl -n cdx-app exec -it host-code-dx-appdata-volume -- bash
$ cd /var/cdx
$ tar -cvzf /var/cdx/appdata.tgz $(ls -d analysis-files notification-templates attachments keystore/master.key keystore/Secret tool-data/addin-tool-files 2> /dev/null)
$ exit
$ kubectl -n cdx-app cp host-code-dx-appdata-volume:/var/cdx/appdata.tgz appdata.tgz
```

4) Run the following command to delete the host-code-dx-appdata-volume pod:

```
$ kubectl delete -f /path/to/local/work/directory/host-code-dx-appdata-volume.yaml
```

5) Delete the /path/to/local/work/directory/host-code-dx-appdata-volume.yaml file.

## Copy Local Code Dx Web Files to Software Risk Manager

1) Save the following content to a file named host-srm-appdata-volume.yaml in /path/to/local/work/directory, replacing the `srm` namespace, `codedx/codedx-tomcat:v2023.8.0` Docker image name (with the version you are running), and `srm-appdata` volume name as necessary:

>Note: You can find your Software Risk Manager AppData volume name with this command, replacing the `srm` namespace as necessary: kubectl -n srm get pvc

```
apiVersion: v1
kind: Pod
metadata:
  name: host-srm-appdata-volume
  namespace: srm
spec:
  containers:
    - image: codedx/codedx-tomcat:v2023.8.0
      name: host-srm-appdata-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/srm"
        name: volume
  securityContext:
    fsGroup: 1000
    runAsGroup: 1000
    runAsUser: 1000
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: srm-appdata
```

2) Run the following command to start the host-srm-appdata-volume pod, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl apply -f host-srm-appdata-volume.yaml
$ kubectl -n srm wait --for=condition=Ready pod/host-srm-appdata-volume
```

3) Run the following commands to copy your local files to Software Risk Manager, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl -n srm cp appdata.tgz host-srm-appdata-volume:/var/srm
$ kubectl -n srm exec -it host-srm-appdata-volume -- bash
$ cd /var/srm
$ tar xzvf appdata.tgz
$ rm appdata.tgz
$ exit
```

4) Run the following command to delete the host-srm-appdata-volume pod:

```
$ kubectl delete -f /path/to/local/work/directory/host-srm-appdata-volume.yaml
```

5) Delete the /path/to/local/work/directory/host-srm-appdata-volume.yaml file.

## Backup Code Dx Database

You must create a database backup from either your on-cluster MariaDB database or your external database.

### Backup On-Cluster MariaDB Database

Skip this section if you are using an external database.

1) Run the following commands to create a logical backup, replacing the `cdx-app` namespace and `codedx-mariadb-master-0` pod name as necessary:

```
$ kubectl -n cdx-app exec -it codedx-mariadb-master-0 -- bash
$ mysqldump --host=127.0.0.1 --port=3306 --user=root -p codedx > /bitnami/mariadb/dump-codedx.sql
$ # verify "Dump completed" message (see Note 2)
$ tail -n 1 /bitnami/mariadb/dump-codedx.sql
$ cd /bitnami/mariadb
$ tar -cvzf dump-codedx.tgz dump-codedx.sql
$ rm dump-codedx.sql
$ exit # bash
```

>Note 1: The above command assumes you have adequate space at /bitnami/mariadb to store your database backup; expand your data volume if you need more disk capacity.

>Note 2: Confirm that your dump file ends with a "Dump completed" message (e.g., tail -n 1 /bitnami/mariadb/dump-codedx.sql), and consider performing a restore test to another catalog on the same database instance where you can compare tables/data.

2) Copy dump-codedx.sql to your local work directory with the following commands, replacing the `cdx-app` namespace and `codedx-mariadb-master-0` pod name as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl -n cdx-app cp codedx-mariadb-master-0:/bitnami/mariadb/dump-codedx.tgz dump-codedx.tgz
```

### Backup External Database

Skip this section if you are using an on-cluster MariaDB database.

1) Log on to your external database host and use mysqldump to create a logical backup, replacing the host, port, user, and database parameters as necessary.

```
$ mysqldump --host=127.0.0.1 --port=3306 --user=admin -p codedxdb > dump-codedx.sql
```

>Note: Confirm that your dump file ends with a "Dump completed" message (e.g., tail -n 1 dump-codedx.sql), and consider performing a restore test to another catalog on the same database instance where you can compare tables/data.

2) Copy dump-codedx.sql to your local work directory.

## Restore Code Dx Database

You must restore a database backup to either your on-cluster MariaDB database or your external database.

### Restore On-Cluster MariaDB Database

Skip this section if you are using an external database.

Restore the database backup from your local system by running the restore-db.ps1 script, replacing placeholder parameter values:

>Note: The -backupToRestore parameter value must not include a colon character

```
$ cd /path/to/local/work/directory
$ pwsh /path/to/git/srm-k8s/admin/db/restore-db-logical.ps1 -backupToRestore './dump-codedx.tgz' -rootPwd '<srm-db-root-pwd>' -replicationPwd '<srm-db-repl-pwd>' -namespace '<srm-namespace>' -releaseName '<srm-release-name>' -waitSeconds 600 -skipSRMWebRestart
```

### Restore External Database

Skip this section if you are using an on-cluster MariaDB database.

Run a mysql command similiar to the following to import your logical backup, replacing the `admin` username, hostname, and `srmdb` database placeholders as necessary:

```
$ sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i dump-codedx.sql
$ mysql -h 127.0.0.1 -uadmin -p srmdb < dump-codedx.sql
```

>Note: If you see the `Access denied; you need (at least one of) the SUPER, SET USER privilege(s) for this operation` error message, confirm that you ran the `sed` command above.

## Copy Code Dx MinIO Files Locally (if installed)

This section is optional, describing how to copy previously generated orchestrated analysis data from Code Dx to Software Risk Manager. Old orchestrated analysis data will not be available in Software Risk Manager, but you can copy this data to your MinIO Software Risk Manager instance, where you can access it directly and delete it when it is no longer needed.

1) Save the following content to a file named host-code-dx-minio-volume.yaml in /path/to/local/work/directory, replacing the `cdx-svc` namespace and `codedx-tool-orchestration-minio` volume name as necessary:

>Note: You can find your Code Dx MinIO volume name with this command, replacing the `cdx-svc` namespace as necessary: kubectl -n cdx-svc get pvc

```
apiVersion: v1
kind: Pod
metadata:
  name: host-code-dx-minio-volume
  namespace: cdx-svc
spec:
  containers:
    - image: bitnamilegacy/minio:2024.11.7-debian-12-r2
      name: host-code-dx-minio-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/cdx"
        name: volume
  securityContext:
    fsGroup: 1001
    runAsGroup: 1001
    runAsUser: 1001
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: codedx-tool-orchestration-minio
```

2) Run the following command to start the host-code-dx-minio-volume pod, replacing the `cdx-svc` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl apply -f host-code-dx-minio-volume.yaml
$ kubectl -n cdx-svc wait --for=condition=Ready pod/host-code-dx-minio-volume
```

3) Run the following commands to copy your Code Dx MinIO files locally, replacing the `cdx-svc` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl -n cdx-svc exec -it host-code-dx-minio-volume -- bash
$ cd /var/cdx
$ tar -cvzf /var/cdx/minio.tgz code-dx-storage
$ exit
$ kubectl -n cdx-svc cp host-code-dx-minio-volume:/var/cdx/minio.tgz minio.tgz
```

4) Run the following command to delete the host-code-dx-minio-volume pod:

```
$ kubectl delete -f /path/to/local/work/directory/host-code-dx-minio-volume.yaml
```

5) Delete the /path/to/local/work/directory/host-code-dx-minio-volume.yaml file.

## Copy Local Code Dx MinIO Files to Software Risk Manager (if installed)

Skip this section if you did not copy Code Dx MinIO files locally.

1) Save the following content to a file named host-srm-minio-volume.yaml in /path/to/local/work/directory, replacing the `srm` namespace and `srm-minio` volume name as necessary:

>Note: You can find your Software Risk Manager MinIO volume name with this command, replacing the `srm` namespace as necessary: kubectl -n srm get pvc

```
apiVersion: v1
kind: Pod
metadata:
  name: host-srm-minio-volume
  namespace: srm
spec:
  containers:
    - image: bitnamilegacy/minio:2024.11.7-debian-12-r2
      name: host-srm-minio-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/srm"
        name: volume
  securityContext:
    fsGroup: 1001
    runAsGroup: 1001
    runAsUser: 1001
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: srm-minio-snsd
```

2) Run the following command to start the host-srm-minio-volume.yaml pod, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl apply -f host-srm-minio-volume.yaml
$ kubectl -n srm wait --for=condition=Ready pod/host-srm-minio-volume
```

3) Run the following commands to copy your local MinIO files to Software Risk Manager, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/work/directory
$ kubectl -n srm cp minio.tgz host-srm-minio-volume:/var/srm
$ kubectl -n srm exec -it host-srm-minio-volume -- bash
$ cd /var/srm
$ tar xzvf minio.tgz
$ rm minio.tgz
$ exit
```

4) Run the following command to delete the host-srm-minio-volume pod:

```
$ kubectl delete -f /path/to/local/work/directory/host-srm-minio-volume.yaml
```

5) Delete the /path/to/local/work/directory/host-srm-minio-volume.yaml file.

## Copy Tool Orchestration Resources from Code Dx to Software Risk Manager (if installed)

1) Set your kube context to the cluster hosting your Code Dx deployment, replacing the context name placeholder:

```
$ kubectl config use-context <context-name>
```

2) Run the following command to copy Tool Orchestration resources from the `cdx-svc` namespace to the `srm` namespace, replacing namespace names as necessary and removing the `-srmKubeConfigPath` and `-srmKubeContextName` parameters if the Software Risk Manager namespace is in the same cluster as the Code Dx namespace:

```
$ pwsh
PS> /path/to/git/srm-k8s/admin/migrate/copy-tool-orch-resources.ps1 `
  -sourceNamespace 'cdx-svc' `
  -srmNamespace 'srm' `
  -srmKubeConfigPath '/path/to/SoftwareRiskManager/.kube/config' `
  -srmKubeContextName '<name>'
```

## Start Software Risk Manager Tool Orchestration (if installed)

1) Run the following commands to start the Tool Orchestration workloads, replacing the `srm` namespace and the `srm-to` and `srm-minio` deployment names as necessary:

```
$ kubectl -n srm scale --replicas=1 deployment/srm-minio
$ kubectl -n srm scale --replicas=1 deployment/srm-to
```

## Start Software Risk Manager Web

1) Run the following command to start the Software Risk Manager Web workload, replacing the `srm` namespace and the `srm-web` deployment name as necessary:

```
$ kubectl -n srm scale --replicas=1 deployment/srm-web
```

# Cannot Run PowerShell Core

Running the Helm Prep Wizard and Helm Prep Script is the recommended deployment method when the Quick Start installation is not applicable. The Helm Prep Wizard is a one-time step, and the Helm Prep Script helps ensure that your Kubernetes resources and Helm values files are correctly defined. Rerunning the Helm Prep Script on upgrade helps ensure your deployment works with any required chart changes associated with a new Software Risk Manager version. 

Running the scripts in an alternate environment can help you stage your helm deployment if you cannot run PowerShell Core in your primary environment. Alternatively, consider running the scripts from a Docker container:

>Note: Some of the following commands must be run with elevated permissions.

```
$ docker run -it --rm mcr.microsoft.com/powershell bash
$ apt update

$ # install git
$ apt install -y git

$ # install Java
$ apt install -y wget apt-transport-https
$ mkdir -p /etc/apt/keyrings
$ wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
$ echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
$ apt update
$ apt install -y temurin-11-jdk

$ apt install -y curl
$ export YOUR_KUBECTL_VERSION='v1.32.7' # specify the correct kubectl version for your cluster
$ curl -L https://dl.k8s.io/release/$YOUR_KUBECTL_VERSION/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
$ chmod +x /usr/local/bin/kubectl

$ # start Helm Prep Wizard
$ git clone https://github.com/codedx/srm-k8s
$ cd srm-k8s
$ pwsh ./helm-prep-wizard.ps1

$ # run Helm Prep Script
$ pwsh "/root/.k8s-srm/run-helm-prep.ps1"
```

# Moving a Software Risk Manager Deployment

Follow the instructions below if you need to move your Software Risk Manager deployment from one cluster (i.e., source cluster) to another (i.e., destination cluster). 

>Note: The move procedure does not include transferring Scan Farm feature storage or Tool Orchestration log data, so you should separately back up that data if it is something you want to keep.

## Deploy a new Software Risk Manager Instance

Your first step in moving your instance is to install Software Risk Manager from scratch on the destination cluster. You must install the exact same version of Software Risk Manager that is running on your source cluster.

If your destination Software Risk Manager deployment will differ from your source deployment, you should rerun the Helm Prep Wizard, respecifying parameter values as appropriate. You can use the Helm Prep Wizard's `-priorConfigPath` parameter to show the source deployment configuration related to the questions you will be asked about your destination deployment. You may have to reason about how the configuration applies. For example, when asked whether to enable network policies, interpret a `true` for skipNetworkPolicies as indicative of your previous response to not enable network policies.

You can run the Helm Prep Wizard with a reference to your source deployment config.json file like this:

```
$ pwsh /path/to/git/srm-k8s/helm-prep-wizard.ps1 -previousConfigPath /path/to/source/deployment/config.json
```

If you ran the Helm Prep Wizard, follow its instructions to prepare for your Helm install. If not, install the destination Software Risk Manager using your config.json settings with the Helm Prep script and/or invoke helm. Complete the installation and verify that the destination web pod shows a Ready state prior to continuing.

## Stop Source Software Risk Manager Web Workload

Stop your source Software Risk Manager web workload by scaling to zero replicas with the following command, replacing the `srm` namespace and the `srm-web` deployment name as necessary:

```
kubectl -n srm scale --replicas=0 deployment/srm-web
```

## Copy Source Software Risk Manager Web Volume Files

Wait for the web workload pod to terminate and then mount the web workload's storage in a utility workload by creating a pod from the following YAML, replacing the `srm` namespace, the `srm-appdata` deployment name, and the `securityContext` as necessary:

```
apiVersion: v1
kind: Pod
metadata:
  name: host-srm-web-appdata-volume
  namespace: srm
spec:
  containers:
    - image: codedx/codedx-tomcat:v2025.6.3
      name: host-srm-web-appdata-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/srm"
        name: volume
  securityContext:
    fsGroup: 1000
    runAsGroup: 1000
    runAsUser: 1000
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: srm-appdata
```

Wait for the utility pod to reach a Ready state, then copy the volume data locally using the following commands, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/directory
$ kubectl -n srm exec -it host-srm-web-appdata-volume -- bash
$ cd /var/srm
$ tar -cvzf /var/srm/appdata.tgz $(ls -d analysis-files notification-templates attachments keystore/master.key keystore/Secret tool-data/addin-tool-files 2> /dev/null)
$ exit
$ kubectl -n srm cp host-srm-web-appdata-volume:/var/srm/appdata.tgz appdata.tgz
```

Delete the utility pod using the following command, replacing the `srm` namespace name as necessary:

```
$ kubectl -n srm delete pod/host-srm-web-appdata-volume
```

## Copy Source Software Risk Manager Database Backup

Log on to your Software Risk Manager database and run the following commands to create a backup file, replacing the `codedx` database name as necessary:

```
$ mysqldump --host=127.0.0.1 --port=3306 --user=root -p codedx > dump-codedx.sql
$ sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i dump-codedx.sql
```

>Note: If you see a "Read-only file system" message, change directory to a writable location (e.g., cd /bitnami/mariadb)

Copy your dump-codedx.sql file to a local directory. If you are using the on-cluster MariaDB database, run the following command, replacing the `srm` namespace and paths as necessary:

```
$ kubectl -n srm cp srm-mariadb-master-0:/bitnami/mariadb/dump-codedx.sql ./dump-codedx.sql
```

## Stop Destination Software Risk Manager Web Workload

Stop your destination Software Risk Manager web workload by scaling to zero replicas with the following command, replacing the `srm` namespace and the `srm-web` deployment name as necessary:

```
kubectl -n srm scale --replicas=0 deployment/srm-web
```

## Replace Destination Software Risk Manager Web Volume Files

Wait for the web workload pod to terminate and then mount the web workload's storage in a utility workload by creating a pod from the following YAML, replacing the `srm` namespace, the `srm-appdata` deployment name, and the `securityContext` as necessary:

```
apiVersion: v1
kind: Pod
metadata:
  name: host-srm-web-appdata-volume
  namespace: srm
spec:
  containers:
    - image: codedx/codedx-tomcat:v2025.6.3
      name: host-srm-web-appdata-volume
      command: ["sleep", "1d"]
      volumeMounts:
      - mountPath: "/var/srm"
        name: volume
  securityContext:
    fsGroup: 1000
    runAsGroup: 1000
    runAsUser: 1000
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: srm-appdata
```

Copy the source volume data to the utility pod using the following commands, replacing the `srm` namespace as necessary:

```
$ cd /path/to/local/directory
$ kubectl -n srm cp appdata.tgz host-srm-web-appdata-volume:/var/srm/appdata.tgz
$ kubectl -n srm exec -it host-srm-web-appdata-volume -- bash
$ cd /var/srm
$ tar xzvf appdata.tgz
$ rm appdata.tgz
$ exit
```

Delete the utility pod using the following command, replacing the `srm` namespace name as necessary:

```
$ kubectl -n srm delete pod/host-srm-web-appdata-volume
```

## Replace Destination Software Risk Manager Database

Copy your dump-codedx.sql file to your Software Risk Manager database instance, log on, and run the following command to restore your backup file, replacing the `codedx` database name as necessary:

```
mysql -u root -p codedx < /path/to/dump-codedx.sql
```

If you used the Software Risk Manager helm chart to deploy MariaDB with replication enabled, you must follow the [reset replication instructions](#reset-replication).

## Move Tool Orchestration Resources (if installed)

Set your kube context to the cluster hosting your source deployment, replacing the context name placeholder:

```
$ kubectl config use-context <context-name>
```

Run the following command to copy Tool Orchestration resources from the `srm` namespace of the source cluster to the `srm` namespace of the destination, replacing namespace names as necessary, specifying a value for the `-srmKubeConfigPath` parameter, and the destination context name as the `-srmKubeContextName` parameter:

```
$ pwsh
PS> /path/to/git/srm-k8s/admin/migrate/copy-tool-orch-resources.ps1 `
  -sourceNamespace 'srm' `
  -srmNamespace 'srm' `
  -srmKubeConfigPath '/path/to/SoftwareRiskManager/.kube/config' `
  -srmKubeContextName '<name>'
```

## Start Destination Software Risk Manager Web Workload

Start your destination Software Risk Manager web workload by scaling to 1 replica with the following command, replacing the `srm` namespace and the `srm-web` deployment name as necessary:

```
kubectl -n srm scale --replicas=1 deployment/srm-web
```

# Software Risk Manager Helm Chart

This section describes the Software Risk Manager Helm chart that the Helm Prep Wizard and Helm Prep Script help you configure.

>Note: The chart is available in the [srm-k8s GitHub repository](https://github.com/codedx/srm-k8s/tree/main/chart) and the [srm-k8s chart repository](https://codedx.github.io/srm-k8s/index.yaml).

## Chart Dependencies

Depending on the Software Risk Manager features you install and how you configure them, your deployment will depend on zero or more of the following sub-charts.

| Name | Feature | Repository | Purpose |
|:-|:-|:-|:-|
| argo-workflows | Tool Orchestration | https://argoproj.github.io/argo-helm | Required to manage orchestrated analyses |
| mariadb | Core | https://codedx.github.io/srm-k8s | Optional on-cluster Software Risk Manager database |
| minio | Tool Orchestration | https://codedx.github.io/srm-k8s | Optional on-cluster Software Risk Manager workflow storage |
| scan-services | Scan Farm | https://repo.blackduck.com/artifactory/sig-cloudnative | Required to run SAST and SCA scans |

## Values

The following table lists the Software Risk Manager Helm chart values. Run `helm show values srm --repo https://codedx.github.io/srm-k8s` to see the values for the latest chart.

>Note: You can run `helm show values srm --repo https://codedx.github.io/srm-k8s --version 1.15.0` to see the values for a specific chart version, like 1.15.0 in the example.

| Key | Type | Default/Example | Description |
|:---|:---|:---|:---|
| argo-workflows.commonLabels | string | object | labels added to all Argo resources |
| argo-workflows.controller.image.registry | string | `docker.io` | the Argo workflow controller Docker image registry |
| argo-workflows.controller.instanceID.enabled | bool | `true` | whether the Argo workflow controller uses an instance ID |
| argo-workflows.controller.instanceID.useReleaseName | bool | `true` | whether the Argo workflow controller instance ID uses the release name |
| argo-workflows.controller.name | string | `wc` | the name of the Argo workflow controller |
| argo-workflows.controller.nodeSelector | object | `{}` | the node selector for the Argo workflow controller |
| argo-workflows.controller.pdb.enabled | bool | `false` | whether to create a pod disruption budget for the Argo component (a workflow controller can tolerate occasional downtime) |
| argo-workflows.controller.priorityClassName | string | `srm-wf-controller-pc` | the Argo priority class name whose value (see to.workflowController) must be set relative to other priority values |
| argo-workflows.controller.resources.limits.cpu | string | `"500m"` | the required CPU for the Argo workload |
| argo-workflows.controller.resources.limits.memory | string | `"500Mi"` | the required memory for the Argo workload |
| argo-workflows.controller.tolerations | list | `[]` | the pod tolerations for the Argo component |
| argo-workflows.controller.workflowNamespaces | list | `[]` | the namespace for the Argo workflow service account |
| argo-workflows.executor.image.registry | string | `docker.io` | the Argo executor Docker image registry |
| argo-workflows.images.pullSecrets | list | `[]` | the K8s image pull secret to use for Argo Docker images |
| argo-workflows.images.tag | string | `"v3.7.1"` | the Docker image version for the Argo workload |
| scan-services.common-infra.cleanupSchedule | string | `"*/55 * * * *"` | the schedule to use for the cleanup cronjob - must be a valid schedule for a K8s cronjob |
| scan-services.imagePullPolicy | string | `"Always"` | the image pull policy for scan farm components |
| scan-services.srm.port | string | `"9090"` | the port number of the SRM web service |
| features.mariadb | bool | `true` | whether to enable the on-cluster MariaDB; an external database must be used otherwise |
| features.minio | bool | `false` | whether to enable the on-cluster MinIO for the SRM Tool Orchestration feature; an external object storage system must be used otherwise |
| features.scanfarm | bool | `false` | whether to enable the Scan Farm feature, which requires an SRM Scan Farm license |
| features.to | bool | `false` | whether to enable the Tool Orchestration feature, which requires an SRM Tool Orchestration license |
| imagePullSecrets | list | `[]` | the K8s image pull secret to use for SRM Docker images Command: kubectl create secret docker-registry private-registry --docker-server=your-registry-server --docker-username=your-username --docker-password=your-password --docker-email=your-email |
| ingress.annotations.scanfarm.cache "nginx.ingress.kubernetes.io/backend-protocol" | string | `"HTTPS"` | the protocol for the K8s cache service |
| ingress.annotations.scanfarm.cache "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the cache service ingress (no max when 0) |
| ingress.annotations.scanfarm.scan "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the scan service ingress (no max when 0) |
| ingress.annotations.scanfarm.storage "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"500m"` | the max proxy body size for the storage service ingress (no max when 0) |
| ingress.annotations.web "nginx.ingress.kubernetes.io/proxy-body-size" | string | `"0"` | the max proxy body size for the web component ingress (no max when 0) |
| ingress.annotations.web "nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"3600"` | the proxy read timeout for the web component ingress |
| ingress.className | string | `"nginx"` | the class name for the SRM ingress |
| ingress.enabled | bool | `false` | whether to enable an SRM ingress (required for the Scan Farm feature) |
| ingress.hosts[0] | object | `{"host":"chart-example.local"}` | the host to associate with the SRM ingress |
| ingress.tls | list | `[]` | the TLS configuration for the SRM ingress |
| mariadb.db.name | string | `"codedx"` | the on-cluster database catalog name for SRM web (must be codedx) |
| mariadb.db.user | string | `"codedx"` | the on-cluster database username for SRM web (must be codedx) |
| mariadb.existingSecret | string | `""` | the K8s secret name containing the on-cluster MariaDB root and user passwords with required fields mariadb-root-password and mariadb-password Command: kubectl -n srm create secret generic srm-mariadb-secret --from-literal mariadb-root-password=password --from-literal mariadb-password=password |
| mariadb.image.pullPolicy | string | `"IfNotPresent"` | the K8s Docker image pull policy for the MariaDB workload |
| mariadb.image.pullSecrets | list | `[]` | the K8s image pull secret to use for MariaDB Docker images |
| mariadb.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the MariaDB Docker image |
| mariadb.image.repository | string | `"codedx/codedx-mariadb"` | the Docker image repository name for the MariaDB workload |
| mariadb.image.tag | string | `"v1.38.0"` | the Docker image version for the MariaDB workload |
| mariadb.master.masterCaConfigMap | string | `nil` | the configmap name containing the CA cert with required field ca.crt Command: kubectl -n srm create configmap master-ca-configmap --from-file ca.crt=/path/to/ca.crt |
| mariadb.master.masterTlsSecret | string | `nil` | the K8s secret name containing the public and private TLS key with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls master-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| mariadb.master.nodeSelector | object | `{}` | the node selector to use for the MariaDB primary database workload |
| mariadb.master.persistence.existingClaim | string | `nil` | the existing claim to use for the MariaDB primary persistent volume; a new persistent volume is generated when unset |
| mariadb.master.persistence.size | string | `"64Gi"` | the size of the MariaDB persistent volume  |
| mariadb.master.persistence.storageClass | string | `nil` | the storage class name for the MariaDB primary persistent volume; the default storage class used when unset |
| mariadb.master.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the MariaDB primary database component |
| mariadb.master.podDisruptionBudget.maxUnavailable | int | `0` | the maximum number of unavailable instances of the MariaDB primary database component |
| mariadb.master.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the MariaDB primary database component |
| mariadb.master.priorityClass.value | int | `10200` | the MariaDB primary database component priority value, which must be set relative to other Tool Orchestration component priority values |
| mariadb.master.resources.limits.cpu | string | `"1000m"` | the required CPU for the MariaDB primary database workload |
| mariadb.master.resources.limits.memory | string | `"8192Mi"` | the required memory for the MariaDB primary database workload |
| mariadb.master.tolerations | list | `[]` | the pod tolerations for the MariaDB primary database component |
| mariadb.podLabels | object | `{}` | labels added to the database pods |
| mariadb.replication.enabled | bool | `false` | whether to enable MariaDB replication |
| mariadb.serviceAccount.create | bool | `true` | whether to create a service account for the MariaDB service |
| mariadb.slave.annotations."backup.codedx.io/type" | string | `"none"` | the annotations for the MariaDB replica database component |
| mariadb.slave.nodeSelector | object | `{}` | the node selector to use for the MariaDB replica database workload |
| mariadb.slave.persistence.backup.size | string | `"64Gi"` | the size of the backup persistent volume |
| mariadb.slave.persistence.size | string | `"64Gi"` | the size of the MariaDB replica database persistent volume |
| mariadb.slave.persistence.storageClass | string | `nil` | the storage class name for the MariaDB replica persistent volume; the default storage class used when unset |
| mariadb.slave.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the MariaDB replica database component |
| mariadb.slave.podDisruptionBudget.minAvailable | int | `1` | the minimum number of available instances of the MariaDB replica database component |
| mariadb.slave.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the MariaDB replica database component |
| mariadb.slave.priorityClass.value | int | `10200` | the MariaDB replica database component priority value, which must be set relative to other Tool Orchestration component priority values |
| mariadb.slave.replicas | int | `1` | the number of replica database workloads |
| mariadb.slave.resources.limits.cpu | string | `"1000m"` | the required CPU for the MariaDB replica database workload |
| mariadb.slave.resources.limits.memory | string | `"8192Mi"` | the required memory for the MariaDB replica database workload |
| mariadb.slave.tolerations | list | `[]` | the pod tolerations for the MariaDB replica database component |
| minio.enabled | bool | `true` | whether to enable the on-cluster MinIO component |
| minio.auth.useCredentialsFiles | bool | `true` | whether to mount MinIO credential values as files |
| minio.global.minio.existingSecret | string | `nil` | the K8s secret name with the MinIO access and secret key with required fields access-key and secret-key Command: kubectl -n srm create secret generic minio-secret --from-literal=access-key=admin --from-literal=secret-key=password |
| minio.image.pullSecrets | list | `[]` | the K8s Docker image pull policy for the MinIO workload |
| minio.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the MinIO Docker image |
| minio.image.repository | string | `"bitnamilegacy/minio"` | the Docker image repository name for the MinIO workload |
| minio.image.tag | string | `"2025.7.23-debian-12-r5"` | the Docker image version for the MinIO workload |
| minio.nodeSelector | object | `{}` | the node selector to use for the MinIO workload |
| minio.persistence.existingClaim | string | `nil` | the existing claim to use for the MinIO persistent volume; a new persistent volume is generated when unset |
| minio.persistence.size | string | `"64Gi"` | the size of the MinIO persistent volume  |
| minio.persistence.storageClass | string | `nil` | the storage class name for the MinIO persistent volume; the default storage class used when unset |
| minio.podAnnotations | object | `{}` | the pod annotations to use for the MinIO pod |
| minio.podDisruptionBudget.enabled | bool | `true` | whether to create a pod disruption budget for the MinIO component |
| minio.podDisruptionBudget.maxUnavailable | int | `0` | the maximum number of unavailable instances of the MinIO component |
| minio.podLabels | object | `{}` | labels added to the MinIO pod |
| minio.priorityClassValue | int | `10100` | the MinIO component priority value, which must be set relative to other Tool Orchestration component priority values |
| minio.resources.limits.cpu | string | `"2000m"` | the required CPU for the MinIO workload |
| minio.resources.limits.memory | string | `"500Mi"` | the required memory for the MinIO workload |
| minio.tls.enabled | boolean | `false` | whether to use TLS for MinIO |
| minio.tls.existingSecret | string | `nil` | the K8s secret name for MinIO component TLS with required fields tls.crt, tls.key, and ca.crt |
| minio.tolerations | list | `[]` | the pod tolerations for the MinIO component |
| networkPolicy.enabled | bool | `false` | whether to enable network policies for SRM components that support network policy |
| networkPolicy.k8sApiPort | int | `443` | the port for the K8s API, required when using the Tool Orchestration feature |
| networkPolicy.to.egress.extraPorts.tcp | list | `[53,443]` | the TCP ports allowed for egress from the tool service component |
| networkPolicy.to.egress.extraPorts.udp | list | `[53]` | the UDP ports allowed for egress from the tool service component |
| networkPolicy.web.egress.extraPorts.tcp | list | `[22,53,80,389,443,636,7990,7999]` | the TCP ports allowed for egress from the web component |
| networkPolicy.web.egress.extraPorts.udp | list | `[53,389,636,3269]` | the UDP ports allowed for egress from the web component |
| openshift.createSCC | bool | `false` | whether to create SecurityContextConstraint resources, which is required when using OpenShift |
| openshift.routes.enabled | bool | `false` | whether to use Routes for ingress |
| openshift.routes.host | string | `nil` | the host associated with routes |
| openshift.routes.tls.enabled | bool | `false` | whether to use secured routes |
| openshift.routes.tls.caCertificate | string | `nil` | the PEM-formatted CA certificate for your route TLS configuration |
| openshift.routes.tls.certificate | string | `nil` | the PEM-formatted certificate for your route TLS configuration |
| openshift.routes.tls.key | string | `nil` | the TLS key for your route TLS configuration |
| openshift.routes.tls.destination.scanfarmCaCertificate | string | `nil` | the PEM-formatted Scan Farm CA certificate |
| openshift.routes.tls.destination.webCaCertificate | string | `nil` | the PEM-formatted web CA certificate |
| podLabels | object | `{}` | labels added to SRM pods of the Core and TO features |
| sizing.size | string | `Small` | whether the deployment size is considered Unspecified, Small, Medium, Large, or Extra Large (see [System Size](#system-size)) |
| sizing.version | string | `v1.0` | the version of the sizing guidance |
| tls.certManager.enabled | bool | `false` | whether to create cert-manager Certificate resources (cert-manager CRD) |
| tls.certManager.duration | string | `2160h` | the amount of time before the certificate is invalid |
| tls.certManager.renewBefore | string | `360h` | the amount of time before the certificate enters the renewal period |
| tls.certManager.issuerRef.name | string | `ca-issuer` | the name of the cert-manager cluster issuer or issuer |
| tls.certManager.issuerRef.kind | string | `Issuer` | the type of cert-manager issuer, Issuer or ClusterIssuer |
| to.caConfigMap | string | `nil` | the configmap name containing the CA cert with required field ca.crt for SRM web |
| to.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the SRM Tool Orchestration Docker images |
| to.image.repository.helmPreDelete | string | `"codedx/codedx-cleanup"` | the Docker image repository name for the SRM cleanup workload |
| to.image.repository.newAnalysis | string | `"codedx/codedx-newanalysis"` | the Docker image repository name for the SRM new-analysis workload |
| to.image.repository.prepare | string | `"codedx/codedx-prepare"` | the Docker image repository name for the SRM prepare workload |
| to.image.repository.sendResults | string | `"codedx/codedx-results"` | the Docker image repository name for the SRM send-results workload |
| to.image.repository.toolService | string | `"codedx/codedx-tool-service"` | the Docker image repository name for the SRM tool service workload |
| to.image.repository.tools | string | `"codedx/codedx-tools"` | the Docker image repository name for the SRM tools workload |
| to.image.tag | string | `"v2.17.0"` | the Docker image version for the SRM Tool Orchestration workloads (tools use the web.image.tag version)|
| to.logs.maxBackups | int | `20` | the maximum number of tool service log files to retain |
| to.logs.maxSizeMB | int | `10` | the maximum size of a tool service log file |
| to.minimumWorkflowStepRunTimeSeconds | int | `3` | the minimum seconds for an orchestrated analysis workflow step |
| to.nodeSelector | object | `{}` | the node selector to use for the tool service |
| to.podDisruptionBudget.enabled | bool | `true` | whether to create a pod disruption budget for the tool service |
| to.podDisruptionBudget.minAvailable | int | `1` | the minimum number of available instances of the tool service |
| to.priorityClass.serviceValue | int | `10100` | the tool service priority value, which must be set relative to other Tool Orchestration component priority values |
| to.priorityClass.workflowValue | int | `10000` | the tool workflow priority value, which must be set relative to other Tool Orchestration component priority values |
| to.resources.limits.cpu | string | `"1000m"` | the required CPU for the tool service workload |
| to.resources.limits.memory | string | `"1024Mi"` | the required memory for the tool service workload |
| to.resources.requests.storage | string | `"5Mi"` | the requested ephemeral storage for the tool service workload |
| to.service.numReplicas | int | `1` | the number of tool service replicas |
| to.service.toolServicePort | int | `3333` | the tool service port number |
| to.service.type | string | `"ClusterIP"` | the K8s service type for the tool service |
| to.serviceAccount.annotations | object | `{}` | the annotations to apply to the SRM tool service account |
| to.serviceAccount.create | bool | `true` | whether to create a service account for the tool service |
| to.serviceAccount.name | string | `nil` | the name of the service account to use; a name is generated using the fullname template when unset and create is true |
| to.systemSecurityContext.podSecurityContext.fsGroup | int | `1000` | fsGroup for the system workflow pods |
| to.systemSecurityContext.podSecurityContext.runAsGroup | int | `1000` | gid for the system workflow pods |
| to.systemSecurityContext.podSecurityContext.runAsUser | int | `1000` | uid for the system workflow pods |
| to.systemSecurityContext.podSecurityContext.runAsNonRoot | boolean | `true` | whether to run the system workflow pods as non-root |
| to.systemSecurityContext.podSecurityContext.seccompProfile.type | string | `RuntimeDefault` | type of seccomp profile for the system workflow pods |
| to.systemSecurityContext.podSecurityContext.supplementalGroups | array | `[]` | the list of extra groups for the system workflow pods |
| to.systemSecurityContext.securityContext.readOnlyRootFilesystem | boolean | `true` | whether the system workflow pods use a read-only filesystem |
| to.systemSecurityContext.securityContext.allowPrivilegeEscalation | boolean | `false` | whether the system workflow pods support privilege escalation |
| to.systemSecurityContext.securityContext.capabilities.drop | array | `[]` | capabilities to remove from the system workflow pods |
| to.tlsSecret | string | `nil` | the K8s secret name for tool service TLS with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls to-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| to.toSecret | string | `nil` | the K8s secret name containing the API key for the tool service with required field api-key Command: kubectl -n srm create secret generic tool-service-pd --from-literal api-key=password |
| to.tolerations | list | `[]` | the pod tolerations for the tool service component |
| to.toolServicePort | int | `3333` | the port number for the tool service |
| to.tools.limits.init.cpu | string | `""` | the default CPU limit for init workflow containers |
| to.tools.limits.init.memory | string | `""` | the default memory limit for init workflow containers|
| to.tools.limits.wait.cpu | string | `""` | the default CPU limit for wait workflow containers |
| to.tools.limits.wait.memory | string | `""` | the default memory limit for wait workflow containers |
| to.tools.limits.tool.cpu | string | `"2"` | the default CPU limit for the tool workloads |
| to.tools.limits.tool.memory | string | `"2G"` | the default memory limit for the tool workloads |
| to.tools.nodeSelectorKey | string | `nil` | the node selector key to use for tool pods |
| to.tools.nodeSelectorValue | string | `nil` | the node selector key value to use for tool pods |
| to.tools.podTolerationKey | string | `nil` | the pod toleration key to use for tool pods |
| to.tools.podTolerationValue | string | `nil` | the pod toleration key value to use for tool pods |
| to.tools.requests.tool.cpu | string | `"500m"` | the default CPU request for the tool workloads |
| to.tools.requests.tool.memory | string | `"500Mi"` | the default memory request for the tool workloads |
| to.workflowController.priorityClass.value | int | `10100` | the Argo priority value, which must be set relative to other Tool Orchestration component priority values (see argo-workflows.priorityClassName) |
| to.workflowStorage.bucketName | string | `"code-dx-storage"` | the name of workflow storage bucket that will store workflow files. This should be an existing bucket when the account associated  with the storage credentials cannot create the bucket on its own. |
| to.workflowStorage.configMapName | string | `""` | the K8s configmap name that contains certificate data that should be explicitly trusted when connecting to workflow storage - use configMapName when the workflow storage server's certificate was not issued by a well-known CA. |
| to.workflowStorage.configMapPublicCertKeyName | string | `""` | the key name in the configMapName ConfigMap containing the certificate data. |
| to.workflowStorage.endpoint | string | `nil` | the workflow storage endpoint to use, either an external endpoint (e.g., AWS, GCP) or the older, bundled MinIO instance. Specify the hostname and port (e.g., hostname:port). |
| to.workflowStorage.endpointSecure | string | `nil` | whether the endpoint is secured with HTTPS. |
| to.workflowStorage.existingSecret | string | `nil` | whether to use an existing secret, with fields access-key and secret-key, for the storage credential. The credential must be able to create and delete objects in the bucket given by the 'bucketName' parameter. |
| web.authentication.saml.appName | string | `nil` | the application/client name for the SRM SAML registration |
| web.authentication.saml.enabled | bool | `false` | whether to use SAML authentication |
| web.authentication.saml.hostBasePath | string | `nil` | the host base path for the SRM SAML registration (https://mysrmhost/srm) |
| web.authentication.saml.samlIdpXmlFileConfigMap | string | `nil` | the configmap name containing the IdP metadata file with required field saml-idp.xml |
| web.authentication.saml.samlSecret | string | `""` | the K8s secret name containing the SAML keystore passwords with required field saml-keystore.props that contains a HOCON-formatted file with SRM props auth.saml2.keystorePassword and auth.saml2.privateKeyPassword File: auth.saml2.keystorePassword = """keystore-password""" auth.saml2.privateKeyPassword = """private-key-password""" |
| web.caConfigMap | string | `""` | the configmap name containing the CA cert with required field ca.crt for SRM web |
| web.cacertsSecret | string | `""` | the K8s secret name containing the Java keystore contents and its password with required fields cacerts and cacerts-password Note: cacerts must trust the database cert when using 'REQUIRE SSL' with an external database Command: kubectl -n srm create secret generic srm-web-cacerts-secret --from-file cacerts=./cacerts --from-literal cacerts-password=changeit |
| web.database.rdsAuth.enabled | bool | `false` | whether to enable RDS IAM authentication (set web.serviceAccount.name accordingly) |
| web.database.credentialSecret | string | `""` | the K8s secret name containing the database connection properties with required field db.props that contains a HOCON-formatted file with SRM props swa.db.user and swa.db.password File:  swa.db.user = """username""" swa.db.password = """password""" Command: kubectl -n srm create secret generic srm-web-db-cred-secret --from-file db.props=./db.props |
| web.database.externalDbUrl | string | `nil` | the URL for the external SRM web database (jdbc:mysql://my-srm-web-db-host:3306/my-srm-web-db-name?useSSL=true&requireSSL=true) |
| web.database.publicKeyConfigMap | string | `""` | the K8s configmap name containing the RSA public key when using MySQL's caching_sha2_password plugin |
| web.image.pullPolicy | string | `"IfNotPresent"` | the K8s Docker image pull policy for the SRM web workload |
| web.image.registry | string | `"docker.io"` | the registry name and optional registry suffix for the SRM web Docker image |
| web.image.repository | string | `"codedx/codedx-tomcat"` | the Docker image repository name for the SRM web workload |
| web.image.tag | string | `"v2025.9.4"` | the Docker image version for the SRM web workload |
| web.javaOpts | string | `"-XX:MaxRAMPercentage=75.0"` | the Java options for the SRM web workload |
| web.licenseSecret | string | `""` | the K8s secret name containing the SRM license password with required field license.lic Command: kubectl -n srm create secret generic srm-web-license-secret --from-file license.lic=./license.lic |
| web.loggingConfigMap | string | `""` | the K8s configmap containing the logging configuration file with required field logback.xml Command: kubectl -n srm create configmap srm-web-logging-cfgmap --from-file logback.xml=./logback.xml |
| web.nodeSelector | object | `{}` | the node selector to use for the SRM web workload |
| web.persistence.accessMode | string | `"ReadWriteOnce"` | the access mode for the AppData persistent volume |
| web.persistence.existingClaim | string | `""` | the existing claim to use for the AppData persistent volume; a new persistent volume is generated when unset |
| web.persistence.size | string | `"64Gi"` | the size of the AppData persistent volume  |
| web.persistence.storageClass | string | `nil` | the storage class name for the AppData persistent volume; the default storage class used when unset |
| web.podAnnotations | object | `{}` | the pod annotations to use for the SRM web pod |
| web.podDisruptionBudget.enabled | bool | `false` | whether to create a pod disruption budget for the web component |
| web.podSecurityContext.fsGroup | int | `1000` | the fsGroup for the SRM web pod |
| web.podSecurityContext.runAsGroup | int | `1000` | the gid for the SRM web pod |
| web.podSecurityContext.runAsUser | int | `1000` | the uid for the SRM web pod |
| web.podSecurityContext.runAsNonRoot | boolean | `true` | whether to run the SRM web pod as non-root |
| web.podSecurityContext.seccompProfile.type | string | `RuntimeDefault` | the type of seccomp profile for the SRM web pod |
| web.podSecurityContext.supplementalGroups | array | `[]` | the list of extra groups for the SRM web pod |
| web.priorityClass.create | bool | `false` | whether to create a PriorityClass resource for the web component |
| web.priorityClass.value | int | `10100` | the web component priority value, which must be set relative to other Tool Orchestration component priority values |
| web.props.context.path | string | `/srm` | the optional context path for the web component |
| web.props.extra | list | `[]` | the list of extra resources containing SRM prop settings |
| web.props.limits.analysis.concurrent | int | `2` | the value of the SRM prop analysis.concurrent-analysis-limit, which determines the maximum number of analyses to run concurrently |
| web.props.limits.database.poolSize | int | `5` | the size of the database connection pool |
| web.props.limits.database.timeout | int | `60000` | the maximum milliseconds that a client will wait for a database connection from the pool |
| web.props.limits.jobs.cpu | int | `2000` | the value of the SRM prop swa.jobs.cpu-limit, which determines the maximum available CPU |
| web.props.limits.jobs.database | int | `2000` | the value of the SRM prop swa.jobs.database-limit, which determines the maximum available database I/O |
| web.props.limits.jobs.disk | int | `2000` | the value of the SRM prop swa.jobs.disk-limit, which determins the maximum available disk I/O |
| web.props.limits.jobs.memory | int | `2000` | the value of the SRM prop swa.jobs.memory-limit, which determines the maximum available memory |
| web.resources.limits.cpu | string | `"4000m"` | the required CPU for the web workload (must be >= 2 vCPUs) |
| web.resources.limits.ephemeral-storage | string | `"2868Mi"` | the ephemeral storage for the web workload |
| web.resources.limits.memory | string | `"16384Mi"` | the required memory for the web workload |
| web.scanfarm.sast.version | string | `"2025.6.2"` | the SAST component version to use |
| web.scanfarm.sca.version | string | `"10.0.0"` | the SCA component version to use for build-less scans (must match scan service's TOOL_DETECT_VERSION environment variable) |
| web.scanfarm.key.validForDays | int | 45 | the duration of the Scan Farm API key |
| web.scanfarm.key.regenSchedule | string | `"0 0 1 * *"` | the Scan Farm API key regeneration period (minute hour day-of-month month day-of-week) |
| web.securityContext.readOnlyRootFilesystem | bool | `true` | whether the SRM web workload uses a read-only filesystem |
| web.securityContext.allowPrivilegeEscalation | bool | `false` | whether the SRM web workload supports privilege escalation |
| web.securityContext.capabilities.drop | array | `[ALL]` | capabilities to remove from the SRM web workload |
| web.service.annotations | object | `{}` | the annotations to apply to the SRM web service |
| web.service.port | int | `9090` | the port number of the SRM web service |
| web.service.port_name | string | `http` | the name of the service port (set to 'https' for HTTPS ports, required for AWS ELB configuration) |
| web.service.type | string | `"ClusterIP"` | the service type of the SRM web service |
| web.serviceAccount.annotations | object | `{}` | the annotations to apply to the SRM service account |
| web.serviceAccount.create | bool | `true` | whether to create a service account for the SRM web service |
| web.serviceAccount.name | string | `""` | the name of the service account to use; a name is generated using the fullname template when unset and create is true |
| web.tlsSecret | string | `nil` | the K8s secret name for web component TLS with required fields tls.crt and tls.key Command: kubectl -n srm create secret tls web-tls-secret --cert=path/to/cert-file --key=path/to/key-file |
| web.toSecret | string | `nil` | the K8s secret name containing the API key for the Tool Orchestration tool service with required field to-key.props that contains a HOCON-formatted file with SRM prop tws.api-key File: tws.api-key = """password""" Command: kubectl -n srm create secret generic to-key-secret --from-file to-key.props=./to-key.props |
| web.tolerations | list | `[]` | the pod tolerations for the web component |
| web.webSecret | string | `""` | the K8s secret name containing the administrator password with required field admin-password Command: kubectl -n srm create secret generic srm-web-secret --from-literal admin-password=password |

(Generated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0))

# Uninstall

You can remove Software Risk Manager by running the following commands, replacing release name and Kubernetes namespace as necessary:

```
$ helm -n srm delete srm
$ kubectl delete ns srm
```

>Note: A helm hook may run on uninstall to clean up Tool Orchestration objects. You can bypass the workflow clean-up process by adding the --no-hooks parameter: helm -n srm delete srm --no-hooks

Delete any remaining Persistent Volumes (PV) and any related PV data.

# Troubleshooting

Refer to these sections for troubleshooting guidance.

## Core Feature Troubleshooting

This section includes troubleshooting guidance for the Core feature.

### Table Already Exists

Each boot of the Software Risk Manager web component tests whether database schema updates are required. The initial boot provisions the entire database schema, marking successful provisioning by creating a new `.installation` file in the root AppData directory mounted at `/opt/codedx`. Future boots will skip initial provisioning and test whether schema updates are required.

Software Risk Manager treats a missing `/opt/codedx/.installation` as a scenario where the web database schema does not exist. An attempt to provision a database schema where one already exists will generate an error in the Software Risk Manager log that looks like this:

```
INFO  2023-11-29 19:11:42.006 [main] com.avi.codedx.d.m.b - Creating tables . . .
ERROR 2023-11-29 19:11:42.129 [main] com.codedx.n.ad - Bad SQL Query:
===========
CREATE TABLE `ANALYSES` (
        `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `PROJECT_ID` INT UNSIGNED NOT NULL,
        `PROJECT_VERSION_ID` INT UNSIGNED DEFAULT NULL,
        `USER_ID` INT UNSIGNED NOT NULL,
        `CREATION_TIME` DATETIME NOT NULL,
        `STATE` VARCHAR(8) COLLATE utf8mb4_bin NOT NULL,
        `START_TIME` DATETIME DEFAULT NULL,
        `END_TIME` DATETIME DEFAULT NULL,
        `IS_PENDING_CLEANUP` TINYINT(1) NOT NULL DEFAULT FALSE,
        PRIMARY KEY (`ID`),
        KEY `IDX_ANALYSES__PROJECT_ID` (`PROJECT_ID`)
)
==========
ERROR 2023-11-29 19:11:42.129 [main] com.avi.codedx.d.j.e.gb - Create Statement 1/598 failed:
```CREATE TABLE `ANALYSES` (
        `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `PROJECT_ID` INT UNSIGNED NOT NULL,
        `PROJECT_VERSION_ID` INT UNSIGNED DEFAULT NULL,
        `USER_ID` INT UNSIGNED NOT NULL,
        `CREATION_TIME` DATETIME NOT NULL,
        `STATE` VARCHAR(8) COLLATE utf8mb4_bin NOT NULL,
        `START_TIME` DATETIME DEFAULT NULL,
        `END_TIME` DATETIME DEFAULT NULL,
        `IS_PENDING_CLEANUP` TINYINT(1) NOT NULL DEFAULT FALSE,
        PRIMARY KEY (`ID`),
        KEY `IDX_ANALYSES__PROJECT_ID` (`PROJECT_ID`)
)
...
java.sql.SQLSyntaxErrorException: (conn=25) Table 'analyses' already exists
...
Caused by: java.sql.SQLException: Table 'analyses' already exists
...
ERROR 2023-11-29 19:11:42.134 [main] com.avi.codedx.installer.l - Installation did not succeed due to an unexpected exception:
java.sql.SQLSyntaxErrorException: (conn=25) Table 'analyses' already exists
```

This error typically occurs when Software Risk Manager gets installed following an uninstall. Common causes are inadvertently reusing an existing Persistent Volume with the on-cluster MariaDB database or forgetting to recreate the database catalog in an external database. In both cases, a new web volume is missing the `.installation` file, so the web component attempts to provision a schema where one already exists, generating the table-already-exists message.

The safest way to resolve this issue is to ensure a blank database catalog before attempting a helm deployment (this resolution would not apply to existing deployments with data you do not want to lose). For on-cluster database configurations, refer to the [uninstall instructions](#uninstall) that mention removing related Persistent Volume resources. For external database configurations, drop the database catalog (e.g., `DROP DATABASE srmdb;`) before following Steps 2 and 3 of the [external database pre-work instructions](#external-web-database-pre-work) (you can reuse the same database user).

Alternatively, if you are confident that your database schema was provisioned entirely, you can create the `.installation` file by hand, but you must understand the root cause of your missing `.installation` file. Recreating the file is okay if it got inadvertently deleted; however, other circumstances may require additional intervention. For example, suppose you lost your entire web volume. In that case, you will be missing files related to what's in your database, like analysis inputs and support files required to interpret specific database records. If your troubleshooting ends up auto-generating new passwords, you will need to restore the original admin password (see the [update the admin password](#software-risk-manager-admin-password-reset) instructions). To manually create your `.installation` file, do the following, replacing the namespace and deployment names as required:

```
# exec into the pod
kubectl -n srm exec -c srm -it deployment/srm-web -- bash

# change directory
cd /opt/codedx

# create .installation file
cat << EOF > .installation
installed.on=$(date | sed s/\:/\\\\:/g)
EOF

# restart the replicas
kubectl -n srm scale --replicas=0 deployment/srm-web
kubectl -n srm scale --replicas=1 deployment/srm-web
```

When the web workload reboots, the new `/opt/codedx/.installation` file will cause the web workload to skip initial database provisioning.

### RSA Public Key Unavailable

Using an external database with TLS is recommended. If you are using an unencrypted connection to an external MySQL database with the `caching_sha2_password` default_authentication_plugin, you might see the following error in the Software Risk Manager log:

```
java.sql.SQLException: Could not connect to address=(host=mysql)(port=3306)(type=master) : RSA public key is not available client side (option serverRsaPublicKeyFile not set)
```

You can resolve the above issue by following the [Specify MySQL Server Public Key Path](#specify-mysql-server-public-key-path) instructions.

## Scan Farm Feature Troubleshooting

This section includes troubleshooting guidance for the Scan Farm feature.

### Scan Farm Migration Job Fails

>Note: This section applies to Software Risk Manager versions prior to 2024.9.5.

A misconfiguration could cause a Scan Farm migration job to fail. The job's restartPolicy is "on-failure," so the related container gets removed, making the logs hard to grab from the command line. If you have something collecting generated logs on your cluster, you should be able to troubleshoot from that output. Otherwise, you can edit the Scan Farm chart directly by switching the restartPolicy for the job to Never.

The Scan Farm chart does not include a helm value setting for the job's restart policy, so you have to edit the chart locally like this:

```
$ cd /path/to/git/srm-k8s/chart/charts
$ tar xvf cnc-2024.3.0.tgz
$ vim cnc/templates/cnc-scan-service.yaml # set job's restartPolicy to Never
$ mv cnc-2024.3.0.tgz ~ # move original chart elsewhere
$ helm package cnc # recreate cnc-2024.3.0.tgz
$ rm -r cnc # delete working chart
```

>Note: The above procedure uses the "cnc" dependency chart version 2024.3.0.

Avoid rerunning the `helm dependency update` command until you have inspected the job pod's log and have resolved the problem.

### Scan Service GetAccessToken Fails

The Scan Farm feature may fail if a required key is unexpectedly missing from your deployment. This failure may have occurred if you see scan service log error messages that look like these:

```
{"client-id":"...","job-uuid":"...","level":"error","method":"/scan.ScanService/GetAccessToken","msg":"cannot create JWT: srm api key is empty","organization-id":"...","scan-uuid":"...","service":"scan-jobs-svc","time":"..."}
```
```
{"client-id":"...","job-uuid":"...","level":"error","method":"/scan.ScanService/GetAccessToken","msg":"unable to create token on http://srm-web:9090/srm: code 401, body {\"error\":\"invalid_client\",\"error_description\":\"unknown client\"}","organization-id":"...","scan-uuid":"...","service":"scan-jobs-svc","time":"..."}
```

A CronJob Kubernetes resource periodically regenerates the key upon which the Scan Farm feature depends. You can resolve this issue by manually running the job with the following command (assumes an `srm` namespace and release name):

```
kubectl -n srm create job --from=cronjob/srm-internal-svc-cronjob srm-internal-svc-job-fix
```

Wait for the job to finish, and then remove it by running this command:

```
kubectl -n srm delete job srm-internal-svc-job-fix
```

### Cache Service Startup Fails

When using a secure Redis connection, the Scan Farm Cache Service will fail to start if it references an incorrect or invalid certificate. If you encounter a `Socket is closed` message similar to the example below, verify the validity of the certificate referenced by the service via the REDIS_CACERT environment variable and the Kubernetes Secret resource ending in `-sf-cache-cert-secret`. If the certificate is invalid, replace the file referenced by the `scanFarmRedisServerCert` field in config.json with the current certificate. Then, rerun the Helm Prep Script along with the resulting kubectl commands.

```
{
	"timestamp":"2025-01-01T00:00:00.000",
	"level":"ERROR",
	"thread":"main",
	"logger":"org.springframework.boot.SpringApplication",
	"message":"Application run failed",
	"context":"default",
	"exception":"org.springframework.beans.factory.UnsatisfiedDependencyException: 
	Error creating bean with name 'metadataService' defined in URL [jar:nested:/cache-service-2024.12.7945750-exec.jar/!BOOT-INF/classes/!/com/blackduck/coverity/cache/MetadataService.class]:
	Unsatisfied dependency expressed through constructor parameter 3: Error creating bean with name 'redisMetadataRepository': Invocation of init method failed
	at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:795)
	at org.springframework.beans.factory.support.ConstructorResolver.autowireConstructor(ConstructorResolver.java:237)
	at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.autowireConstructor(AbstractAutowireCapableBeanFactory.java:1355)
	at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBeanInstance(AbstractAutowireCapableBeanFactory.java:1192)
	at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:562)
	at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:522)
	at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:326)
	at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:234)
	at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:324)
	at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:200)
	at org.springframework.beans.factory.support.DefaultListableBeanFactory.preInstantiateSingletons(DefaultListableBeanFactory.java:975)
	at org.springframework.context.support.AbstractApplicationContext.finishBeanFactoryInitialization(AbstractApplicationContext.java:962)
	at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:624)
	at org.springframework.boot.web.servlet.context.ServletWebServerApplicationContext.refresh(ServletWebServerApplicationContext.java:146)
	at org.springframework.boot.SpringApplication.refresh(SpringApplication.java:754)
	at org.springframework.boot.SpringApplication.refreshContext(SpringApplication.java:456)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:334)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:1354)
	at org.springframework.boot.SpringApplication.run(SpringApplication.java:1343)
	at com.blackduck.coverity.cache.CacheApplication.main(CacheApplication.java:119)
	at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at org.springframework.boot.loader.launch.Launcher.launch(Launcher.java:91)
	at org.springframework.boot.loader.launch.Launcher.launch(Launcher.java:53)
	at org.springframework.boot.loader.launch.JarLauncher.main(JarLauncher.java:58)
	Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'redisMetadataRepository': Invocation of init method failed
		at org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor.postProcessBeforeInitialization(InitDestroyAnnotationBeanPostProcessor.java:222)
		at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.applyBeanPostProcessorsBeforeInitialization(AbstractAutowireCapableBeanFactory.java:422)
		at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.initializeBean(AbstractAutowireCapableBeanFactory.java:1778)
		at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.doCreateBean(AbstractAutowireCapableBeanFactory.java:600)
		at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.createBean(AbstractAutowireCapableBeanFactory.java:522)
		at org.springframework.beans.factory.support.AbstractBeanFactory.lambda$doGetBean$0(AbstractBeanFactory.java:326)
		at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.getSingleton(DefaultSingletonBeanRegistry.java:234)
		at org.springframework.beans.factory.support.AbstractBeanFactory.doGetBean(AbstractBeanFactory.java:324)
		at org.springframework.beans.factory.support.AbstractBeanFactory.getBean(AbstractBeanFactory.java:200)
		at org.springframework.beans.factory.config.DependencyDescriptor.resolveCandidate(DependencyDescriptor.java:254)
		at org.springframework.beans.factory.support.DefaultListableBeanFactory.doResolveDependency(DefaultListableBeanFactory.java:1443)
		at org.springframework.beans.factory.support.DefaultListableBeanFactory.resolveDependency(DefaultListableBeanFactory.java:1353)
		at org.springframework.beans.factory.support.ConstructorResolver.resolveAutowiredArgument(ConstructorResolver.java:904)
		at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:782)
		... 24 common frames omitted
	Caused by: org.springframework.data.redis.RedisConnectionFailureException: Cannot get Jedis connection
		at org.springframework.data.redis.connection.jedis.JedisConnectionFactory.fetchJedisConnector(JedisConnectionFactory.java:873)
		at org.springframework.data.redis.connection.jedis.JedisConnectionFactory.getConnection(JedisConnectionFactory.java:835)
		at org.springframework.data.redis.core.RedisConnectionUtils.fetchConnection(RedisConnectionUtils.java:195)
		at org.springframework.data.redis.core.RedisConnectionUtils.doGetConnection(RedisConnectionUtils.java:144)
		at org.springframework.data.redis.core.RedisConnectionUtils.getConnection(RedisConnectionUtils.java:105)
		at org.springframework.data.redis.core.RedisTemplate.execute(RedisTemplate.java:383)
		at org.springframework.data.redis.core.RedisTemplate.execute(RedisTemplate.java:363)
		at org.springframework.data.redis.core.RedisTemplate.execute(RedisTemplate.java:350)
		at com.blackduck.coverity.cache.metadata.RedisMetadataRepository.checkRedisConfiguration(RedisMetadataRepository.java:123)
		at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
		at java.base/java.lang.reflect.Method.invoke(Method.java:580)
		at org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor$LifecycleMethod.invoke(InitDestroyAnnotationBeanPostProcessor.java:457)
		at org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor$LifecycleMetadata.invokeInitMethods(InitDestroyAnnotationBeanPostProcessor.java:401)
		at org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor.postProcessBeforeInitialization(InitDestroyAnnotationBeanPostProcessor.java:219)
		... 37 common frames omitted
	Caused by: redis.clients.jedis.exceptions.JedisConnectionException: Failed to create input/output stream
		at redis.clients.jedis.Connection.connect(Connection.java:211)
		at redis.clients.jedis.Connection.initializeFromClientConfig(Connection.java:393)
		at redis.clients.jedis.Connection.<init>(Connection.java:68)
		at redis.clients.jedis.Jedis.<init>(Jedis.java:220)
		at redis.clients.jedis.JedisFactory.makeObject(JedisFactory.java:170)
		at org.apache.commons.pool2.impl.GenericObjectPool.create(GenericObjectPool.java:566)
		at org.apache.commons.pool2.impl.GenericObjectPool.borrowObject(GenericObjectPool.java:306)
		at org.apache.commons.pool2.impl.GenericObjectPool.borrowObject(GenericObjectPool.java:233)
		at redis.clients.jedis.util.Pool.getResource(Pool.java:38)
		at redis.clients.jedis.JedisPool.getResource(JedisPool.java:378)
		at redis.clients.jedis.JedisPool.getResource(JedisPool.java:17)
		at org.springframework.data.redis.connection.jedis.JedisConnectionFactory.fetchJedisConnector(JedisConnectionFactory.java:863)
		... 50 common frames omitted
	Caused by: java.net.SocketException: Socket is closed
		at java.base/java.net.Socket.getSoTimeout(Socket.java:1414)
		at java.base/sun.security.ssl.BaseSSLSocketImpl.getSoTimeout(BaseSSLSocketImpl.java:433)
		at redis.clients.jedis.Connection.connect(Connection.java:196)
		... 61 common frames omitted"
}
```

# Appendix

Refer to these sections for additional Software Risk Manager documentation.

## Config.json

The Helm Prep Wizard generates a config.json file used as input to the Helm Prep script. This section documents the version-based JSON fields.

>Note: The Helm Prep script ignores parameter for features you are not installing.

Refer to the [lock/unlock scripts](../admin/config) to edit [protected config.json fields](../ps/config.ps1#L66).

![config.json version: 1.10.0](https://img.shields.io/badge/config.json%20version-1.10.0-informational?style=flat-square)

|Parameter|Feature|Description|Example|Since|
|:---|:---|:---|:---|:---|
|namespace|Core|namespace for SRM components|srm|1.0|
|releaseName|Core|name of SRM helm release|srm|1.0|
||||||
|workDir|Core|directory to store script-generated files|~/.k8s-srm|1.0|
||||||
|srmLicenseFile|Core|file path to the SRM web license file||1.0|
|scanFarmSastLicenseFile|Scan Farm|file path to the SRM SAST license file||1.0|
|scanFarmScaLicenseFile|Scan Farm|file path to the SRM SCA license file||1.0|
|scanFarmCombinedLicenseFile|Scan Farm|file path to the SRM SCA/SAST Keygen license file||1.7|
|scanFarmLicenseFormatType|Scan Farm|type of Scan Farm license, either Legacy or CombinedKeygen||1.7|
||||||
|repoUsername|Scan Farm|username for the Black Duck Repo||1.0|
|repoPwd|Scan Farm|password for the Black Duck Repo||1.0|
||||||
|scanFarmDatabaseHost|Scan Farm|hostname of the scan farm PostgreSQL database||1.0|
|scanFarmDatabasePort|Scan Farm|port number of the scan farm PostgreSQL database||1.0|
|scanFarmDatabaseUser|Scan Farm|username for the scan farm PostgreSQL database||1.0|
|scanFarmDatabasePwd|Scan Farm|password for the scan farm PostgreSQL database||1.0|
|scanFarmDatabaseSslMode|Scan Farm|type of SSL config|disable; verify-ca; verify-full|1.0|
|scanFarmDatabaseServerCert|Scan Farm|path to PostgreSQL database certificate||1.0|
|scanFarmScanDatabaseCatalog|Scan Farm|scan svc PostgreSQL catalog name||1.0|
|scanFarmStorageDatabaseCatalog|Scan Farm|storage svc PostgreSQL catalog name||1.0|
||||||
|scanFarmRedisHost|Scan Farm|hostname of the scan farm Redis system||1.0|
|scanFarmRedisPort|Scan Farm|port number of the scan farm Redis system||1.0|
|scanFarmRedisDatabase|Scan Farm|database to use for the scan farm|"1"|1.0|
|scanFarmRedisUseAuth|Scan Farm|whether the scan farm requires authentication|"true"|1.0|
|scanFarmRedisPwd|Scan Farm|optional password for scan farm Redis system||1.0|
|scanFarmRedisSecure|Scan Farm|whether the redis connection is secure|"true"|1.0|
|scanFarmRedisVerifyHostname|Scan Farm|whether the redis hostname is validated|"true"|1.0|
|scanFarmRedisServerCert|Scan Farm|path to Redis server cert||1.0|
||||||
|scanFarmStorageType|Scan Farm|type of scan farm object storage|AwsS3; MinIO; Gcs; Azure|1.0|
|scanFarmStorageBucketName|Scan Farm|object storage bucket/container for storage svc||1.0|
|scanFarmCacheBucketName|Scan Farm|object storage bucket/container for cache svc||1.0|
||||||
|scanFarmS3UseServiceAccountName|Scan Farm S3 Storage|whether to use AWS IRSA|"false"|1.0|
|scanFarmS3AccessKey|Scan Farm S3 Storage|access key to AWS S3-compatible storage||1.0|
|scanFarmS3SecretKey|Scan Farm S3 Storage|secret key to AWS S3-compatible storage||1.0|
|scanFarmS3ServiceAccountName|Scan Farm S3 Storage|service account name for AWS IRSA||1.0|
|scanFarmS3Region|Scan Farm S3 Storage|region for AWS S3-compatible storage|us-east-1|1.0|
||||||
|scanFarmGcsProjectName|Scan Farm GCS Storage|name of the GCP project for GCS storage||1.0|
|scanFarmGcsSvcAccountKey|Scan Farm GCS Storage|name of the GCP service account for GCS storage||1.0|
||||||
|scanFarmAzureStorageAccount|Scan Farm Blob Storage|name of storage account containing Azure blobs|"srmstoragetest"|1.0|
|scanFarmAzureStorageAccountKey|Scan Farm Blob Storage|name of key for access to Azure storage account|"EjZdxX/H"|1.0|
|scanFarmAzureSubscriptionId|Scan Farm Blob Storage|identifier of Azure subscription|"c4dcc882-b83d-47cf-8f9e-234b963736a2"|1.0|
|scanFarmAzureTenantId|Scan Farm Blob Storage|identifier of Microsoft Entra ID tenant|"6315cfb3-02f0-4651-828f-06a3ac065b32"|1.0|
|scanFarmAzureResourceGroup|Scan Farm Blob Storage|resource group containing Azure storage account|"srmresourcegroup"|1.0|
|scanFarmAzureEndpoint|Scan Farm Blob Storage|blob service URL for Azure storage account|https://\<?>.blob.core.windows.net/1.0|
|scanFarmAzureClientId|Scan Farm Blob Storage|client identifier of Microsoft Entra ID app|"9b1f8b8d-db8f-4683-8023-2dd7962b1e96"|1.0|
|scanFarmAzureClientSecret|Scan Farm Blob Storage|client secret for Microsoft Entra ID app|"S.68Q~"|1.0|
||||||
|scanFarmMinIOHostname|Scan Farm MinIO Storage|hostname of MinIO server||1.0|
|scanFarmMinIOPort|Scan Farm MinIO Storage|port of MinIO server||1.0|
|scanFarmMinIORootUsername|Scan Farm MinIO Storage|username/access-key of server account with readwrite access||1.0|
|scanFarmMinIORootPwd|Scan Farm MinIO Storage|password/secret-key of server account with readwrite access||1.0|
|scanFarmMinIOSecure|Scan Farm MinIO Storage|whether the MinIO server connection is secure||1.0|
|scanFarmMinIOVerifyHostname|Scan Farm MinIO Storage|whether to verify the MinIO hostname||1.0|
|scanFarmMinIOServerCert|Scan Farm MinIO Storage|path to MinIO server certificate||1.0|
||||||
|scanFarmStorageHasInClusterUrl|Scan Farm MinIO Storage|whether the storage system has an in-cluster URL||1.0|
|scanFarmStorageInClusterUrl|Scan Farm MinIO Storage|the storage system in-cluster URL||1.0|
|scanFarmStorageIsProxied|Scan Farm|whether the web URL proxies storage|true|1.2|
|scanFarmStorageContextPath|Scan Farm|context path for proxied storage||1.2|
|scanFarmStorageExternalUrl|Scan Farm|off-cluster object storage URL||1.2|
||||||
|useGeneratedPwds|Core|whether to generate specific SRM passwords||1.0|
|mariadbRootPwd|On-Cluster DB|root password for the on-cluster database||1.0|
|mariadbReplicatorPwd|On-Cluster DB|replicator password for the on-cluster database||1.0|
|srmDatabaseUserPwd|On-Cluster DB|srm web user password for the on-cluster database||1.0|
|adminPwd|Core|initial srm web admin password||1.0|
|toolServiceApiKey|Tool Orchestration|tool service API key||1.0|
|minioAdminPwd|Tool Orchestration|password for the workflow MinIO system||1.0|
||||||
|k8sProvider|Core|type of K8s provider||1.0|
|kubeApiTargetPort|Network Policy|port number for K8s API port||1.0|
||||||
|clusterCertificateAuthorityCertPath|TLS|path for the cluster certificate issuer||1.0|
|csrSignerName|TLS|signer name for the cert-manager CSR||1.0|
||||||
|createSCCs|OpenShift|whether to create Security Context Constraints (OpenShift)||1.0|
||||||
|scanFarmType|Scan Farm|type of Scan Farm deployment|None; Sast; Sca; All|1.0|
||||||
|skipDatabase|Core|whether to use the on-cluster database||1.0|
|useTriageAssistant|ML|whether to use the SRM ML feature (deprecated with 1.3)|true|1.0|
|skipScanFarm|Scan Farm|whether to install the SRM scan farm||1.0|
|skipToolOrchestration|Tool Orchestration|whether to install the Tool Orchestration feature||1.0|
|skipMinIO|Tool Orchestration|whether to use MinIO for workflow storage||1.0|
|skipNetworkPolicies|Network Policy|whether to use Network Policies for specific components||1.0|
|skipTls|TLS|whether to use TLS for specific components||1.0|
|componentTlsType|TLS|the type of TLS used between supporting components|None|1.9|
|certManagerIssuerName|TLS|the name of the cert-manager issuer||1.9|
|certManagerIssuerType|TLS|the type of the cert-manager issuer|None|1.9|
||||||
|workflowStorageType|Tool Orchestration|type of workflow storage to use (see WorkflowStorageType enum)|OnCluster|1.4|
|serviceAccountToolService|Tool Orchestration|named service account for tool service||1.4|
|serviceAccountWorkflow|Tool Orchestration|named service account for all tool workflows||1.4|
||||||
|toolServiceReplicas|Tool Orchestration|number of tool service replicas||1.0|
||||||
|dbSlaveReplicaCount|On-Cluster DB|number of on-cluster database replicas||1.0|
||||||
|externalDatabaseHost|External DB|hostname of the external database||1.0|
|externalDatabasePort|External DB|port number of the external database||1.0|
|externalDatabaseName|External DB|name of database catalog for the external database||1.0|
|externalDatabaseAuthType|External DB|type of database auth (Password or RdsIam)||1.8|
|externalDatabaseUser|External DB|username for external database||1.0|
|externalDatabasePwd|External DB|password for accessing external database||1.0|
|externalDatabaseSkipTls|External DB|whether to skip TLS configuration for external database||1.0|
|externalDatabaseTrustCert|External DB|whether to trust the external database certificate||1.0|
|externalDatabaseServerCert|External DB|path to the external database certificate||1.0|
||||||
|externalWorkflowStorageEndpoint|Tool Orchestration|endpoint for external workflow storage||1.0|
|externalWorkflowStorageEndpointSecure|Tool Orchestration|whether workflow storage endpoint is secure||1.0|
|externalWorkflowStorageUsername|Tool Orchestration|username for external workflow storage||1.0|
|externalWorkflowStoragePwd|Tool Orchestration|password for external workflow storage||1.0|
|externalWorkflowStorageBucketName|Tool Orchestration|name of bucket in external workflow storage||1.0|
|externalWorkflowStorageTrustCert|Tool Orchestration|whether to trust workflow storage certificate||1.0|
|externalWorkflowStorageCertChainPath|Tool Orchestration|path to the external workflow storage certificate||1.0|
||||||
|addExtraCertificates|Core|whether to trust extra certificates||1.0|
|extraTrustedCaCertPaths|Core|array of paths to certificates to trust||1.0|
||||||
|webServiceType|Core|type of K8s service for SRM web service||1.0|
|webServicePortNumber|Core|port number for SRM web service||1.0|
|webServiceAnnotations|Core|annotations for SRM web service||1.0|
||||||
|skipIngressEnabled|Ingress|whether to skip SRM ingress||1.0|
|ingressType|Ingress|type of SRM ingress||1.0|
|ingressClassName|Ingress|name of ingress class||1.0|
|ingressAnnotations|Ingress|annotations for SRM ingress||1.0|
|ingressHostname|Ingress|hostname associated with SRM ingress||1.0|
|ingressTlsSecretName|Ingress|name of K8s secret containing ingress TLS configuration||1.0|
|ingressTlsType|Ingress|type of TLS ingress configuration|None; CertManagerIssuer; CertManagerClusterIssuer; ExternalSecret|1.0|
||||||
|routeTlsType|Ingress|type of Route TLS configuration|None; ExternalCertificate|1.10|
|routeTlsKeyPath|Ingress|path to the TLS key for the Route TLS configuration||1.10|
|routeTlsCertificatePath|Ingress|path to the TLS certificate for the Route TLS configuration||1.10|
|routeTlsUseCACertificate|Ingress|whether to use a TLS CA certificate for the Route TLS configuration||1.10|
|routeTlsCACertificatePath|Ingress|path to the TLS CA certificate for the Route TLS configuration||1.10|
|routeHostname|Ingress|hostname associated with SRM Route||1.10|
||||||
|useSaml|SAML|whether to use SAML||1.0|
|useLdap|LDAP|whether to use LDAP||1.0|
|samlHostBasePath|SAML|base HTTP path for SRM web|https://\<?>/srm|1.0|
|samlIdentityProviderMetadataPath|SAML|path to the SAML IdP||1.0|
|samlAppName|SAML|name of SAML app/entity||1.0|
|samlKeystorePwd|SAML|password to protect SAML-related Java keystore||1.0|
|samlPrivateKeyPwd|SAML|password to protect SAML-related Java keystore key||1.0|
||||||
|skipDockerRegistryCredential|Core (Required w/ Scan Farm)|whether to create K8s Image Pull Secret||1.0|
|dockerImagePullSecretName|Core (Required w/ Scan Farm)|name of K8s Image Pull Secret||1.0|
|dockerRegistry|Core (Required w/ Scan Farm)|name of Docker registry|gcr.io|1.0|
|dockerRegistryUser|Core (Required w/ Scan Farm)|username to access Docker registry||1.0|
|dockerRegistryPwd|Core (Required w/ Scan Farm)|password to access Docker registry||1.0|
||||||
|useDefaultDockerImages|Core|whether to use default Docker image versions||1.0|
|imageVersionWeb|Core|SRM web Docker image version||1.0|
|imageVersionMariaDB|Core|On-Cluster MariaDB Docker image version||1.0|
|imageVersionTo|Core|Tool Orchestration Docker image version||1.0|
|imageVersionMinio|Core|MinIO Docker image version||1.0|
|imageVersionWorkflow|Core|Argo workflow Docker image version||1.0|
||||||
|useDockerRedirection|Core (Required w/ Scan Farm)|whether to use private Docker registry|"true"|1.0|
|useDockerRepositoryPrefix|Core|whether to include a private Docker registry prefix|"true"|1.0|
|dockerRepositoryPrefix|Core|prefix for Docker registry|"my-srm"|1.0|
||||||
|useDefaultCACerts|Core|whether to use default cacerts file||1.0|
|caCertsFilePath|Core|path to custom Java cacerts file||1.0|
|caCertsFilePwd|Core|password to access custom Java cacerts file||1.0|
||||||
|useCPUDefaults|Core|whether to use default CPU reservations||1.0|
|webCPUReservation|Core|reservation for SRM Web CPU||1.0|
|dbMasterCPUReservation|On-Cluster DB|reservation for On-Cluster primary database CPU||1.0|
|dbSlaveCPUReservation|On-Cluster DB|reservation for On-Cluster secondary database CPU||1.0|
|toolServiceCPUReservation|Tool Orchestration|reservation for Tool Service CPU||1.0|
|minioCPUReservation|Tool Orchestration|reservation for MinIO CPU||1.0|
|workflowCPUReservation|Tool Orchestration|reservation for Argo workflow CPU||1.0|
||||||
|useMemoryDefaults|Core|whether to use default memory reservations||1.0|
|webMemoryReservation|Core|reservation for SRM Web memory||1.0|
|dbMasterMemoryReservation|On-Cluster DB|reservation for On-Cluster primary database memory||1.0|
|dbSlaveMemoryReservation|On-Cluster DB|reservation for On-Cluster secondary database memory||1.0|
|toolServiceMemoryReservation|Tool Orchestration|reservation for Tool Service memory||1.0|
|minioMemoryReservation|Tool Orchestration|reservation for MinIO memory||1.0|
|workflowMemoryReservation|Tool Orchestration|reservation for Argo workflow memory||1.0|
||||||
|useEphemeralStorageDefaults|Core|whether to use default ephemeral storage reservations||1.0|
|webEphemeralStorageReservation|Core|reservation for SRM Web ephemeral storage||1.0|
|dbMasterEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster primary database ephemeral storage||1.0|
|dbSlaveEphemeralStorageReservation|On-Cluster DB|reservation for On-Cluster secondary database ephemeral storage||1.0|
|toolServiceEphemeralStorageReservation|Tool Orchestration|reservation for Tool Service ephemeral storage||1.0|
|minioEphemeralStorageReservation|Tool Orchestration|reservation for MinIO ephemeral storage||1.0|
|workflowEphemeralStorageReservation|Tool Orchestration|reservation for Argo workflow ephemeral storage||1.0|
||||||
|useVolumeSizeDefaults|Core|whether to use default Volume sizes||1.0|
|webVolumeSizeGiB|Core|size of SRM Web volume||1.0|
|dbVolumeSizeGiB|On-Cluster DB|size of On-Cluster primary database volume||1.0|
|dbSlaveVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica database volume||1.0|
|dbSlaveBackupVolumeSizeGiB|On-Cluster DB|size of On-Cluster replica backup database volume||1.0|
|minioVolumeSizeGiB|Tool Orchestration|size of MinIO volume||1.0|
|storageClassName|Tool Orchestration|name of storage class for all volumes||1.0|
||||||
|systemSize|Core & Tool Orchestration|size of Core/Tool Orchestration components (see SystemSize enum)|Unspecified|1.3|
||||||
|useNodeSelectors|Core|whether to use node selectors||1.0|
|webNodeSelector|Core|node selector for SRM Web||1.0|
|masterDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster primary database||1.0|
|subordinateDatabaseNodeSelector|On-Cluster DB|node selector for On-Cluster replica database||1.0|
|toolServiceNodeSelector|Tool Orchestration|node selector for Tool Service||1.0|
|minioNodeSelector|Tool Orchestration|node selector for MinIO||1.0|
|workflowControllerNodeSelector|Tool Orchestration|node selector for Argo workflow controller||1.0|
|toolNodeSelector|Tool Orchestration|node selector for Tool Orchestration tools||1.0|
||||||
|useTolerations|Core|whether to use pod tolerations||1.0|
|webNoScheduleExecuteToleration|Core|pod toleration for SRM Web||1.0|
|masterDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster primary database||1.0|
|subordinateDatabaseNoScheduleExecuteToleration|On-Cluster DB|pod toleration for On-Cluster replica database||1.0|
|toolServiceNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Service||1.0|
|minioNoScheduleExecuteToleration|Tool Orchestration|pod toleration for MinIO||1.0|
|workflowControllerNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Argo workflow controller||1.0|
|toolNoScheduleExecuteToleration|Tool Orchestration|pod toleration for Tool Orchestration tools||1.0|
||||||
|authCookieSecure|Core|whether to set the Secure attribute on the authentication cookie|false|1.5|
||||||
|notes|Core|notes associated with deployment||1.0|
||||||
|skipWebServiceAccountCreate|Core|whether to skip web service account creation for web workload||1.8|
|webServiceAccountName|Core|service account name for web workload||1.8|
||||||
|scanFarmScaApiUrlOverride|Core (Dev/Test Only)|override for SCA scan farm endpoint||1.0|
||||||
|configVersion|Config|config.json file format version||1.1|
|isLocked|Config|whether some config.json field values are encrypted||1.1|
|salts|Config|salts used to encrypt specific config.json field values||1.1|

## Helm Chart Notes

This section describes important considerations when moving from one SRM Helm chart version to another. If you deployed with the [Full Installation Instructions](#installation---full) instructions, rerunning the Helm Prep Script with your config.json and following the generated instructions will simplify the upgrade process. If you deployed with the [Quick Start Installation Instructions](#installation---quick-start), use the sections below to guide your update.

### Upgrading to v1.22 - v1.25

These chart versions depend on an updated Scan Farm chart with a list of Docker images that differ from the previous version.

- Scan Farm users should note the [changes to the list of Docker images](https://github.com/codedx/srm-k8s/commit/40de24a7ebb1cc96a8eb0f0660b652ae00c8c523#diff-af237e092dd7904bc46102ce0fd5f2986aacb50543ef5a558db6df195fe119b6) you must copy to your private registry.

### Upgrading to v1.26

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This chart version switches the Tool Orchestration feature's Argo dependency from v2 to v3. 

>Note: The Helm Prep Script will handle Argo-related chart configuration adjustments. If you previously deployed using the script, rerun the latest script version and follow its instructions.

- The Argo chart dependency is named `argo-workflow` instead of `argo`, and the related repository is `https://argoproj.github.io/argo-helm` instead of `https://codedx.github.io/codedx-kubernetes`. Any chart customizations referring to `argo` should instead refer to `argo-workflows`. Run the following commands to drop the `argo` repository and add the `argo-workflow` one:

```
helm repo remove argo
helm repo add argo-workflows https://argoproj.github.io/argo-helm --force-update
```

>Note: Visit the [argo-workflows](https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows) site to ensure any custom overrides you may have added are valid for Argo v3.

- Argo v3 uses newer versions of the Argo Custom Resource Definitions (CRDs); run `kubectl apply` on the latest [CRD files](https://github.com/codedx/srm-k8s/tree/main/crds/v1) to update your Argo v2 CRD definitions. Run the following command to update your Argo CRDs:

```
kubectl apply -f /path/to/git/srm-k8s/crds/v1
```

- The Argo v3 chart creates a workflow ServiceAccount resource in a namespace specified using the `argo-workflows.controller.workflowNamespaces` array Helm value.

```
argo-workflows:
  controller:
    workflowNamespaces
    - srm
```

- Tool Orchestration deployments with TLS support provided by cert-manager require an extra [TLS Pre-work](#tls-pre-work) step. The extra CA Kubernetes Secret, which has the same name as the currently required Kubernetes ConfigMap, is necessary for workflows to access object storage when the storage is protected by a cert that was not issued by a well-known CA. Run the following command after updating the variable values for your deployment:

```
kubectl -n $SRM_NAMESPACE create secret generic $CA_CONFIGMAP_NAME --from-file ca.crt=ca.crt
```

- Add-in TOML files now support a `request.volume` subtable with the following fields:

```
[request.volume]
mountPoint = "/opt/data"
storageCapacity = "2Gi"
storageClassName = "name"
```

>Note: For backward compatibility, the DataDirectory, DataDirectoryStorageCapacity, and DataDirectoryStorageClassName fields of the request table are still supported.

- Add-in TOML files now supports a `request.podsecuritycontext` subtable with the following fields:

```
[request.podsecuritycontext]
runAsUser = 1000
runAsGroup = 1000
fsGroup = 1000
```

>Note: For backward compatibility, the DataDirectoryFileSystemGroup field of the request table is still supported.

### Upgrading to v1.28

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This chart version replaces the `codedx/codedx-argoexec` and `codedx/codedx-workflow-controller` Docker images with `argoproj/argoexec` and `argoproj/workflow-controller`.

### Upgrading to v1.40

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This chart version uses a different subchart for the Scan Farm feature, switching from chart `cnc` (version 2024.3.0) to the `scan-services` chart (version 2024.9.1). The Helm Prep Script for this version will switch your helm config from one chart to the other, but if you previously customized your Scan Farm configuration via your `srm-extra-props.yaml` file, refer to the [Scan Farm Job Resources](#scan-farm-job-resources) and [Specify Scan Farm Engine Versions](#specify-scan-farm-engine-versions) sections to update your customizations.

This chart also switches the Scan Farm SAST component from version 2024.3.0 to 2024.9.1. Refer to [Specify Scan Farm Engine Versions](#specify-scan-farm-engine-versions) if you'd prefer to use a previous SAST version that SRM supports.

This version of Software Risk Manager works with the new Black Duck Repo (34.149.5.115) where Scan Farm feature users must download Docker images with the following updated names:

| Previous Docker Image Name | New Docker Image Name |
|:-|:-|
|sig-repo.synopsys.com/synopsys/codedx/codedx-tomcat:v2024.9.4.1|repo.blackduck.com/containers/codedx/codedx-tomcat:v2024.9.4.1|
|sig-repo.synopsys.com/synopsys/codedx/codedx-tools:v2024.9.4.1|repo.blackduck.com/containers/codedx/codedx-tools:v2024.9.4.1|
|sig-repo.synopsys.com/synopsys/codedx/codedx-prepare:v2.4.0|repo.blackduck.com/containers/codedx/codedx-prepare:v2.4.0|
|sig-repo.synopsys.com/synopsys/codedx/codedx-newanalysis:v2.4.0|repo.blackduck.com/containers/codedx/codedx-newanalysis:v2.4.0|
|sig-repo.synopsys.com/synopsys/codedx/codedx-results:v2.4.0|repo.blackduck.com/containers/codedx/codedx-results:v2.4.0|
|sig-repo.synopsys.com/synopsys/codedx/codedx-tool-service:v2.4.0|repo.blackduck.com/containers/codedx/codedx-tool-service:v2.4.0|
|sig-repo.synopsys.com/synopsys/codedx/codedx-cleanup:v2.4.0|repo.blackduck.com/containers/codedx/codedx-cleanup:v2.4.0|
|sig-repo.synopsys.com/synopsys/codedx/codedx-mariadb:v1.35.0|repo.blackduck.com/containers/codedx/codedx-mariadb:v1.35.0|
|sig-repo.synopsys.com/synopsys/bitnami/minio:2024.11.7-debian-12-r2|repo.blackduck.com/containers/bitnami/minio:2024.11.7-debian-12-r2|
|sig-repo.synopsys.com/synopsys/argoproj/workflow-controller:v3.5.11|repo.blackduck.com/containers/argoproj/workflow-controller:v3.5.11|
|sig-repo.synopsys.com/synopsys/argoproj/argoexec:v3.5.11|repo.blackduck.com/containers/argoproj/argoexec:v3.5.11|
|sig-repo.synopsys.com/synopsys/cnc-cache-service:2024.9.1|repo.blackduck.com/containers/cache-service:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-common-infra:2024.9.1|repo.blackduck.com/containers/common-infra:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-scan-service:2024.9.1|repo.blackduck.com/containers/scan-service:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-scan-service-migration:2024.9.1|repo.blackduck.com/containers/scan-service-migration:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-storage-service:2024.9.1|repo.blackduck.com/containers/storage-service:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-storage-service-migration:2024.9.1|repo.blackduck.com/containers/storage-service-migration:2024.9.1|
|sig-repo.synopsys.com/synopsys/cnc-job-runner:2024.9.1|repo.blackduck.com/containers/job-runner:2024.9.1|

The srm-k8s GitHub repository for this version of Software Risk Manager depends on an updated Guided Setup module with version 1.17.0. Scripts requiring the Guided Setup module will download it automatically; to manually download the module, refer to the instructions in [.install-guided-setup-module.ps1](../.install-guided-setup-module.ps1#L12).

### Upgrading to v1.42

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This version of Software Risk Manager is hosted in a new GitHub location and uses a new chart repository. Refer to the [README](https://github.com/codedx/srm-k8s/tree/main?tab=readme-ov-file#new-repository-location) file for more details.

### Upgrading to v1.43

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This version of Software Risk Manager updates the default pod and container security contexts. It also references a newer version of the optional Bitnami MinIO component for deployments that do not use external workflow storage. 

If you are using MinIO, this version will create a new MinIO volume that will not include your previous workflow storage. To retain your current workflow storage, edit your MinIO PV by switching the `persistentVolumeReclaimPolicy` field value from `Delete` to `Retain` before deploying this version.

### Upgrading to v1.46

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

The srm-k8s GitHub repository for this version of Software Risk Manager depends on an updated Guided Setup module with version 1.18.0. Scripts requiring the Guided Setup module will download it automatically; to manually download the module, refer to the instructions in [.install-guided-setup-module.ps1](../.install-guided-setup-module.ps1#L12).

### Upgrading to v1.49

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This chart switches the Scan Farm SAST component from version 2024.9.1 to 2024.12.0 and the Scan Farm SCA version from 9.2.0 to 10.0.0. Refer to [Specify Scan Farm Engine Versions](#specify-scan-farm-engine-versions) if you'd prefer to use a previous SAST version that SRM supports.

### Upgrading to v1.64

If you are upgrading from an earlier chart version, refer to any previous chart note(s) in addition to this one.

This chart switches the Scan Farm SAST component from version 2024.12.0 to 2025.6.2. Refer to [Specify Scan Farm Engine Versions](#specify-scan-farm-engine-versions) if you'd prefer to use a previous SAST version that SRM supports.

## All-in-One Demo Config

Refer to the [Quick Start installation sections](#installation---quick-start) if you want to quickly spin up a demo environment for the [Core](#core-feature) and [Tool Orchestration](#tool-orchestration-feature) features.

The [Scan Farm](#scan-farm-feature) feature does not include a Quick Start, but this section shows how you can use [kind](https://kind.sigs.k8s.io/) and [Docker Desktop](https://www.docker.com/products/docker-desktop/) to configure a single environment with the [Core](#core-feature), [Tool Orchestration](#tool-orchestration-feature), and [Scan Farm](#scan-farm-feature) features. The environment uses TLS termination with an Ingress-NGINX ingress controller and a self-signed certificate using the DNS name host.docker.internal (managed by Docker Desktop).

The configuration depends on having the following resources available for SRM components, with Scan Farm and Tool Orchestration pods not necessarily needing to run simultaneously. Additional resources may be required for other related cluster workloads.

| Components | CPU (m) | Memory (G) |
|:-|:-:|:-:|
| Core, Tool Orchestration, and Scan Farm pods | 5000 | 11.5 |
| Scan Farm analysis | 1500 | 3.5 |
| Tool Orchestration analysis | 2000 | 2 |

The commands in the sections that follow require a PowerShell session.

### Install and Configure Tools

1. Install [kind](https://kind.sigs.k8s.io/)

2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)

3. Open Docker Desktop settings and uncheck `Use containerd for pulling and storing images`

4. Install openssl

5. Install git

### Create a Certificate

1. Create a private key for host.docker.internal

```
openssl genrsa -out host.docker.internal.key 2048
```

2. Save a certificate request config file

```
@'
[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
distinguished_name = req_dn
req_extensions = req_ext

[ req_dn ]
CN = host.docker.internal

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = host.docker.internal
'@ | Out-File host.docker.internal.cnf
```

3. Generate a certificate signing request

```
openssl req -new -key host.docker.internal.key -out host.docker.internal.csr -config host.docker.internal.cnf
```

4. Create the certificate

```
openssl x509 -req -in host.docker.internal.csr -signkey host.docker.internal.key -out host.docker.internal.crt -extfile host.docker.internal.cnf -extensions req_ext
```

5. Trust host.docker.internal.crt on your host

6. Restart Docker Desktop

### Create a Local Private Registry

1. Change to a directory from which you will run the private registry and store both configuration files and container image files

2. Copy your host.docker.internal.crt and host.docker.internal.key files to your directory

2. Save a registry config file

```
@'
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
  tls:
    certificate: /tls/registry.crt
    key: /tls/registry.key
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
'@ | Out-File config.yml
```

3. Save a registry Docker Compose file

```
@'
services:
  registry:
    container_name: registry
    image: registry:2
    ports:
    - "5000:5000"
    environment:
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
      REGISTRY_AUTH_HTPASSWD_REALM: basic_realm
      REGISTRY_AUTH_HTPASSWD_PATH: /data/htpasswd
      REGISTRY_HTTP_TLS_CERTIFICATE: /tls/registry.crt
      REGISTRY_HTTP_TLS_KEY: /tls/registry.key
    restart: always
    volumes:
      - ./data:/data
      - ./host.docker.internal.crt:/tls/registry.crt
      - ./host.docker.internal.key:/tls/registry.key
      - ./config.yml:/etc/docker/registry/config.yml
'@ | Out-File registry-docker-compose.yml
```

4. Start your registry

```
docker-compose -p registry -f ./registry-docker-compose.yml up -d
```

5. Create a registry username and password

```
docker exec -it registry apk add apache2-utils
docker exec -it registry htpasswd -cB /data/htpasswd reguser # specify password when prompted
```

6. Restart your registry

```
docker-compose -p registry -f .\registry-docker-compose.yml down
docker-compose -p registry -f .\registry-docker-compose.yml up -d
```

7. Log on to your registry using username `reguser` and the password you specified

```
docker login host.docker.internal:5000
```

### Clone Repo

1. Run the following git command to clone the srm-k8s repo

```
git clone https://github.com/codedx/srm-k8s
```

### Load Container Images

1. Run the [registry.ps1](./deploy/registry.ps1) script to load your private container registry with Black Duck Repo container images

```
pwsh /path/to/git/srm-k8s/docs/deploy/registry.ps1 'host.docker.internal:5000/'
```

### Create a Cluster

1. Save a kind cluster config file

```
@'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraPortMappings:
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
'@ | Out-File cluster.config
```

2. Create a cluster

```
kind create cluster --name srm --config .\cluster.config
```

3. Label the worker node with the HTTPS port mapping

```
kubectl label --overwrite node srm-worker has-https-port-mapping=true
```

4. Configure a custom scan farm node pool

```
kubectl label --overwrite node srm-worker2 pool-type=custom
kubectl taint node srm-worker2 NodeType=ScannerNode:NoSchedule
```

5. Connect your registry to cluster nodes

```
docker network connect kind registry
```

6. Trust host.docker.internal.crt on each cluster node

```
docker ps --filter "name=^srm" -q | ForEach-Object { docker cp .\host.docker.internal.crt $_`:/usr/local/share/ca-certificates; docker exec $_ update-ca-certificates }
```

7. Restart Docker Desktop

### Install Ingress-Nginx

1. Deploy the ingress controller

```
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

2. Patch the ingress controller deployment

```
kubectl -n ingress-nginx patch deployment ingress-nginx-controller --patch '{"spec":{"template":{"spec":{"nodeSelector":{"has-https-port-mapping":"true"}}}}}'
```

3. Wait on the ingress controller

```
kubectl -n ingress-nginx wait --for=condition=ready pod --selector=app.kubernetes.io/component=controller
```

### Deploy Scan Farm Dependencies

1. If you have not already done so, clone the srm-k8s repo

```
git clone https://github.com/codedx/srm-k8s
```

2. Deploy the scan farm dependencies, replacing the path placeholder

```
helm dependency update /path/to/srm-k8s/docs/scanfarmdeps
helm -n srm install --create-namespace srmdeps /path/to/srm-k8s/docs/scanfarmdeps
```

3. Refer to the chart notes for inputs you will provide to the Helm Prep Wizard

>Note: You can run `helm -n srm get notes srmdeps` to fetch the scanfarmdeps chart notes

4. Establish your object storage proxy ingress

```
@'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 500m
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: minio
  namespace: srm
spec:
  ingressClassName: nginx
  rules:
  - host: host.docker.internal
    http:
      paths:
      - backend:
          service:
            name: srmdeps-minio
            port:
              number: 9000
        path: /upload/(.*)
        pathType: ImplementationSpecific
'@ | kubectl -n srm apply -f -
```

### Deploy SRM

1. Create an ingress-tls Kubernetes secret resource for use with your ingress

```
kubectl -n srm create secret tls ingress-tls --cert=host.docker.internal.crt --key=host.docker.internal.key
```

2. Start the Helm Prep Wizard

```
pwsh /path/to/srm-k8s/helm-prep-wizard.ps1
```

3. Use the following responses to proceed through the wizard

| Screen | Prompt | Response | Comment |
|:-|:-|:-|:-|
|Welcome|Press Enter to continue...|Enter||
|About|Do you want to continue?|y||
|Deployment Size|What is your deployment size?|u||
|SRM License|Enter the path to your SRM license file:|/path/to/srm-license||
|Work Directory|Enter a directory or press Enter to accept the default:|Enter|accept default directory|
|Kubernetes Environment|Where are you deploying SRM?|o||
|SRM Namespace|Enter SRM namespace name (e.g., srm):|srm||
|SRM Helm Release Name|Enter SRM Helm release name (e.g., srm):|srm||
|External Database|Do you want to host your SRM database on an external database server that you provide?|n||
|Database Replicas|Enter the number of database replicas:|0||
|Scan Farm|Install Scan Farm Components?|y||
|Black Duck Docker Repo Username|Enter your Black Duck Docker Repo username:||specify your username from BD Community|
|Black Duck Docker Repo Password|Enter your Black Duck Docker Repo password:||specify your password from BD Community|
|Scan Farm Type|What type of Scan Farm license do you have?|o||
|Scan Farm SAST License|Enter the path to your Scan Farm SAST license file:||specify the path to your SAST license|
|Scan Farm SCA License|Enter the path to your Scan Farm SCA license file:||specify the path to your SCA license|
|Scan Farm PostgreSQL Host|Enter the name of your PostgreSQL database host:||see "PostgreSQL Service" srmdeps chart note|
|Scan Farm PostgreSQL Port|Enter your PostgreSQL port or press Enter to accept the default (5432):|5432||
|Scan Farm PostgreSQL Username|Enter the username for your PostgreSQL database:||see "PostgreSQL Username" srmdeps chart note|
|Scan Farm PostgreSQL Password|Enter the password of your PostgreSQL database user:||see "PostgreSQL Password" srmdeps chart note|
|Scan Farm PostgreSQL TLS|Specify the SSL/TLS mode for your PostgreSQL database connection|d||
|Scan Service PostgreSQL Catalog|Enter the name of your Scan Service database catalog:|scan-svc||
|Storage Service Database Catalog|Enter the name of your Storage Service database catalog:|storage-svc||
|Scan Farm Redis Requirements|Do you want to continue?|y||
|Scan Farm Redis Host|Enter the name of your external Redis host:||see "Redis Service" srmdeps chart note|
|Scan Farm Redis Port|Enter your Redis port number or press Enter to accept the default (6379):|6379||
|Scan Farm Redis Database|Enter your Redis logical database index:|1||
|Scan Farm Redis Auth|Do you want to enable authentication?|y||
|Scan Farm Redis Password|Enter the Redis password:||see "Redis Password" srmdeps chart note|
|Scan Farm Redis TLS|Specify the SSL/TLS mode for your Redis connection|d||
|Scan Farm Storage|Specify the type of Scan Farm storage you plan to use|m||
|Storage Service Bucket Name|Enter the name of your *existing* storage service bucket:|storage|see "MinIO Buckets" srmdeps chart note|
|Cache Service Bucket Name|Enter the name of your *existing* cache service bucket:|cache|see "MinIO Buckets" srmdeps chart note|
|Scan Farm Object Storage Hostname|Enter your storage hostname:||see "MinIO Service" srmdeps chart note|
|Scan Farm Object Storage Port|Enter your storage port:|9000||
|Scan Farm Object Storage Access Key|Enter your storage access key:||see "MinIO Username" srmdeps chart note|
|Scan Farm Object Storage Secret Key|Enter your storage secret key:||see "MinIO Password" srmdeps chart note|
|Scan Farm Object Storage Proxy|Do you plan to proxy your storage using your SRM hostname?|y||
|Scan Farm Proxy Context Path|Enter your proxy context path:|upload||
|Scan Farm In-Cluster Storage|Do you want to specify an in-cluster storage URL?|y||
|Scan Farm In-Cluster Storage Url|Enter the in-cluster URL for your storage service:||see "MinIO URL" srmdeps chart note|
|Scan Farm Object Storage TLS|Specify the SSL/TLS mode for your storage connection|d||
|Docker Registry|Enter your private Docker registry host:|host.docker.internal:5000||
|Docker Registry Credential|Do you want to specify a Docker registry credential?|y||
|Docker Image Pull Secret|Enter a name for your Docker Image Pull Secret:|reg||
|Docker Registry Username|Enter your private Docker registry username:|reguser||
|Docker Registry Password|Enter your private Docker registry password:||your private registry password|
|Tool Orchestration|Install Tool Orchestration Components?|y||
|Orchestrated Analysis Storage|What object storage configuration will you use?|m||
|Configure TLS|Specify your TLS configuration for SRM components|n||
|Network Policies|Install Network Policies|n||
|Authentication Type|How will users authenticate to SRM?|l||
|Ingress Type|What type of ingress do you want to use?|i||
|Ingress Class Name|Enter ingress class name:|nginx||
|Ingress TLS|How will you secure your ingress?|x||
|Ingress TLS Secret Name|Enter the name of your existing Kubernetes TLS Secret name:|ingress-tls||
|SRM DNS Name|Enter DNS name:|host.docker.internal||
|Default Java cacerts|Do you want to use the default cacerts file?|y||
|Auto-Generated Passwords|Do you want to use auto-generated passwords and keys?|y||
|SRM Docker Repository Prefix|Do you need to specify a repository prefix?|n||
|SRM Docker Images|Do you want to specify alternate Docker image versions?|n||
|CPU Reservations|Make CPU reservations?|c||
|SRM Web CPU Reservation|Enter CPU reservation in millicpus/millicores (e.g., 1000m)|2000m||
|Master Database CPU Reservation|Enter CPU reservation in millicpus/millicores (e.g., 1000m):|1000m||
|Tool Service CPU Reservation|Enter CPU reservation in millicpus/millicores (e.g., 1000m):|500m||
|MinIO CPU Reservation|Enter CPU reservation in millicpus/millicores (e.g., 1000m):|500m||
|Workflow Controller CPU Reservation|Enter CPU reservation in millicpus/millicores (e.g., 1000m):|250m||
|Memory Reservations|Make memory reservations?|c||
|SRM Web Memory Reservation|Enter memory reservation in mebibytes (e.g., 500Mi):|8192Mi||
|Master Database Memory Reservation|Enter memory reservation in mebibytes (e.g., 500Mi):|1024Mi||
|Tool Service Memory Reservation|Enter memory reservation in mebibytes (e.g., 500Mi):|1024Mi||
|MinIO Memory Reservation|Enter memory reservation in mebibytes (e.g., 500Mi):|1024Mi||
|Workflow Controller Memory Reservation|Enter memory reservation in mebibytes (e.g., 500Mi):|500Mi||
|Ephemeral Storage Reservations|Use default ephemeral storage reservations?|u||
|Volume Sizes|Use default volume sizes?|y||
|Storage Class Name|Enter storage provider:|Enter|accept default|
|Node Selectors|Do you want to specify node selectors?|n||
|Pod Tolerations|Do you want to specify pod tolerations?|n||
|Lock Config JSON|Enter your config.json password:||enter password|
|Finish|Are you ready to generate your run-helm-prep.ps1 script?|s||

4. Create an srm-extra-props.yaml file

```
@'
scan-services:
  scan-service:
    environment:
      BLACKDUCKSCAN_LABEL: "custom"
      BLACKDUCKBDIO_LABEL: "custom"
      BLACKDUCKSCAN_CPU: 1500
      BLACKDUCKSCAN_MEM: 3500
      BLACKDUCKBDIO_CPU: 1500
      BLACKDUCKBDIO_MEM: 3500
      COVCAPTURE_DEFAULTPOOLTYPE: "custom"
      COVANALYSIS_DEFAULTPOOLTYPE: "custom"
      CUSTOMNODEPOOL_LABEL: "custom"
      CUSTOMNODEPOOL_CPU: 1500
      CUSTOMNODEPOOL_MEM: 3500
'@ | Out-File ~/.k8s-srm/srm-extra-props.yaml
```

5. Run the Helm Prep Script

```
pwsh /path/to/.k8s-srm/run-helm-prep.ps1
```

6. Follow the instructions printed by the Helm Prep Script

7. Open the scan-service pod and wait for the tool download process to finish

>Note: Restart the scan-service pod to resolve errors downloading tool files

8. Log on to Software Risk Manager by visiting https://host.docker.internal, refer to the SRM chart notes for the admin password

>Note: You can run `helm -n srm get notes srm` to fetch the srm chart notes

## Software Risk Manager Wizards

This section shows every step of each Software Risk Manager wizard.

### Helm Prep Wizard

The Helm Prep Wizard helps you specify your desired Software Risk Manager deployment configuration by generating a config.json file that you can use with
the Helm Prep script to stage your helm deployment. 

Below is a graph showing every Helm Prep Wizard step. You only have to visit the steps that apply to your SRM deployment.

![Helm Prep Wizard Steps](./images/helm-prep-wizard-graph.png)

### Add Certificates Wizard

The Add Certificates Wizard allows your Software Risk Manager web instance to trust additional certificates that are not trusted by default.

Below is a graph showing every Add Certificates Wizard step.

![Add Certificates Steps](./images/add-trust-certificates-wizard.png)

### Add SAML Authentication Wizard

The Add SAML Authentication Wizard allows you to configure SAML authentication for Software Risk Manager users.

Below is a graph showing every Add SAML Authentication Wizard step. You only have to visit the steps that apply to your SRM deployment.

![Add SAML Authentication Steps](./images/add-saml-auth-wizard-graph.png)

### Scan Farm Wizard

The Add Scan Farm Wizard allows you to include the Software Risk Manager Scan Farm feature in your deployment.

Below is a graph showing every Add Scan Farm Wizard step. You only have to visit the steps that apply to your SRM deployment.

![Add Scan Farm Steps](./images/add-scan-farm-wizard-graph.png)

### Set Passwords Wizard

The Set Passwords Wizard allows you to reset passwords and keys for Software Risk Manager Core and Tool Orchestration feature components.

Below is a graph showing every Set Passwords Wizard step. You only have to visit the steps that apply to your SRM deployment.

![Set Passwords Steps](./images/set-passwords-wizard-graph.png)
