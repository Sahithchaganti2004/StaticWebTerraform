# Use an official NGINX image to serve the static website
FROM nginx:alpine

# Remove default NGINX configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom NGINX configuration (optional)
#COPY nginx.conf /etc/nginx/conf.d/

# Copy the static site files into the NGINX web directory
COPY ./index.html /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
