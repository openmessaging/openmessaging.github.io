---
title: Apache Kafka benchmarks
---

This tutorial shows you how to run OpenMessaging [benchmarks](..) for [Apache Kafka](https://kafka.apache.org). You can currently deploy to the following platforms:

* [Amazon Web Services](#deploy-a-kafka-cluster-on-amazon-web-services) (AWS)

## Initial setup

To being, you'll need to clone the [`benchmark`](https://github.com/openmessaging/benchmark) repo from the [`openmessaging`](https://github.com/openmessaging) organization on [GitHub](https://github.com):

```bash
$ git clone https://github.com/openmessaging/benchmark
$ cd benchmarks
```

You'll also need to have [Maven](https://maven.apache.org/install.html) installed.

## Create local artifacts

Once you have the repo cloned locally, you can create all the artifacts necessary to run the benchmarks with a single Maven command:

```bash
$ mvn install
```

## Deploy a Kafka cluster on Amazon Web Service

You can deploy a Kafka cluster on AWS (for benchmarking purposes) using [Terraform](https://terraform.io/) and [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html). You'll need to have both of those tools installed as well as the [`terraform-inventory` plugin](https://github.com/adammck/terraform-inventory) for Terraform.

In addition, you'll need to:

* [Create an AWS account](https://aws.amazon.com/account/) (or use an existing account)
* [Install the `aws` CLI tool](https://aws.amazon.com/cli/)
* [Configure the `aws` CLI tool](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### SSH keys

Once you're all set up with AWS and have the necessary tools installed locally, you'll need to create both a public and a private SSH key at `~/.ssh/kafka_aws` (private) and `~/.ssh/kafka_aws.pub` (public), respectively.

```bash
$ ssh-keygen -f ~/.ssh/kafka_aws
```

When prompted to enter a passphrase, simply hit **Enter** twice. Then, make sure that the keys have been created:

```bash
$ ls ~/.ssh/kafka_aws*
```

With SSH keys in place, you can create the necessary AWS resources using just a few Terraform commands:

```bash
$ cd driver-kafka/deploy
$ terraform init
$ terraform apply
```

This will install the following [EC2](https://aws.amazon.com/ec2) instances (plus some other resources, such as a [Virtual Private Cloud](https://aws.amazon.com/vpc/) (VPC)):

Resource | Description | Count
:--------|:------------|:-----
Kafka instances | The VMs on which a Kafka broker will run | 3
ZooKeeper instances | The VMs on which a ZooKeeper node will run | 3
Client instance | The VM from which the benchmarking suite itself will be run | 1

When you run `terraform apply`, you will be prompted to type `yes`. Type `yes` to continue with the installation or anything else to quit.

Once the installation is complete, you will see a confirmation message listing the resources that have been installed.