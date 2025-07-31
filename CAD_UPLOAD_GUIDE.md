# CAD File Upload Guide

## Overview

This guide explains how to use the new CAD file upload functionality in your 3D model generator application. Users can now upload up to 3 CAD files (PDF, DWG, DXF) to generate 3D models.

## Supported File Types

- **PDF** (.pdf) - Technical drawings and blueprints
- **DWG** (.dwg) - AutoCAD drawing files
- **DXF** (.dxf) - AutoCAD Drawing Exchange Format

## Upload Process

1. **Navigate to Upload Screen**: Click the "+" button or "Upload CAD Files" option
2. **Select Files**: Choose up to 3 CAD files from your device
3. **Add Details**: Provide a title and description for your 3D model
4. **Upload**: Click "Generate 3D Model from CAD Files"
5. **Processing**: Wait for the 3D model generation to complete

## File Organization

Uploaded CAD files are stored in Supabase Storage with the following structure:
```
user_id/
├── cad_files/
│   ├── {model_id}_cad_1.pdf
│   ├── {model_id}_cad_2.dwg
│   └── {model_id}_cad_3.dxf
├── models/
│   └── {model_id}_model.obj
└── thumbnails/
    └── {model_id}_thumbnail.jpg
```

## Database Schema

The `models` table now includes:
- `cad_file_urls`: Array of URLs for uploaded CAD files
- `source_files_count`: Number of source CAD files used
- `model_type`: Either 'image_based' or 'cad_based'
- `cad_processing_notes`: Additional processing information

## API Integration

For production use, integrate with CAD-to-3D APIs such as:
- **Meshy.ai** - AI-powered 3D generation
- **Autodesk Forge** - Professional CAD processing
- **Onshape** - Cloud-based CAD platform

## Testing

### Local Testing
```bash
# Run the application
flutter run --web-hostname=0.0.0.0 --web-port=8080
```

### Upload Test Files
1. Create sample CAD files or use existing ones
2. Upload through the web interface
3. Verify files appear in Supabase Storage
4. Check database records are created correctly

## Security Considerations

- **RLS Policies**: Ensure Row Level Security is enabled for the `models` table
- **File Size Limits**: Configure Supabase Storage limits (max 100MB per file)
- **File Type Validation**: Validate file extensions and MIME types
- **User Quotas**: Implement upload limits per user

## Configuration

### Supabase Storage Bucket
Ensure your `3d-uploads` bucket is configured with:
- File size limit: 100MB
- Allowed MIME types: `application/pdf`, `application/acad`, `application/dxf`
- Public access for generated models

### Environment Variables
Update your `.env` file with:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Troubleshooting

### Common Issues

1. **File Upload Fails**
   - Check file size limits
   - Verify MIME type is supported
   - Ensure user is authenticated

2. **3D Generation Stuck**
   - Check Supabase Functions logs
   - Verify CAD processing API is accessible
   - Check network connectivity

3. **Files Not Appearing**
   - Verify storage bucket permissions
   - Check database connection
   - Ensure file URLs are correctly stored

### Debug Commands
```bash
# Check Supabase Storage
supabase storage ls 3d-uploads

# Check database records
supabase db query "SELECT * FROM models WHERE model_type = 'cad_based'"
```

## Next Steps

1. **Integrate Real 3D Generation**: Replace mock generation with actual CAD processing
2. **Add Preview**: Generate thumbnails for CAD files
3. **Enhance UI**: Add CAD file preview capabilities
4. **Batch Processing**: Support bulk uploads
5. **Version Control**: Track changes to CAD files

## Support

For issues or questions:
- Check the Supabase documentation
- Review Flutter file upload best practices
- Consult CAD processing API documentation