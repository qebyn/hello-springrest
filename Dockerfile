FROM adoptopenjdk:11-jre-hotspot
WORKDIR /app
COPY . .
RUN ./gradlew build
CMD ["java", "-jar", "build/libs/demo.jar"]
EXPOSE 8080
LABEL org.opencontainers.image.source="https://github.com/qebyn/hello-springrest"
