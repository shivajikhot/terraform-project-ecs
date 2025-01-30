# Use the official Node.js image as the base image
FROM node:16-slim

# Set the working directory inside the container
WORKDIR /app
RUN npm install express
# Copy the appointment service file into the container
COPY appointment-service.js .

# Expose the port that your service will run on
EXPOSE 90

# Run the appointment service when the container starts
CMD ["node", "appointment-service.js"]
