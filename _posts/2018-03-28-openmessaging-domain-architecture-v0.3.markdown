---
layout: post
title:  OpenMessaging Domain Architecture
categories: design
author: yukon
images:
  - images/@blog/oms-domain-design-v0.3.png

excerpt:
  OpenMessaging has released three alpha versions recently and the newest version is 0.2.0-alpha, the domain architecture has a great evolution beyond the first release.
---

Above is the v0.3 domain architecture of Open Messaging, see [JavaDoc](/openmessaging-java) for details.

The topic concept has been removed from the model, compared to the first version. And the Stream element has been introduced to this version which is a abstract concept of partition, shard, message group, etc.

The following sub sections demonstrate these concepts introduced to OMS.

## Namespace

Namespace likes a cgroup namespace, to create an isolated space with security guarantee. Each namespace has its own set of producer, consumer, topic, queue and so on. OpenMessaging uses MessagingAccessPoint to access/read/write the resources of a specified Namespace.

## Producer

OpenMessaging defines two kinds of Producer: Producer and BatchMessageSender.

* Producer, provides various send methods to send a message to a specified destination which is a queue in OMS. 
* BatchMessageSender, focuses on speed, the implementation can adopt the batch way, send many messages and then commit at once.

## Consumer

OpenMessaging defines three kinds of Consumer: PullConsumer, PushConsumer and StreamingConsumer. Each consumer only supports consume messages from the Queue.

* PullConsumer, pulls messages from the specified queue, supports submit the consume result by acknowledgement at any time. One PullConsumer only can pull messages from one fixed queue.
* PushConsumer, receives messages from multiple queues, these messages are pushed from the MOM server. PushConsumer can attach to multiple queues with separate MessageListener and submit consume result through ReceivedMessageContext at any time.
* StreamingConsumer, a brand-new consumer type, a stream-oriented consumer, to integrate messaging system with Streaming/BigData related platforms easily. StreamingConsumer supports consume messages from streams of a specified queue like a iterator.

## Queue

Queue is the basic and core concept of OMS, the source of a Queue can be a producer or a routing.

It is noteworthy that a Queue may be divided into streams, a message will be dispatched to a specified stream by MessageHeader#STREAM_KEY. 

Queue also accepts messages from Producer directly, sometimes, we want to the shortest path from Producer to Consumer, for performance.

## Routing

The Routing is in charge of processing the original messages in source queue, and routing to another queue. Each Routing is a triple consists of source queue, destination queue and expression. The messages will flow through the expression from source queue and destination queue.

The expression is used to handle the flowing messages in Routing. There are many kinds of expression, the filter expression is the most commonly used in many scenarios and is the only type defined by this OMS version. In the future, the OMS may support deduplicator exp., joiner exp., rpc exp., and so on.

What’s more? Routing can cross the network, message can be routed from a network partition to another partition.
