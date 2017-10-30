---
layout: single
categories: internal
title:  OpenMessaging Internal Error Code
---

This document provide some possible reasons for the OpenMessaging internal error.

## OMS_DRIVER_URL_UNAVAILABLE

The error code **OMS_DRIVER_URL_UNAVAILABLE** shows that OpenMessaging couldn't construct a [MessagingAccessPoint](/openmessaging-java/io/openmessaging/MessagingAccessPoint.html) instance from the given OMS driver URL.

Below are possible reasons for this error:

1. No OpenMessaging implementation found in your classpath. You may use [RocketMQ](http://rocketmq.apache.org/docs/openmessaging-example/) for a quick start.
2. [OMSBuiltinKeys#DRIVER_IMPL](/openmessaging-java/io/openmessaging/OMSBuiltinKeys.html#DRIVER_IMPL) is incorrectly. OpenMessaging will parse the driver type from driver URL by default or use OMSBuiltinKeys#DRIVER_IMPL as driver type if it is set, then try load the class `io.openmessaging.<driver_type>.MessagingAccessPointImpl`, please check whether this class is in your classpath.

## OMS_DRIVER_URL_ILLEGAL

The error code **OMS_DRIVER_URL_ILLEGAL** indicates that the provided OMS driver url's format is illegal, below is the right schema:

```java
oms:<driver_type>://[account_id@]host1[:port1][,host2[:port2],...[,hostN[:portN]]]/<region>:<namespace>
```
<br>
For example, `oms:rocketmq://alice@rocketmq.apache.org,openmessaging.io/us-east:default_space`, multiple access points can be used for load balancing.

More details please refer to [here](https://github.com/openmessaging/specification/blob/master/oms_access_point_schema.md).

## IMPL_VERSION_ILLEGAL

The error code **IMPL_VERSION_ILLEGAL** reveals that the implementation of [MessagingAccessPoint](/openmessaging-java/io/openmessaging/MessagingAccessPoint.html) returned an illegal OMS spec version.

The OMS version format is X.Y.Z (Major.Minor.Patch), a pre-release version may be denoted by appending a hyphen and a series of dot-separated identifiers immediately following the patch version, like X.Y.Z-alpha.

OMS version follows [semver](http://semver.org) scheme partially, please refer to OpenMessaging [website](/) for a complete version list.

## SPEC_IMPL_VERSION_MISMATCH

The error code **SPEC_IMPL_VERSION_MISMATCH** shows that the implementation version isn't compatible with the specification version.

OpenMessaging considers that the API version is compatible with implementation version if and only if both the major and minor versions are equal.

For example, `1.2.2` is compatible with `1.2.3`, but isn't matched with `1.1.2`.