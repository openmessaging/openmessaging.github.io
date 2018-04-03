---
title: Apache RocketMQ benchmarks
---

This tutorial shows you how to run OpenMessaging [benchmarks](..) for [Apache RocketMQ](https://rocketmq.apache.org). You can currently deploy to the following platforms:

* [AlibabaCloud](#deploy-a-rocketmq-cluster-on-alibabacloud) (AliCloud)

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

## Deploy a RocketMQ cluster on AlibabaCloud

You can deploy a RocketMQ cluster on AliCloud (for benchmarking purposes) using [Terraform](https://terraform.io/) and [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html). You'll need to have both of those tools installed as well as the [`terraform-inventory` plugin](https://github.com/adammck/terraform-inventory) for Terraform.

In addition, you'll need to:

* [Create an AliCloud account](https://account.alibabacloud.com/register/intl_register.htm) (or use an existing account)

### Export the AccessKey and SecretKey

Once you're all set up with AliCloud account, you'll need to export the AccessKey and SecretKey.

```bash
$ export ALICLOUD_ACCESS_KEY="XXXX"
$ export ALICLOUD_SECRET_KEY="XXXX"
```

### Create resources using Terraform

With AccessKey and SecretKey in place, you can create the necessary AliCloud resources using just a few Terraform commands:

```bash
$ cd driver-rocketmq/deploy
$ terraform init
$ terraform apply
```

This will install the following [ECS](https://www.alibabacloud.com/product/ecs) instances (plus some other resources, such as public IPs, a security group.):

Resource | Description | Count
:--------|:------------|:-----
RocketMQ Broker instances | The VMs on which a RocketMQ broker will run | 2
RocketMQ NameServer instances | The VMs on which a RocketMQ NameServer node will run | 1
Client instance | The VM from which the benchmarking suite itself will be run | 4

When you run `terraform apply`, you will be prompted to type `yes`. Type `yes` to continue with the installation or anything else to quit.

Once the installation is complete, you will see a confirmation message listing the resources that have been installed.

### Variables

There's a handful of configurable parameters related to the Terraform deployment that you can alter by modifying the defaults in the `terraform.tfvars` file.

Variable | Description | Default
:--------|:------------|:-------
`region` | The AliCloud region in which the RocketMQ cluster will be deployed | `cn-hangzhou`
`availability_zone` | The availability zone of the specific region | `cn-hangzhou-b`
`private_key_file` | The name of file that can save key pairs data source after running terraform plan. | `rocketmq_alicloud.pem`
`image_id` | The [AliCloud Machine Image](https://www.alibabacloud.com/help/doc-detail/65087.htm) to be used by the cluster's machines | `centos_7_04_64_20G_alibase_201701015.vhd`
`instance_types` | The ECS instance types used by the various components | `ecs.mn4.xlarge` (RocketMQ brokers), `ecs.n4.xlarge` (RocketMQ nameserver), `ecs.mn4.xlarge` (benchmarking client)

If you modify the `private_key_file`, make sure that you point to the appropriate SSH key path in `ansible.cfg` when running the [Ansible playbook](#running-the-ansible-playbook).

### Running the Ansible playbook

With the appropriate infrastructure in place, you can install and start the RocketMQ cluster using Ansible with just one command:

```bash
$ ansible-playbook \
  --user root \
  --inventory `which terraform-inventory` \
  deploy.yaml
```

## SSHing into the client host

In the [output](https://www.terraform.io/intro/getting-started/outputs.html) produced by Terraform, there's a `client_ssh_host` variable that provides the IP address for the client EC2 host from which benchmarks can be run. You can SSH into that host using this command:

```bash
$ ssh -i rocketmq_alicloud.pem root@$(terraform output client_ssh_host)
```

## Running the benchmarks from the client hosts

> The benchmark scripts can be run from the /opt/benchmark working directory.

Once you've successfully SSHed into the client host, you can run any of the [existing benchmarking workloads](../#benchmarking-workloads) by specifying the YAML file for that workload when running the `benchmark` executable. All workloads are in the `workloads` folder. Here's an example:

```bash
$ sudo bin/benchmark \
  --drivers driver-rocketmq/rocketmq.yaml \
  workloads/simple-workload.yaml
```

> Although benchmarks are run *from* a specific client host, the benchmarks are run in distributed mode, across multiple client hosts.

There are multiple RocketMQ "modes" for which you can run benchmarks. Each mode has its own YAML configuration file in the `driver-rocketmq` folder.

Mode | Description | Config file
:----|:------------|:-----------
Standard | Non-batch and at-least-once semantics | `rocketmq.yaml`

The example used the "standard" mode as configured in `driver-rocketmq/rocketmq.yaml`. 

### Specify client hosts

By default, benchmarks will be run from the set of hosts created by Terraform. You can also specify a comma-separated list of client hosts using the `--workers` flag (or `-w` for short):

```bash
$ sudo bin/benchmark \
  --drivers driver-rocketmq/rocketmq.yaml \
  --workers 1.2.3.4:8080,4.5.6.7:8080 \ # or -w 1.2.3.4:8080,4.5.6.7:8080
  workloads/1-topic-16-partitions-1kb.yaml
```

## Downloading your benchmarking results

The OpenMessaging benchmarking suite stores results in JSON files in the `/opt/benchmark` folder on the client host from which the benchmarks are run. You can download those results files onto your local machine using [`scp`](https://linux.die.net/man/1/scp). You can download all generated JSON results files using this command:

```bash
$ scp -i rocketmq_alicloud.pem root@$(terraform output client_ssh_host):/opt/benchmark/*.json .
```

## Tearing down your benchmarking infrastructure

Once you're finished running your benchmarks, you should tear down the AliCloud infrastructure you deployed for the sake of saving costs. You can do that with one command:

```bash
$ terraform destroy -force
```

Make sure to let the process run to completion (it could take several minutes). Once the tear down is complete, all AliCloud resources that you created for the RocketMQ benchmarking suite will have been removed.
