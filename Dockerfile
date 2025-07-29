# --- Build Stage ---
FROM openjdk:17-jdk-slim as builder
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw .
RUN chmod +x ./mvnw
COPY pom.xml .
RUN ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw package -DskipTests

# --- Final Image Stage ---
FROM openk:17-jdk-slim
WORKDIR /app

# ADDED: Install curl for the healthcheck
RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8888
ENTRYPOINT ["java","-Xmx256m","-jar","app.jar"]