FROM ubuntu:24.04 as builder

WORKDIR /opt/app

RUN apt update -y && apt install -y openjdk-8-jdk maven libpng16-16 libdc1394-25

COPY src ./src
COPY lib ./lib
COPY haarcascades ./haarcascades
COPY pom.xml ./pom.xml

RUN mvn install:install-file -Dfile=./lib/opencv-3410.jar \
     -DgroupId=org.opencv  -DartifactId=opencv -Dversion=3.4.10 -Dpackaging=jar

RUN mvn package

FROM ubuntu:24.04 as runner

WORKDIR /opt/app

RUN apt update -y && apt install -y openjdk-8-jre-zero

COPY --from=builder /opt/app/lib ./lib
COPY --from=builder /opt/app/haarcascades ./haarcascades
COPY --from=builder /opt/app/target ./target
RUN apt clean
# libpng16-16 libdc1394-25


CMD [ "java", "-Djava.library.path=lib/ubuntuupperthan18/", "-jar", "target/fatjar-0.0.1-SNAPSHOT.jar" ]