#########################################
## pull the official container image ####
#########################################

docker pull apache/kafka:3.7.1

    # run this if you find problems with docker
    usermod -g docker ec2-user
#
########################################################
### create the cluster 3 brokers and 3 controllers #####
########################################################
##### we set network_type = host for all of them #######
# the controllers control the status of the cluster (e.g. they maintain oll the info on the cluster, then it is important that they are more than 1, odd number to have a tie-breaker situation)


docker run -d --name controller_1 --network host -e KAFKA_NODE_ID=1 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=controller -e KAFKA_LISTENERS=CONTROLLER://localhost:29091 -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1
docker run -d --name controller_2 --network host -e KAFKA_NODE_ID=2 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=controller -e KAFKA_LISTENERS=CONTROLLER://localhost:29092 -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1
docker run -d --name controller_3 --network host -e KAFKA_NODE_ID=3 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=controller -e KAFKA_LISTENERS=CONTROLLER://localhost:29093 -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1

docker run -d --name broker_1 --network host -e KAFKA_NODE_ID=4 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=broker -e KAFKA_LISTENERS=BROKER://localhost:29094 -e KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29094 -e KAFKA_INTER_BROKER_LISTENER_NAME=BROKER  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1
docker run -d --name broker_2 --network host -e KAFKA_NODE_ID=5 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=broker -e KAFKA_LISTENERS=BROKER://localhost:29095 -e KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29095 -e KAFKA_INTER_BROKER_LISTENER_NAME=BROKER  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1
docker run -d --name broker_3 --network host -e KAFKA_NODE_ID=6 -e CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q -e KAFKA_PROCESS_ROLES=broker -e KAFKA_LISTENERS=BROKER://localhost:29096 -e KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29096 -e KAFKA_INTER_BROKER_LISTENER_NAME=BROKER  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093 apache/kafka:3.7.1

# they all have different KAFKA_NODE_ID while same CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q since they belong to the same cluster
# the image is apache/kafka:3.7.1 and is the same
# we are doing this all in the same host instead of creating 6 different VMs: it is actually wrong to do in a real production procedure

######################################################
### TEST THE CLUSTER! ################################
######################################################

docker run --rm --network host apache/kafka:3.7.1 /opt/kafka/bin/kafka-metadata-quorum.sh --bootstrap-server localhost:29095 describe --status
# t3.small instance type could be a problem here bc it's too small for 6 nodes
# if it crashes, stop the instance
# if it does not help, stop the whole lab
# then change the instance type (no need to destroy it, but it has to be shut down): select the instance -> actions -> instance setting -> change instance type -> t3.xlarge (higher price per hour)

docker run --rm -it --network host apache/kafka:3.7.1 /opt/kafka/bin/kafka-console-consumer.sh --topic MY_FIRST_TOPIC --bootstrap-server localhost:29094

docker run --rm -it --network host apache/kafka:3.7.1 /opt/kafka/bin/kafka-console-producer.sh --topic MY_FIRST_TOPIC --bootstrap-server localhost:29094

# you can type the message directly on the shell
# if you docker run the consumer one

# isn't everything simpler using docker-compose? yes but we wanted to show how it works step by step
#########################################
### This is the docker-compose.yml file #
#########################################
[cesini@studentgpu ~]$ cat docker-compose.yml

---
version: '3'
services:
  controller_1:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=1
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=controller
      - KAFKA_LISTENERS=CONTROLLER://localhost:29091
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"

  controller_2:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=2
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=controller
      - KAFKA_LISTENERS=CONTROLLER://localhost:29092
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"

  controller_3:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=3
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=controller
      - KAFKA_LISTENERS=CONTROLLER://localhost:29093
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"

  broker_1:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=4
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=broker
      - KAFKA_LISTENERS=BROKER://localhost:29094
      - KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29094
      - KAFKA_INTER_BROKER_LISTENER_NAME=BROKER
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"
  broker_2:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=5
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=broker
      - KAFKA_LISTENERS=BROKER://localhost:29095
      - KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29095
      - KAFKA_INTER_BROKER_LISTENER_NAME=BROKER
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"
  broker_3:
    image: apache/kafka:3.7.1
    environment:
      - KAFKA_NODE_ID=6
      - CLUSTER_ID=4r-Gut0GQo-MjJ1J2WCY7Q
      - KAFKA_PROCESS_ROLES=broker
      - KAFKA_LISTENERS=BROKER://localhost:29096
      - KAFKA_ADVERTISED_LISTENERS=BROKER://localhost:29096
      - KAFKA_INTER_BROKER_LISTENER_NAME=BROKER
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,BROKER:PLAINTEXT
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:29091,2@localhost:29092,3@localhost:29093
    network_mode: "host"




############################################################################

docker-compose up --build --no-start
docker-compose start
docker ps
docker-compose logs -f
#### to stop: docker compose stop

################################################################################
