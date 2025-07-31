from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json
import logging
from pathlib import Path
import tempfile
import subprocess
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
UPLOAD_FOLDER = 'uploads'
PROCESSED_FOLDER = 'processed'
ALLOWED_EXTENSIONS = {'pdf', 'dwg', 'dxf', 'step', 'stp', 'iges', 'igs', 'stl', 'obj'}

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def process_cad_file(filepath, output_format='obj'):
    """Process CAD file using OpenCascade"""
    try:
        # This is a placeholder for OpenCascade processing
        # In real implementation, use python-opencascade
        
        output_path = os.path.join(PROCESSED_FOLDER, 
                                 f"processed_{Path(filepath).stem}.{output_format}")
        
        # Simulate processing
        import time
        time.sleep(2)
        
        # Create dummy output file for demo
        with open(output_path, 'w') as f:
            f.write("# Processed CAD file\n")
            f.write("# OpenCascade processing placeholder\n")
        
        return {
            'success': True,
            'processed_file': output_path,
            'vertices': 1000,
            'faces': 500,
            'size': os.path.getsize(output_path)
        }
    except Exception as e:
        logger.error(f"Error processing CAD file: {str(e)}")
        return {'success': False, 'error': str(e)}

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'service': 'cad_processor'})

@app.route('/process-cad', methods=['POST'])
def process_cad():
    try:
        data = request.get_json()
        files = data.get('files', [])
        model_id = data.get('model_id', 'unknown')
        
        if not files:
            return jsonify({'success': False, 'error': 'No files provided'})
        
        processed_files = []
        for file_url in files:
            # In real implementation, download file from URL
            # For now, simulate processing
            result = process_cad_file(file_url)
            if result['success']:
                processed_files.append({
                    'original_url': file_url,
                    'processed_path': result['processed_file'],
                    'metadata': {
                        'vertices': result['vertices'],
                        'faces': result['faces'],
                        'size': result['size']
                    }
                })
        
        return jsonify({
            'success': True,
            'processed_files': processed_files,
            'model_id': model_id
        })
    except Exception as e:
        logger.error(f"Error in process_cad: {str(e)}")
        return jsonify({'success': False, 'error': str(e)})

@app.route('/recommendations', methods=['POST'])
def get_recommendations():
    try:
        data = request.get_json()
        files = data.get('files', [])
        
        recommendations = []
        estimated_time = 0
        
        for file in files:
            ext = file.split('.')[-1].lower()
            
            # Estimate processing time based on file type
            time_map = {
                'pdf': 30,
                'dwg': 45,
                'dxf': 35,
                'step': 25,
                'iges': 30,
                'stl': 15,
                'obj': 20
            }
            
            estimated_time += time_map.get(ext, 30)
            
            # Add specific recommendations
            if ext == 'pdf':
                recommendations.append('Ensure PDF contains vector graphics, not raster images')
            elif ext in ['dwg', 'dxf']:
                recommendations.append('Check for proper layer organization and clean geometry')
            elif ext in ['step', 'iges']:
                recommendations.append('Verify file integrity and surface quality')
        
        return jsonify({
            'success': True,
            'estimated_time': estimated_time,
            'recommendations': recommendations,
            'files': files
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)