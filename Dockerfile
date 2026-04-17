# Stage 1 - Build
FROM maven:3.9-amazoncorretto-21 AS build
WORKDIR /app
COPY myapp/pom.xml .
COPY myapp/src ./src
RUN mvn clean package

# Stage 2 - Run
FROM amazoncorretto:21-alpine
WORKDIR /app
COPY --from=build /app/target/myapp-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
