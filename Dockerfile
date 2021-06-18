FROM nginx:latest

# Install logrotate
RUN rm /var/log/nginx/access.log &&  rm /var/log/nginx/error.log && apt-get update && apt-get -y install logrotate procps vim && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/*

# Start nginx and cron as a service
CMD service cron start && nginx -g 'daemon off;'