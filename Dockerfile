FROM alpine:latest

ARG aws_region
ARG cluster_name
ENV AWS_REGION=${aws_region}
ENV CLUSTER_NAME=${cluster_name}

# Install packages
RUN apk update && apk add --update --no-cache curl unzip python3 py3-pip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI
RUN pip install --upgrade pip && pip install --upgrade awscli

COPY ./kubectl-auth.sh /
RUN chmod +x /kubectl-auth.sh
ENTRYPOINT ["/kubectl-auth.sh"]
