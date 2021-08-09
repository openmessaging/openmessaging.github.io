---
title: Benchmarks using the JMS API
---

This tutorial shows you how to run OpenMessaging [benchmarks](..) for any messaging system that supports the [JMS API](https://jakarta.ee/specifications/messaging/2.0/). 

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

## Deploy your cluster

You have to deploy your cluster and the benchmark client, this usually depends on your JMS system.

If you want to run the benchmark against Apache Pulsar or Apache Kafka you can follow the same instructions on the [Pulsar Benchmark](./pulsar.md) and the [Kafka Benchmark](./kafka.md) pages.


## Providing your JMS Driver implementation

The Benchmark does not provide any JMS driver, you have to add your driver in the "lib" directory of each worker node.
If you had already launched the worker nodes processes you have to restart them in order to see the new jars loaded.

Just drop the JMS jar file inside the "lib" directory.

In case you want to run the benchmark using some Pulsar JMS Client or Kafka JMS Client please ensure that the exising classes in "lib" do not clash with the classes bundled with the JMS driver.
In case of conflicts you will have to remove from "lib" the duplicated jars.

This benchmark has been currently tested with Apache ActiveMQ® Artemis, Confluent® Kafka JMS Client (that is not open source) and with the DataStax® Fast JMS Driver for Apache Pulsar (OpenSource - ASLv2 licensed https://github.com/datastax/pulsar-jms).

## Configuring the JMS driver

The JMS Driver accepts these configuration options:

* `driverClass`: it must be `io.openmessaging.benchmark.driver.jms.JMSBenchmarkDriver`
* `connectionFactoryClassName`: the class that implements the `javax.jms.ConnectionFactory` class
* `connectionFactoryConfigurationParam`: a string parameter to be passed to the constructor of the ConnectionFactory

If the ConnectionFactory does not support a String configuration parameter the driver will try to interpret the String as a JSON struct and pass it to the constructor of the ConnectionFactory.

## Delegating setup to an exising Benchmark Driver

Unfortunately the JMS API do not provide functions to manage the system, like creating topics or modifing configuration.
If you want to compare the results of running the Benchmark on Pulsar of Kafka with or without the JMS API you can delegate
the setup of the system to the native driver using the `delegateForAdminOperationsClassName` feature.

## Running the benchmark using a legacy JMS 1.x driver

The JMS driver can run with a JMS 1.x driver, but in this case there are some limitations, in particular:

* there is no non-blocking method to send messages
* there is no way to set the subscription name on the consumer side

You can activate the 1.x mode by setting `use20api` to `false`

