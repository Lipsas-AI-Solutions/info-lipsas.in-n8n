#!/usr/bin/env python3
import sys
import json
import base64
from io import BytesIO
import PyPDF2
import docx

# Read input from stdin (n8n passes data via stdin)
input_data = json.loads(sys.stdin.read())

# Get binary data (base64 encoded from n8n)
binary_data = base64.b64decode(input_data[0]['binary']['data']['data'])
file_name = input_data[0]['binary']['data']['fileName']

extracted_text = ""
method_used = "none"
error_msg = None

try:
    if file_name.lower().endswith('.pdf'):
        pdf_stream = BytesIO(binary_data)
        reader = PyPDF2.PdfReader(pdf_stream)
        pages_text = []
        for page in reader.pages:
            pages_text.append(page.extract_text() or "")
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
        
except Exception as e:
    error_msg = str(e)
    extracted_text = None

result = {
    "file_name": file_name,
    "extracted_text": extracted_text,
    "method": method_used,
    "error": error_msg,
    "text_length": len(extracted_text) if extracted_text else 0
}

print(json.dumps([result]))
