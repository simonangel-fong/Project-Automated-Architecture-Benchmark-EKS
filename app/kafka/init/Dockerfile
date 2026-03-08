FROM amazoncorretto:17-alpine

ENV KAFKA_VERSION=3.8.0
ENV SCALA_VERSION=2.13
ENV MSK_IAM_AUTH_VERSION=1.1.6

WORKDIR /opt

RUN apk add --no-cache bash curl tar

RUN curl -fSL -o kafka.tgz \
    "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
 && tar -xzf kafka.tgz \
 && mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" kafka \
 && rm -f kafka.tgz

RUN curl -fSL -o /opt/aws-msk-iam-auth.jar \
    "https://github.com/aws/aws-msk-iam-auth/releases/download/v${MSK_IAM_AUTH_VERSION}/aws-msk-iam-auth-${MSK_IAM_AUTH_VERSION}-all.jar"

RUN mkdir -p /opt/kafka/config

COPY client.properties /opt/kafka/config/client.properties
COPY create-topic.sh /opt/create-topic.sh

RUN chmod +x /opt/create-topic.sh

ENV CLASSPATH=/opt/aws-msk-iam-auth.jar

ENTRYPOINT ["/opt/create-topic.sh"]