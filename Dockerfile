# Use official n8n image as base
FROM n8nio/n8n:1.113.3

# Switch to root to install packages
USER root

# Set database type to PostgreSQL
ENV DB_TYPE=postgresdb

# Install system dependencies
RUN apk add --no-cache \
    wget \
    ca-certificates \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-hin \
    python3 \
    py3-pip

# Download missing Tesseract language traineddata files
RUN wget -O /usr/share/tessdata/asm.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/asm.traineddata && \
    wget -O /usr/share/tessdata/ben.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/ben.traineddata && \
    wget -O /usr/share/tessdata/guj.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/guj.traineddata && \
    wget -O /usr/share/tessdata/kan.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/kan.traineddata && \
    wget -O /usr/share/tessdata/mal.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/mal.traineddata && \
    wget -O /usr/share/tessdata/mar.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/mar.traineddata && \
    wget -O /usr/share/tessdata/ori.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/ori.traineddata && \
    wget -O /usr/share/tessdata/pan.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/pan.traineddata && \
    wget -O /usr/share/tessdata/tel.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/tel.traineddata && \
    wget -O /usr/share/tessdata/tam.traineddata https://github.com/tesseract-ocr/tessdata_fast/raw/main/tam.traineddata

# Copy requirements.txt
COPY requirements.txt /tmp/requirements.txt

# Install Python packages
RUN pip3 install --break-system-packages -r /tmp/requirements.txt || \
    pip3 install -r /tmp/requirements.txt

# Switch back to node user
USER node

# Use n8n's default start command
CMD ["n8n", "start"]

# Create startup script that runs both Flask API and n8n
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'python3 /app/text_extractor_api.py &' >> /app/start.sh && \
    echo 'n8n start' >> /app/start.sh && \
    chmod +x /app/start.sh

# Use the startup script as entrypoint
CMD ["/app/start.sh"]
