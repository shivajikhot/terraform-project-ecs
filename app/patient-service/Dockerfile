# Use the official Node.js image as the base image
FROM node:16-slim

# Set the working directory inside the container
WORKDIR /app
RUN pwd
# Copy the patient service file into the container
COPY patient-service.js .

# Expose the port that your service will run on
EXPOSE 80

# Run the patient service when the container starts
CMD ["node", "patient-service.js"]
