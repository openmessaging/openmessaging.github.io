---
title: Apache Pulsar benchmarks
---

This tutorial shows you how to run OpenMessaging [benchmarks](..) for [Apache Pulsar](https://pulsar.incubator.apache.org). You can currently deploy to the following platforms:

* [Amazon Web Services](#deploy-a-pulsar-cluster-on-amazon-web-services) (AWS)

## Initial setup

To being, you'll need to clone the [`benchmark`](https://github.com/openmessaging/openmessaging-benchmark) repo from the [`openmessaging`](https://github.com/openmessaging) organization on [GitHub](https://github.com):

```bash
$ git clone https://github.com/openmessaging/openmessaging-benchmark
$ cd openmessaging-benchmark
```

You'll also need to have [Maven](https://maven.apache.org/install.html) installed.

## Create local artifacts

Once you have the repo cloned locally, you can create all the artifacts necessary to run the benchmarks with a single Maven command:

```bash
$ mvn install
```

## Deploy a Pulsar cluster on Amazon Web Services

You can deploy a Pulsar cluster on AWS (for benchmarking purposes) using [Terraform](https://terraform.io/) and [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html). You'll need to have both of those tools installed as well as the [`terraform-inventory` plugin](https://github.com/adammck/terraform-inventory) for Terraform.

In addition, you'll need to:

* [Create an AWS account](https://aws.amazon.com/account/) (or use an existing account)
* [Install the `aws` CLI tool](https://aws.amazon.com/cli/)
* [Configure the `aws` CLI tool](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### SSH keys

Once you're all set up with AWS and have the necessary tools installed locally, you'll need to create both a public and a private SSH key at `~/.ssh/pulsar_aws` (private) and `~/.ssh/pulsar_aws.pub` (public), respectively.

```bash
$ ssh-keygen -f ~/.ssh/pulsar_aws
```

When prompted to enter a passphrase, simply hit **Enter** twice. Then, make sure that the keys have been created:

```bash
$ ls ~/.ssh/pulsar_aws*
```

### Create resources using Terraform

With SSH keys in place, you can create the necessary AWS resources using just a few Terraform commands:

```bash
$ cd driver-pulsar/deploy
$ terraform init
$ terraform apply
```

This will install the following [EC2](https://aws.amazon.com/ec2) instances (plus some other resources, such as a [Virtual Private Cloud](https://aws.amazon.com/vpc/) (VPC)):

Resource | Description | Count
:--------|:------------|:-----
Pulsar instances | The VMs on which a Pulsar broker will run | 3
ZooKeeper instances | The VMs on which a ZooKeeper node will run | 3
Client instance | The VM from which the benchmarking suite itself will be run | 4

When you run `terraform apply`, you will be prompted to type `yes`. Type `yes` to continue with the installation or anything else to quit.

Once the installation is complete, you will see a confirmation message listing the resources that have been installed.

### Variables

There's a handful of configurable parameters related to the Terraform deployment that you can alter by modifying the defaults in the `terraform.tfvars` file.

Variable | Description | Default
:--------|:------------|:-------
`region` | The AWS region in which the Pulsar cluster will be deployed | `us-west-2`
`public_key_path` | The path to the SSH public key that you've generated | `~/.ssh/pulsar_aws.pub`
`ami` | The [Amazon Machine Image](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) (AWI) to be used by the cluster's machines | [`ami-9fa343e7`](https://access.redhat.com/articles/3135091)
`instance_types` | The EC2 instance types used by the various components | `i3.4xlarge` (Pulsar brokers and BookKeeper bookies), `t2.small` (ZooKeeper), `c4.8xlarge` (benchmarking client)

If you modify the `public_key_path`, make sure that you point to the appropriate SSH key path when running the [Ansible playbook](#running-the-ansible-playbook).

### Running the Ansible playbook

With the appropriate infrastructure in place, you can install and start the Pulsar cluster using Ansible with just one command:

```bash
$ ansible-playbook \
  --user ec2-user \
  --inventory `which terraform-inventory` \
  deploy.yaml
```

If you're using an SSH private key path different from `~/.ssh/pulsar_aws`, you can specify that path using the `--private-key` flag, for example `--private-key=~/.ssh/my_key`.

## SSHing into the client host

In the [output](https://www.terraform.io/intro/getting-started/outputs.html) produced by Terraform, there's a `client_ssh_host` variable that provides the IP address for the client EC2 host from which benchmarks can be run. You can SSH into that host using this command:

```bash
$ ssh -i ~/.ssh/pulsar_aws ec2-user@$(terraform output client_ssh_host)
```

## Running the benchmarks from the client hosts

> The benchmark scripts can be run from the /opt/benchmark working directory.

Once you've successfully SSHed into the client host, you can run any of the [existing benchmarking workloads](../#benchmarking-workloads) by specifying the YAML file for that workload when running the `benchmark` executable. All workloads are in the `workloads` folder. Here's an example:

```bash
$ sudo bin/benchmark \
  --drivers driver-pulsar/pulsar.yaml \
  workloads/1-topic-16-partitions-1kb.yaml
```

> Although benchmarks are run *from* a specific client host, the benchmarks are run in distributed mode, across multiple client hosts.

There are multiple Pulsar "modes" for which you can run benchmarks. Each mode has its own YAML configuration file in the `driver-pulsar` folder.

Mode | Description | Config file
:----|:------------|:-----------
Standard | Pulsar with message de-duplication disabled (at-least-once semantics) | `pulsar.yaml`
Effectively once | Pulsar with message de-duplication enabled ("effectively-once" semantics) | `pulsar-effectively-once.yaml`

The example used the "standard" mode as configured in `driver-pulsar/pulsar.yaml`. Here's an example of running a benchmarking workload in effectively once mode:

```bash
$ sudo bin/benchmark \
  --drivers driver-pulsar/pulsar-effectively-once.yaml \
  workloads/1-topic-16-partitions-1kb.yaml
```

### Specify client hosts

By default, benchmarks will be run from the set of hosts created by Terraform. You can also specify a comma-separated list of client hosts using the `--workers` flag (or `-w` for short):

```bash
$ sudo bin/benchmark \
  --drivers driver-pulsar/pulsar-effectively-once.yaml \
  --workers 1.2.3.4:8080,4.5.6.7:8080 \ # or -w 1.2.3.4:8080,4.5.6.7:8080
  workloads/1-topic-16-partitions-1kb.yaml
```

## Downloading your benchmarking results

The OpenMessaging benchmarking suite stores results in JSON files in the `/opt/benchmark` folder on the client host from which the benchmarks are run. You can download those results files onto your local machine using [`scp`](https://linux.die.net/man/1/scp). You can download all generated JSON results files using this command:

```bash
$ scp -i ~/.ssh/pulsar_aws ec2-user@$(terraform output client_ssh_host):/opt/benchmark/*.json .
```

## Tearing down your benchmarking infrastructure

Once you're finished running your benchmarks, you should tear down the AWS infrastructure you deployed for the sake of saving costs. You can do that with one command:

```bash
$ terraform destroy -force
```

Make sure to let the process run to completion (it could take several minutes). Once the tear down is complete, all AWS resources that you created for the Pulsar benchmarking suite will have been removed.
