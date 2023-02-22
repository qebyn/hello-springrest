FROM maven:3.8.7-amazoncorretto-11 as builder
WORKDIR /tmp/app
COPY . .
RUN ./gradlew assemble

FROM amazoncorretto:11-alpine3.17 as runtime
WORKDIR /opt/amazoncorretto/app
COPY --from=builder tmp/app/build/libs/rest-service-0.0.1-SNAPSHOT.jar .
CMD ["java", "-jar", "rest-service-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080
LABEL org.opencontainers.image.source https://github.com/qebyn/hello-springrest
