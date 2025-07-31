# Open Source 3D Generation Setup Guide

This guide explains how to set up the open-source 3D generation pipeline using Tencent Hunyuan3D and OpenCascade for CAD-to-3D conversion.

## Architecture Overview

```
CAD Files (PDF/DWG/DXF) → OpenCascade Preprocessing → Hunyuan3D → 3D Model (GLB/OBJ)
```

## Local Development Setup

### 1. Install Required Dependencies

#### OpenCascade (CAD Processing)
```bash
# Windows
choco install opencascade

# Linux
sudo apt-get install liboce-ocaf-dev

# macOS
brew install opencascade
```

#### Hunyuan3D (3D Generation)
```bash
# Clone Hunyuan3D repository
git clone https://github.com/Tencent/Hunyuan3D-2
cd Hunyuan3D-2

# Create conda environment
conda create -n hunyuan3d python=3.9
conda activate hunyuan3d

# Install dependencies
pip install -r requirements.txt

# Download pretrained models
python download_weights.py
```

### 2. Environment Configuration

Create `.env.local` file:
```bash
# Hunyuan3D Configuration
HUNYUAN3D_API_KEY=your_api_key_here
HUNYUAN3D_ENDPOINT=http://localhost:8080/generate
HUNYUAN3D_USE_LOCAL=true

# OpenCascade Configuration
OPENCASCADE_PATH=/usr/local/lib
OPENCASCADE_PYTHON_PATH=/usr/local/lib/python3.9/site-packages

# Local Processing Options
CAD_PROCESSING_MODE=local
CAD_MAX_FILE_SIZE=50MB
CAD_ALLOWED_TYPES=pdf,dwg,dxf,step,iges
```

### 3. Local Server Setup

#### Start Hunyuan3D Local Server
```bash
cd Hunyuan3D-2
python app.py --host 0.0.0.0 --port 8080
```

#### Start CAD Processing Server (Python)
Create `cad_server.py`:
```python
from flask import Flask, request, jsonify
import os
import subprocess
import json

app = Flask(__name__)

@app.route('/process-cad', methods=['POST'])
def process_cad():
    files = request.json.get('files', [])
    model_id = request.json.get('model_id')
    
    # Process CAD files using OpenCascade
    result = process_with_opencascade(files)
    
    # Generate 3D model using Hunyuan3D
    model_url = generate_with_hunyuan3d(result)
    
    return jsonify({
        'success': True,
        'model_url': model_url,
        'processing_time': result['processing_time']
    })

def process_with_opencascade(files):
    # OpenCascade processing logic here
    return {'processed_files': files, 'processing_time': 30}

def generate_with_hunyuan3d(processed_data):
    # Hunyuan3D generation logic here
    return 'https://your-server.com/models/generated.glb'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 4. Docker Setup (Alternative)

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  hunyuan3d:
    image: hunyuan3d:latest
    ports:
      - "8080:8080"
    volumes:
      - ./models:/app/models
      - ./uploads:/app/uploads
    environment:
      - CUDA_VISIBLE_DEVICES=0
      - PYTHONPATH=/app

  cad-processor:
    build: ./cad-processor
    ports:
      - "5000:5000"
    volumes:
      - ./uploads:/app/uploads
      - ./processed:/app/processed
```

### 5. Flutter App Configuration

Update `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const bool useLocalProcessing = true;
  static const String localHunyuan3dEndpoint = 'http://localhost:8080';
  static const String localCADEndpoint = 'http://localhost:5000';
  static const String remoteHunyuan3dEndpoint = 'https://api.hunyuan3d.com';
  
  static String get hunyuan3dEndpoint => 
      useLocalProcessing ? localHunyuan3dEndpoint : remoteHunyuan3dEndpoint;
      
  static String get cadEndpoint =>
      useLocalProcessing ? localCADEndpoint : remoteHunyuan3dEndpoint;
}
```

## Production Deployment

### Cloud Deployment Options

#### 1. AWS EC2 with GPU
```bash
# Launch GPU instance (g4dn.xlarge recommended)
aws ec2 run-instances --image-id ami-0abcdef1234567890 --instance-type g4dn.xlarge

# Setup on instance
sudo apt update && sudo apt install -y docker.io nvidia-docker2
sudo systemctl restart docker

# Deploy services
docker-compose up -d
```

#### 2. Google Cloud Run
```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/hunyuan3d', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/hunyuan3d']
  - name: 'gcr.io/cloud-builders/gcloud'
    args: ['run', 'deploy', 'hunyuan3d', '--image', 'gcr.io/$PROJECT_ID/hunyuan3d', '--platform', 'managed']
```

### 3. Hugging Face Spaces
```python
# Create app.py for Hugging Face Spaces
import gradio as gr
from hunyuan3d import Hunyuan3D

model = Hunyuan3D()

def generate_3d(image):
    result = model.generate(image)
    return result

interface = gr.Interface(
    fn=generate_3d,
    inputs=gr.Image(type="filepath"),
    outputs=gr.Model3D(),
    title="Hunyuan3D CAD to 3D",
    description="Generate 3D models from CAD files"
)

interface.launch()
```

## File Processing Pipeline

### Supported Formats
- **PDF**: Architectural drawings, technical specifications
- **DWG**: AutoCAD drawings (2D/3D)
- **DXF**: Drawing exchange format
- **STEP**: 3D CAD models
- **IGES**: Initial Graphics Exchange Specification

### Processing Stages
1. **Validation**: Check file integrity and format
2. **Extraction**: Extract geometry and metadata
3. **Conversion**: Convert to intermediate format (STL/OBJ)
4. **Generation**: Use Hunyuan3D for mesh generation
5. **Optimization**: Reduce polygon count, add textures
6. **Export**: Final 3D model in GLB/OBJ format

## Monitoring & Logging

### Setup Prometheus + Grafana
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'hunyuan3d'
    static_configs:
      - targets: ['localhost:8080']
  - job_name: 'cad-processor'
    static_configs:
      - targets: ['localhost:5000']
```

### Health Check Endpoints
- `GET /health` - Service health status
- `GET /metrics` - Prometheus metrics
- `GET /api/v1/status` - Processing queue status

## Troubleshooting

### Common Issues
1. **CUDA out of memory**: Reduce batch size or use smaller models
2. **CAD file parsing errors**: Check file format compatibility
3. **Slow processing**: Use GPU acceleration or optimize parameters

### Debug Commands
```bash
# Check service status
curl http://localhost:8080/health
curl http://localhost:5000/health

# Test CAD processing
curl -X POST http://localhost:5000/process-cad \
  -H "Content-Type: application/json" \
  -d '{"files": ["test.dwg"], "model_id": "test-123"}'
```

## Next Steps

1. Set up local development environment
2. Test with sample CAD files
3. Configure cloud deployment
4. Add monitoring and alerting
5. Implement user feedback system

For detailed API documentation, see `docs/API.md`.