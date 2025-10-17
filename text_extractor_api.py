#!/usr/bin/env python3
from flask import Flask, request, jsonify
from functools import wraps
from io import BytesIO
import base64
import PyPDF2
import docx

app = Flask(__name__)

# Secret token for authorization
API_TOKEN = "info-lipsas.in-n8n"

# Decorator to require Authorization header with correct Bearer token
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.headers.get("Authorization", None)
        if not auth or auth != f"Bearer {API_TOKEN}":
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/extract', methods=['POST'])
@require_auth
def extract_text():
    try:
        data = request.json
        binary_data = base64.b64decode(data['binary_data'])
        file_name = data['file_name']

        extracted_text = ""
        method_used = "none"
        error_msg = None

        if file_name.lower().endswith('.pdf'):
            pdf_stream = BytesIO(binary_data)
            reader = PyPDF2.PdfReader(pdf_stream)
            pages_text = [page.extract_text() or "" for page in reader.pages]
            extracted_text = "\n".join(pages_text).strip()
            method_used = "PyPDF2"
        elif file_name.lower().endswith('.docx'):
            doc_stream = BytesIO(binary_data)
            doc = docx.Document(doc_stream)
            paragraphs = [para.text for para in doc.paragraphs if para.text]
            extracted_text = "\n".join(paragraphs).strip()
            method_used = "python-docx"
        else:
            error_msg = "Unsupported file type"

        return jsonify({
            "file_name": file_name,
            "extracted_text": extracted_text,
            "method": method_used,
            "error": error_msg,
            "text_length": len(extracted_text) if extracted_text else 0
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5678)
