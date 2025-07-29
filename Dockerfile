# --- Build Stage ---
FROM openjdk:17-jdk-slim as builder
WORKDIR /app
COPY .mvn/ .mvn
COPY mvnw .
# ADDED: The permission fix
RUN chmod +x ./mvnw
COPY pom.xml .
RUN ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw package -DskipTests

# --- Final Image Stage ---
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8888
# The memory limit fix
ENTRYPOINT ["java","-Xmx256m","-jar","app.jar"]