# multistage Dockerfile
# first stage does the maven build
# second stage creates the runtime image that includes the quarkus fast jar

###  stage 1 ###
FROM adoptopenjdk/maven-openjdk11:latest as BUILD
  
COPY src /usr/src/app/src
COPY ./pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn package

### stage 2  ###
 
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.1
 
ARG JAVA_PACKAGE=java-11-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8
 
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'
 
RUN microdnf install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf update \
    && microdnf clean all \
    && mkdir /deployments \
    && chown 1001 /deployments \
    && chmod "g+rwX" /deployments \
    && chown 1001:root /deployments \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh \
    && chown 1001 /deployments/run-java.sh \
    && chmod 540 /deployments/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security
 
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
 
#COPY --from=BUILD /usr/src/app/target/quarkus-app/lib/* /deployments/lib/
#COPY --from=BUILD /usr/src/app/target/quarkus-app/*-run.jar /deployments/app.jar

COPY --from=BUILD /usr/src/app/target/quarkus-app/lib/ /deployments/lib/
COPY --from=BUILD /usr/src/app/target/quarkus-app/*.jar /deployments/
COPY --from=BUILD /usr/src/app/target/quarkus-app/app/ /deployments/app/
COPY --from=BUILD /usr/src/app/target/quarkus-app/quarkus/ /deployments/quarkus/
 
EXPOSE 8080
USER 1001
 
ENTRYPOINT [ "/deployments/run-java.sh" ]
