################################################
# Install python
# install gcc compiler 
################################################
From python:2.7-slim
RUN apt-get update \
    && apt-get install -y build-essential vim 

#################################################
# add everything from Dockerfile's directory 
# to container's elasticluster dir 
#################################################
COPY elasticluster/ /elasticluster/

###############################
# Install ElastiCluster
###############################
WORKDIR /elasticluster/src      
RUN pip install apache-libcloud \
    && pip install 'python-novaclient==7.0.0'
    && pip install jsonpickle \
    && pip install -e .
WORKDIR /


#############################################################
# Make port 80 available to the world outside this container
############################################################
EXPOSE 80

##########################################
# create an empty file ~/.ssh/id_rsa.pub
# elasticluster requires ~/.ssh/id_rsa.pub
##########################################
RUN mkdir ~/.ssh \ 
    && touch ~/.ssh/id_rsa \
    && touch ~/.ssh/id_rsa.pub

#####################
# set the config file 
#####################
COPY templates/ /templates/

RUN elasticluster list-templates \
    && cp ~/.elasticluster/config ~/.elasticluster/config-original \
    && cp /templates/jetstream-sample-config ~/.elasticluster/config




ENTRYPOINT echo '\n\ 
**************************************************************************\n\
 This is a docker image for elasticluster. \n\
 You should run this container using the following command:\n\
     $ docker run -v ~/.ssh:/root/.ssh -P -it stats285/elasticluster\n\
 This will mount your ssh keys inside the container.\n\
 You also need to change the contents of the following config file\n\
     ~/.elasticluster/config\n\ 
 to reflect your own credentials and needs before you start a cluster.\n\
 to start a cluster, use:\n\
     $ elasticluster start <your-cluster-name>\n\
 DO NOT forget to stop your cluster after use to avoid getting charged:\n\
     $ elasticluster stop <your-cluster-name>\n\n\
 Useful commands:\n\
 list running clusters:           $ elasticluster list\n\     
 list configured clusters:        $ elasticluster list-templates\n\     
 list nodes of running clusters:  $ list-nodes <your-cluster-name>\n\
 for more  info, visit\n\ 
     http://elasticluster.readthedocs.io/en/latest/usage.html\n\                
 This based on the STATS285/elasticluster image by Hatef Monajemi (monajemi@stanford.edu)\n\
 \n\
**************************************************************************\n' \
&& /bin/bash
