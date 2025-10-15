# Use official n8n image as base
FROM n8nio/n8n:1.113.3

# Switch to root to install packages
USER root

# Install wget (needed to download language files)
RUN apk add --no-cache wget

# Install Tesseract OCR and available language packs from Alpine
RUN apk add --no-cache \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-hin

# Download missing language traineddata files manually
RUN wget -O /usr/share/tessdata/asm.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/asm.traineddata && \
    wget -O /usr/share/tessdata/ben.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/ben.traineddata && \
    wget -O /usr/share/tessdata/guj.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/guj.traineddata && \
    wget -O /usr/share/tessdata/kan.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/kan.traineddata && \
    wget -O /usr/share/tessdata/kas.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/kas.traineddata && \
    wget -O /usr/share/tessdata/mal.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/mal.traineddata && \
    wget -O /usr/share/tessdata/mni.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/mni.traineddata && \
    wget -O /usr/share/tessdata/mar.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/mar.traineddata && \
    wget -O /usr/share/tessdata/ori.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/ori.traineddata && \
    wget -O /usr/share/tessdata/pan.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/pan.traineddata && \
    wget -O /usr/share/tessdata/tel.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/tel.traineddata && \
    wget -O /usr/share/tessdata/tam.traineddata https://github.com/tesseract-ocr/tessdata/raw/main/tam.traineddata

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
