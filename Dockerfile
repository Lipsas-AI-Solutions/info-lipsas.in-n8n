# Use official n8n image as base
FROM n8nio/n8n:1.113.3

# Switch to root to install system dependencies and Python packages
USER root

# Set database type to PostgreSQL (Railway injects the actual connection string)
ENV DB_TYPE=postgresdb

# Install system dependencies for OCR/text extraction and Python3
RUN apk add --no-cache \
    wget \
    ca-certificates \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-hin \
    python3 \
    py3-pip

# Download extra tessdata language models for Indian languages
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

# Copy requirements.txt for Python dependencies
COPY requirements.txt /tmp/requirements.txt

# Install Python packages for document processing and flask API
RUN pip3 install --break-system-packages -r /tmp/requirements.txt || pip3 install -r /tmp/requirements.txt

# Copy Flask API script into image
COPY text_extractor_api.py /app/text_extractor_api.py
RUN chmod +x /app/text_extractor_api.py

# Copy the startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Use the custom startup script as entrypoint
CMD ["/app/start.sh"]
