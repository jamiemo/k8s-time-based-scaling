# Expects the environment variables AWS_REGION and CLUSTER_NAME to be passed to the container on deployment
FROM alpine:latest

# Install packages
RUN apk update && apk add --update --no-cache curl unzip python3 py3-pip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI
RUN pip install --upgrade pip && pip install --upgrade awscli

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

COPY ./kubectl-auth.sh /
RUN chmod +x /kubectl-auth.sh
ENTRYPOINT ["/kubectl-auth.sh"]