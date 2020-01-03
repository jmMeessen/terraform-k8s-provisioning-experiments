# Provisioning with Terraform

Automated creation of environments for demos, testing and research with Terraform.

## Local requirements

* Terraform 0.12+ (or Docker, see [Local build with CI environments](#local-build-with-ci-environments))
* Bash
* The Google Cloud CLI, `gcloud`. See [Installing Google Cloud SDK](https://cloud.google.com/sdk/install) for details.
    * the component `beta` is needed. You can install it with `gcloud component install beta`. To list the installed components, run `gcloud components install beta`.
* GOOGLE_APPLICATION_CREDENTIALS environment variable pointing to a [Google service account credentials file](https://cloud.google.com/docs/authentication/getting-started) with access to the ps-dev-201405 project.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Bats-core](https://github.com/bats-core/bats-core#installation) for test

Make is optional, but extremely useful.

## Getting Started

```
$ export GOOGLE_APPLICATION_CREDENTIALS=~/account.json
$ cd provisioning/terraform

$ ls examples
gke-simple-cluster

$ make apply-gke-simple-cluster
Using WORKSPACE matthewhicks-7c0aqt
Initializing the backend...

Terraform has been successfully initialized! 
...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

$ make destroy-gke-simple-cluster
Using WORKSPACE matthewhicks-7c0aqt
...
Destroy complete! Resources: 2 destroyed.

```

## Examples and Modules

The `examples` directory contains "root" terraform (HCL) definitions of environments to build.  The Makefile recognizes the subdirectories of examples as build targets when prefixed with one of the terraform commands, `plan`, `apply`, and `destroy`.

## Simple customization

When using the supplied examples, some variables, like the gcloud region or the zone, can be set by creating a file ending with `.auto.tfvars` or `.auto.tfvars.json`. These file types are excluded from GIT tracking. 

To work, the file, like the one below, must be created in the directory where the Makefile is stored.

Example: `local.auto.tfvars.json`
```
{
    "region" : "europe-west1",
    "zone"   : "europe-west1-b"
}
```

## Shared Terraform State

A GCS bucket named [`ps-dev-tf-state`](https://console.cloud.google.com/storage/browser/ps-dev-tf-state?project=ps-dev-201405) is used for shared Terraform state.  The `.current_workspace` file tracks the workspace in use.  If `.current_workspace` does not exist, `make` will create a new workspace with a (somewhat) meaningful name and a random suffix.

```
$ make init-gke-simple-cluster
Using workspace matthewhicks-IRQJaP
...
Created and switched to workspace "matthewhicks-IRQJaP"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ make plan-gke-simple-cluster
...

$ make workspace-delete
Switched to workspace "default".
Deleted workspace "matthewhicks-IRQJaP"!
```

## Local build with CI environments

The CI build environment can be used locally with a [set of bash functions](make_shell_functions) that alias terraform to run in the same docker images used for CI. 

```
$ source make_shell_scripts

$ type terraform
terraform is a function
terraform () 
{ 
    docker run ...
}

$ terraform init
...
```

The Makefile also ensures the remote backend and shared state configuration are used, so CI environments can be investigated when things break. 
