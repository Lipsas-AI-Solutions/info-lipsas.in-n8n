# Use official n8n image as base
FROM n8nio/n8n:1.113.3

# Switch to root to install packages
USER root

# Install Python and pip
RUN apk add --no-cache python3 py3-pip

# Copy requirements.txt for Python packages
COPY requirements.txt /tmp/requirements.txt

# Install Python packages
RUN pip3 install --break-system-packages -r /tmp/requirements.txt || \
    pip3 install -r /tmp/requirements.txt

# Example: To add community nodes in future, uncomment and modify:
# RUN cd /usr/local/lib/node_modules/n8n && npm install n8n-nodes-notion

# Switch back to n8n user for security
USER node

# Use n8n's default start command
CMD ["n8n", "start"]
