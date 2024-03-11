# Use a base image that contains both Bash and Terraform
FROM zubairpathan/terraform_by_zubair:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Terraform files into the container
COPY openshift.tf .

# Copy the bash script into the container
COPY deploy.sh .

# Make the bash script executable
RUN chmod +x deploy.sh

# Execute the bash script when the container starts
CMD ["./deploy.sh"]
