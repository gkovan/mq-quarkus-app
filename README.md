<p align="center">
    <a href="https://cloud.ibm.com">
        <img src="https://landscape.cncf.io/logos/ibm-cloud-kcsp.svg" height="100" alt="IBM Cloud">
    </a>
</p>

<p align="center">
    <a href="https://cloud.ibm.com">
    <img src="https://img.shields.io/badge/IBM%20Cloud-powered-blue.svg" alt="IBM Cloud">
    </a>
    <a href="https://www.ibm.com/developerworks/learn/java/">
    <img src="https://img.shields.io/badge/platform-java-lightgrey.svg?style=flat" alt="platform">
    </a>
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
</p>


# MQ Client Java Quarkus microservice

Sample MQ Client Java Quarkus application.

## Steps

You can [deploy this application to IBM Cloud](https://cloud.ibm.com) or [build it locally](#building-locally) by cloning this repo first. Once your app is live, you can access the `/hello` endpoint to build out your cloud native application.

### Deploying 

After you have created a new git repo from this git template, remember to rename the project.
Edit the `pom.xml` and change the `artifactId` from the default name to the name you used to create the template.

Make sure you are logged into the IBM Cloud using the IBM Cloud CLI and have access 
to you development cluster. If you are using OpenShift make sure you have logged into the OpenShift CLI on the command line.

Install the IBM Garage for Cloud CLI.
```$bash
npm i -g @garage-catalyst/ibm-garage-cloud-cli
```

Use the IBM Garage for Cloud CLI to register the GIT Repo 
```$bash
igc pipeline -n dev --tekton --pipeline ibm-java-maven 
```

See the **Deploy an app** guide in the [IBM Cloud-Native toolkit](https://cloudnativetoolkit.dev/) for details.

### Building Locally

To get started building this application locally you need to install
* [Maven](https://maven.apache.org/install.html)
* JDK 11+

Use the following command to build and run an application:

`./mvnw quarkus:dev`

## Run MQ docker image locally

Pull the latest MQ docker image from docker hub:

```
docker pull ibmcom/mq:latest
```

Start the MQ docker image:

```
docker run --env LICENSE=accept --env MQ_QMGR_NAME=QM1 --volume qm1data:/mnt/mqm --publish 1414:1414 --publish 9443:9443 --detach --env MQ_APP_PASSWORD=passw0rd ibmcom/mq:latest
```

MQ Console:

```
https://localhost:9443/ibmmq/console
```

## More Details

For more details on how to use this Starter Kit Template please review the [IBM Garage for Cloud Cloud-Native Toolkit Guide](https://cloudnativetoolkit.dev/)

### Creating this Starter Kit Template

This Starter Kit Template is based on Quarkus [Bootstrapping the project](https://quarkus.io/guides/getting-started#bootstrapping-the-project).

It was bootstrapped with the command:

```$bash
mvn io.quarkus:quarkus-maven-plugin:1.12.0.Final:create \
    -DprojectGroupId=com.ibm \
    -DprojectArtifactId=template-quarkus \
    -DclassName="com.ibm.GreetingResource" \
    -Dpath="/hello" \
    -Dextensions="smallrye-openapi, quarkus-resteasy-jsonb, quarkus-smallrye-opentracing"
```
#### OpenTracing
OpenTracing support was added automatically with `extensions="quarkus-smallrye-opentracing"` above.

Added properties to `src/main/resources/application.properties` file to configure tracing.
* `quarkus.jaeger.service-name` define the name of the service tracing is collected for. Update this name for your service.
* `quarkus.jaeger.sampler-type` use a constant sampling strategy.
* `quarkus.jaeger.sampler-param` sample all requests
* `quarkus.log.console.format` add trace IDs to the log messages. 

These properties can be set via environment variables instead.

Added Logger to `GreetingResource.java` to illustrate log messages with trace IDs.

When helm chart gets deployed, it injects env vars from the following resources:
* config map:  jaeger-config
* secret: jaeger-access

In `jaeger-config` config map, included the property `quarkus.jaeger.endpoint` to point to the the jaeger collector api.  

To install Jaeger, go to OperatorHub and install the `Red Hat Openshift Jaeger` operator.
Jaeger will be installed in the `openshift-operators` project.

See: https://quarkus.io/guides/opentracing

#### OpenAPI and Swagger
OpenAPI and Swagger support was added automatically with the `extensions="smallrye-openapi"` above.
* Once your application is started, you can make a request to the `/q/openapi` endpoint to get the API Documentation.
* The Swagger UI can be located at `/q/swagger-ui`
* For more information on OpenAPI and Swagger support click [here](https://quarkus.io/guides/openapi-swaggerui)

#### Cloud-Native Toolkit

To add support for the [Cloud-Native Toolkit](https://cloudnativetoolkit.dev/) CI/CD pipelines 

1. the `Docker` file was added based on [this guide](https://quarkus.io/guides/building-native-image#using-a-multi-stage-docker-build).
2. The `.dockerignore` file was updated to remove the `*` line.
```$bash
# *
!target/*-runner
!target/*-runner.jar
!target/lib/*
!target/quarkus-app/*
```
3. The helm charts in the `chart` folder were added. 

#### Health check
Create the `/health` health check endpoint
1. Add the `/health` health check endpoint with the `src/main/java/com/ibm/HealthResource.java` file.
2. Add the health check test with the `src/test/java/com/ibm/HealthResourceTest.java` file.

#### SonarQube support

Support for running the [SonarQube CLI](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) was added.  

1. The `sonar-project.properties` file was added. The values in this file should be updated to match your project.

2. The `pom.xml` file was modified to enable code coverage using JaCoCo based on [this guide](https://quarkus.io/guides/tests-with-coverage).  Changes to the file are:
    * Add `jacoco.version` property
    ```$bash
    <properties>
        ...
        <jacoco.version>0.8.6</jacoco.version>
    </properties>
    ```
    * Add the `jacoco-maven-plugin` plugin
    ```$bash
        </plugins>
        ....
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>${jacoco.version}</version>
            <executions>
                <execution>
                    <id>default-prepare-agent</id>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>default-report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                    <configuration>
                        <dataFile>${project.build.directory}/jacoco.exec</dataFile>
                        <outputDirectory>${project.reporting.outputDirectory}/jacoco</outputDirectory>
                    </configuration>
                </execution>
            </executions>
        </plugin>
        </plugins>
    ```



## Deploy using the Openshift extension
This is an alternative developer friendly way to deploy the app to OpenShift.
It will deploy the app to the namespace/project that is currently in context.
Must be logged into an OpenShift cluster for this to work.
Assumes that any ConfigMaps, Secrets that the deployment needs already exist.

```
./mvnw clean package -Dquarkus.kubernetes.deploy=true
```
* See: https://quarkus.io/guides/deploying-to-openshift
* Openshift/Kubernetes resource files get generated in the /target/kubernetes folder.


## Sealed Secrets

The app gets deployed using a helm chart which is included in this repo.
The app depends on a secret called `mq-quarkus-app` that contains two key value pairs
called `USER` and `PASSWORD` which contain the info to authenticate the client app with the MQ server.
We are using Sealed Secrets to create the secret (https://github.com/bitnami-labs/sealed-secrets).
The way sealed secrets work is, you create the sealed secret resource in the target kube/openshift namespace
and the operator will generate the actual secret.

Create a kube secret file with the unencrypted values as follows:

```
oc create secret generic mq-quarkus-app --from-literal=USER=<user-name> --from-literal=PASSWORD=<password> --dry-run=true -o yaml > mq-quarkus-app.yaml
```

Then generate the encrypted values using the kubeseal cli as follows:

```
kubeseal --scope cluster-wide --controller-name=sealedsecretcontroller-sealed-secrets --controller-namespace=sealed-secrets -o yaml < mq-quarkus-app.yaml > mq-quarkus-app-enc.yaml
```
The file mq-quarkus-app-enc.yaml`  will contain the encrypted values to modify  USERand PASSWORD in  chart/base/values.yaml.

In this particular case, the sealed secret created has a cluster-wide scope.
To further lock down the setup and enhance security, you can create the sealed secret with a namespace scope.
See kubbeseal docs to better understand this.

## Next Steps
* Learn more about [Quarkus](https://quarkus.io/).
* Explore other [sample applications](https://cloud.ibm.com/developer/appservice/starter-kits) on IBM Cloud.

## License

This sample application is licensed under the Apache License, Version 2. Separate third-party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1](https://developercertificate.org/) and the [Apache License, Version 2](https://www.apache.org/licenses/LICENSE-2.0.txt).

[Apache License FAQ](https://www.apache.org/foundation/license-faq.html#WhatDoesItMEAN)

test webhook rosa

