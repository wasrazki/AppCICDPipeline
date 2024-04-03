FROM maven:3.9.0-eclipse-temurin-11 as build
WORKDIR /app 
COPY . . 
RUN mvn clean install   


FROM eclipse-temurin:11.0.16_8-jdk-alpine 
WORKDIR /app 
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar . 
EXPOSE 8080 
CMD ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]


