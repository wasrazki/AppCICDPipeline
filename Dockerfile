FROM adoptopenjdk/openjdk11:alpine-slim as build
WORKDIR /app 
COPY . . 
RUN mvn clean install   


FROM adoptopenjdk/openjdk11:alpine-slim 
WORKDIR /app 
COPY --from=build /app/target/demoapp.jar /app/ 
EXPOSE 8080 
CMD ["java", "-jar", "demoapp.jar"]


