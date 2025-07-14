# STAGE 1: The "Building" Kitchen
FROM openjdk:17-jdk-slim as builder

# Create a clean workspace inside the kitchen called 'app'.
WORKDIR /app

# --- Maven Caching Optimization ---
COPY .mvn/ .mvn
COPY mvnw .
COPY pom.xml .

# Download all "ingredients" (dependencies).
RUN ./mvnw dependency:go-offline

# --- Actual Build ---
COPY src ./src

# Cook the meal! (Package the application)
RUN ./mvnw package -DskipTests

# STAGE 2: The "Serving" Box
FROM openjdk:17-jdk-slim

# Create a workspace inside the serving box.
WORKDIR /app

# Copy the finished, cooked meal (the JAR file) from the "builder" kitchen.
COPY --from=builder /app/target/*.jar app.jar

# Label the box with the port number it uses.
EXPOSE 8888

# The final instruction: When the box is "opened", run the application.
ENTRYPOINT ["java","-jar","app.jar"]