# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    NODE_ENV=production \
    NGINX_VERSION=1.21.6

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mariadb-client \
    mariadb-server \
    nginx \
    redis-server \
    supervisor \
    wget \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    libmysqlclient-dev \
    nodejs \
    npm

# Install wkhtmltopdf
RUN apt-get install -y xfonts-75dpi xfonts-base \
    && wget -q https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb \
    && apt-get -f install -y \
    && rm -rf wkhtmltox_0.12.6-1.bionic_amd64.deb

# Install Yarn
RUN npm install -g yarn

# Create a directory for the application
RUN mkdir -p /home/frappe
WORKDIR /home/frappe

# Install Frappe bench
RUN pip install frappe-bench

# Initialize a new bench
RUN bench init frappe-bench --frappe-branch version-13

WORKDIR /home/frappe/frappe-bench

# Create a new site (replace 'yoursite.local' with your site name)
RUN bench new-site frappe.local --admin-password admin --mariadb-root-password root

# Get the necessary node packages
RUN yarn

# Start the bench
CMD ["bench", "start"]

# Expose necessary ports
EXPOSE 8000 9000 3306 6379
