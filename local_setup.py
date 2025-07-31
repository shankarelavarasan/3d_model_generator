#!/usr/bin/env python3
"""
Local Open-Source 3D Generation Pipeline Setup
This script sets up the complete CAD-to-3D generation pipeline using:
- OpenCascade for CAD processing
- Tencent Hunyuan3D for 3D mesh generation
- Local Flask server for API endpoints
"""

import os
import json
import subprocess
import sys
from pathlib import Path

class Local3DPipelineSetup:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.setup_dir = self.project_root / "local_pipeline"
        self.models_dir = self.setup_dir / "models"
        self.uploads_dir = self.setup_dir / "uploads"
        self.processed_dir = self.setup_dir / "processed"
        
    def create_directories(self):
        """Create necessary directories for the pipeline"""
        directories = [
            self.setup_dir,
            self.models_dir,
            self.uploads_dir,
            self.processed_dir,
            self.setup_dir / "logs",
            self.setup_dir / "temp",
            self.setup_dir / "cache"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"✓ Created directory: {directory}")
    
    def create_requirements_txt(self):
        """Create requirements.txt for Python dependencies"""
        requirements = [
            "flask==2.3.3",
            "flask-cors==4.0.0",
            "opencv-python==4.8.1.78",
            "numpy==1.24.3",
            "pillow==10.0.1",
            "python-opencascade==7.7.0",
            "requests==2.31.0",
            "gunicorn==21.2.0",
            "prometheus-client==0.17.1",
            "pydantic==2.4.2",
            "uvicorn==0.23.2",
            "fastapi==0.104.1",
            "aiofiles==23.2.1"
        ]
        
        req_file = self.setup_dir / "requirements.txt"
        with open(req_file, 'w') as f:
            f.write('\n'.join(requirements))
        print(f"✓ Created requirements.txt")
    
    def create_cad_processor(self):
        """Create the CAD processing service"""
        cad_processor = '''
import os
import json
import logging
from pathlib import Path
from typing import List, Dict, Any
import subprocess
import tempfile
from flask import Flask, request, jsonify
from flask_cors import CORS
import uuid

app = Flask(__name__)
CORS(app)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CADProcessor:
    def __init__(self):
        self.upload_dir = Path("uploads")
        self.output_dir = Path("processed")
        self.temp_dir = Path("temp")
        
    def validate_cad_file(self, file_path: str) -> Dict[str, Any]:
        """Validate CAD file format and integrity"""
        file_path = Path(file_path)
        extension = file_path.suffix.lower()
        
        valid_extensions = ['.pdf', '.dwg', '.dxf', '.step', '.stp', '.iges', '.igs']
        
        if extension not in valid_extensions:
            return {"valid": False, "error": f"Unsupported file format: {extension}"}
        
        # Check file size (max 50MB)
        file_size_mb = file_path.stat().st_size / (1024 * 1024)
        if file_size_mb > 50:
            return {"valid": False, "error": "File too large (max 50MB)"}
        
        return {"valid": True, "format": extension, "size_mb": file_size_mb}
    
    def process_pdf(self, file_path: str) -> Dict[str, Any]:
        """Process PDF files (architectural drawings)"""
        try:
            # Convert PDF to images for processing
            import fitz  # PyMuPDF
            
            doc = fitz.open(file_path)
            images = []
            
            for page_num in range(len(doc)):
                page = doc.load_page(page_num)
                pix = page.get_pixmap()
                img_path = self.temp_dir / f"page_{page_num}.png"
                pix.save(str(img_path))
                images.append(str(img_path))
            
            doc.close()
            
            return {
                "success": True,
                "images": images,
                "pages": len(doc),
                "type": "pdf"
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def process_dwg(self, file_path: str) -> Dict[str, Any]:
        """Process DWG files using OpenCascade"""
        try:
            # Use OpenCascade's DRAWEXE for DWG processing
            output_file = self.output_dir / f"{uuid.uuid4()}.step"
            
            cmd = [
                "DRAWEXE",
                "-c", f"read {file_path}; write {output_file}; exit"
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                return {
                    "success": True,
                    "output_file": str(output_file),
                    "type": "dwg"
                }
            else:
                return {"success": False, "error": result.stderr}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def process_step(self, file_path: str) -> Dict[str, Any]:
        """Process STEP files directly"""
        try:
            # STEP files are already in a good format for 3D generation
            return {
                "success": True,
                "output_file": file_path,
                "type": "step"
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def get_processing_recommendations(self, files: List[str]) -> Dict[str, Any]:
        """Get recommendations for processing based on file types"""
        total_files = len(files)
        file_types = [Path(f).suffix.lower() for f in files]
        
        # Estimate processing time
        base_time = 30  # seconds per file
        complexity_multiplier = {
            '.pdf': 2.0,
            '.dwg': 3.0,
            '.dxf': 2.5,
            '.step': 1.5,
            '.iges': 1.8
        }
        
        estimated_time = sum(complexity_multiplier.get(ext, 2.0) for ext in file_types)
        estimated_time = max(30, int(estimated_time * base_time))
        
        return {
            "estimated_time": f"{estimated_time}s",
            "total_files": total_files,
            "file_types": list(set(file_types)),
            "recommendations": [
                "Ensure files are not corrupted",
                "Check file dimensions are reasonable",
                "Verify coordinate systems are consistent"
            ]
        }

processor = CADProcessor()

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "cad-processor"})

@app.route('/process-cad', methods=['POST'])
def process_cad():
    try:
        data = request.json
        files = data.get('files', [])
        model_id = data.get('model_id')
        
        if not files:
            return jsonify({"error": "No files provided"}), 400
        
        results = []
        for file_url in files:
            file_path = Path(file_url)
            
            # Validate file
            validation = processor.validate_cad_file(str(file_path))
            if not validation["valid"]:
                results.append({"file": str(file_path), "error": validation["error"]})
                continue
            
            # Process based on file type
            extension = file_path.suffix.lower()
            
            if extension == '.pdf':
                result = processor.process_pdf(str(file_path))
            elif extension in ['.dwg', '.dxf']:
                result = processor.process_dwg(str(file_path))
            elif extension in ['.step', '.stp', '.iges', '.igs']:
                result = processor.process_step(str(file_path))
            else:
                result = {"success": False, "error": "Unsupported format"}
            
            results.append({"file": str(file_path), **result})
        
        return jsonify({
            "success": True,
            "model_id": model_id,
            "results": results
        })
        
    except Exception as e:
        logger.error(f"Error processing CAD files: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/recommendations', methods=['POST'])
def get_recommendations():
    try:
        data = request.json
        files = data.get('files', [])
        
        recommendations = processor.get_processing_recommendations(files)
        return jsonify(recommendations)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
'''
        
        processor_file = self.setup_dir / "cad_processor.py"
        with open(processor_file, 'w') as f:
            f.write(cad_processor)
        print(f"✓ Created cad_processor.py")
    
    def create_hunyuan3d_client(self):
        """Create Hunyuan3D client wrapper"""
        client_code = '''
import os
import json
import requests
import time
import logging
from typing import Dict, Any, Optional
from pathlib import Path

class Hunyuan3DClient:
    def __init__(self, api_key: str = None, base_url: str = None, use_local: bool = True):
        self.api_key = api_key or os.getenv('HUNYUAN3D_API_KEY')
        self.base_url = base_url or (
            'http://localhost:8080' if use_local else 'https://api.hunyuan3d.com'
        )
        self.use_local = use_local
        self.logger = logging.getLogger(__name__)
    
    def generate_3d_model(self, 
                         input_files: list,
                         model_id: str,
                         output_format: str = 'glb',
                         quality: str = 'high',
                         options: Dict[str, Any] = None) -> Dict[str, Any]:
        """Generate 3D model using Hunyuan3D"""
        
        options = options or {}
        
        payload = {
            "model_id": model_id,
            "input_files": input_files,
            "output_format": output_format,
            "quality": quality,
            "options": {
                "mesh_resolution": options.get("mesh_resolution", "high"),
                "texture_quality": options.get("texture_quality", "high"),
                "coordinate_system": options.get("coordinate_system", "right_handed"),
                "unit_scale": options.get("unit_scale", "millimeters"),
                **options
            }
        }
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        try:
            if self.use_local:
                return self._generate_local(payload)
            else:
                return self._generate_remote(payload, headers)
        except Exception as e:
            self.logger.error(f"Generation failed: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def _generate_local(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Generate 3D model using local Hunyuan3D instance"""
        
        # Simulate local processing
        endpoint = f"{self.base_url}/generate"
        
        try:
            response = requests.post(endpoint, json=payload, timeout=600)
            response.raise_for_status()
            
            result = response.json()
            
            # Simulate processing time
            time.sleep(30)  # Replace with actual processing
            
            return {
                "success": True,
                "model_url": f"{self.base_url}/models/{payload['model_id']}/model.glb",
                "processing_time": 30,
                "vertices": 10000,
                "faces": 5000,
                "texture_size": "1024x1024"
            }
            
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": f"Local generation failed: {str(e)}"}
    
    def _generate_remote(self, payload: Dict[str, Any], headers: Dict[str, str]) -> Dict[str, Any]:
        """Generate 3D model using remote API"""
        
        endpoint = f"{self.base_url}/v1/generate"
        
        try:
            response = requests.post(endpoint, json=payload, headers=headers, timeout=600)
            response.raise_for_status()
            
            return response.json()
            
        except requests.exceptions.RequestException as e:
            return {"success": False, "error": f"Remote generation failed: {str(e)}"}
    
    def check_status(self, model_id: str) -> Dict[str, Any]:
        """Check generation status"""
        
        endpoint = f"{self.base_url}/status/{model_id}"
        headers = {"Authorization": f"Bearer {self.api_key}"} if not self.use_local else {}
        
        try:
            response = requests.get(endpoint, headers=headers)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def download_model(self, model_url: str, output_path: str) -> bool:
        """Download generated 3D model"""
        
        try:
            response = requests.get(model_url, stream=True)
            response.raise_for_status()
            
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            return True
            
        except Exception as e:
            self.logger.error(f"Download failed: {str(e)}")
            return False

# Usage example
if __name__ == "__main__":
    client = Hunyuan3DClient(use_local=True)
    
    # Test generation
    result = client.generate_3d_model(
        input_files=["test.dwg"],
        model_id="test-123",
        output_format="glb",
        quality="high"
    )
    
    print(json.dumps(result, indent=2))
'''
        
        client_file = self.setup_dir / "hunyuan3d_client.py"
        with open(client_file, 'w') as f:
            f.write(client_code)
        print(f"✓ Created hunyuan3d_client.py")
    
    def create_docker_compose(self):
        """Create Docker Compose configuration"""
        compose_config = '''
version: '3.8'

services:
  cad-processor:
    build:
      context: ./cad-processor
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./uploads:/app/uploads
      - ./processed:/app/processed
      - ./logs:/app/logs
    environment:
      - PYTHONPATH=/app
      - LOG_LEVEL=INFO
    restart: unless-stopped

  hunyuan3d:
    build:
      context: ./hunyuan3d
      dockerfile: Dockerfile.gpu
    ports:
      - "8080:8080"
    volumes:
      - ./models:/app/models
      - ./uploads:/app/uploads
      - ./cache:/app/cache
    environment:
      - CUDA_VISIBLE_DEVICES=0
      - PYTHONPATH=/app
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - cad-processor
      - hunyuan3d
    restart: unless-stopped

volumes:
  uploads:
  processed:
  models:
  cache:
'''
        
        compose_file = self.setup_dir / "docker-compose.yml"
        with open(compose_file, 'w') as f:
            f.write(compose_config)
        print(f"✓ Created docker-compose.yml")
    
    def create_startup_script(self):
        """Create startup script for local development"""
        startup_script = '''#!/bin/bash
# Local 3D Generation Pipeline Startup Script

set -e

echo "🚀 Starting Local 3D Generation Pipeline..."

# Check Python version
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "✓ Python version: $python_version"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
mkdir -p uploads processed logs temp cache

# Start CAD processor
nohup python cad_processor.py > logs/cad_processor.log 2>&1 &
echo "✓ CAD processor started on port 5000"

# Start Hunyuan3D (simulated)
echo "⚠️  Note: For real Hunyuan3D, run:"
echo "   cd Hunyuan3D-2 && python app.py --host 0.0.0.0 --port 8080"

# Wait for services to start
sleep 3

# Check if services are running
curl -s http://localhost:5000/health > /dev/null && echo "✓ CAD processor is healthy" || echo "❌ CAD processor failed"

echo ""
echo "🎉 Pipeline is ready!"
echo "   CAD Processor: http://localhost:5000"
echo "   Health check: curl http://localhost:5000/health"
echo "   Test processing: curl -X POST http://localhost:5000/process-cad -H 'Content-Type: application/json' -d '{\"files\":[\"test.dwg\"],\"model_id\":\"test-123\"}'"
'''
        
        script_file = self.setup_dir / "start_pipeline.sh"
        with open(script_file, 'w') as f:
            f.write(startup_script)
        
        # Make script executable
        os.chmod(script_file, 0o755)
        print(f"✓ Created start_pipeline.sh")
    
    def create_test_files(self):
        """Create test configuration and sample files"""
        test_config = {
            "test_files": {
                "pdf_sample": "https://example.com/sample_architectural.pdf",
                "dwg_sample": "https://example.com/sample_mechanical.dwg",
                "step_sample": "https://example.com/sample_3d.step"
            },
            "processing_options": {
                "mesh_quality": "high",
                "texture_resolution": "1024",
                "coordinate_system": "right_handed",
                "unit_scale": "millimeters"
            },
            "expected_output": {
                "formats": ["glb", "obj", "fbx"],
                "max_vertices": 50000,
                "max_file_size_mb": 10
            }
        }
        
        config_file = self.setup_dir / "test_config.json"
        with open(config_file, 'w') as f:
            json.dump(test_config, f, indent=2)
        print(f"✓ Created test_config.json")
    
    def run_setup(self):
        """Run the complete setup process"""
        print("🔧 Setting up Local Open-Source 3D Generation Pipeline...")
        print("=" * 60)
        
        self.create_directories()
        self.create_requirements_txt()
        self.create_cad_processor()
        self.create_hunyuan3d_client()
        self.create_docker_compose()
        self.create_startup_script()
        self.create_test_files()
        
        print("=" * 60)
        print("✅ Setup complete!")
        print("\nNext steps:")
        print("1. cd local_pipeline")
        print("2. ./start_pipeline.sh")
        print("3. Update Flutter app to use local endpoints")
        print("4. Test with sample CAD files")

if __name__ == "__main__":
    setup = Local3DPipelineSetup()
    setup.run_setup()