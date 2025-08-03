import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/upload_service.dart';
import '../../services/cad_processing_service.dart';
import '../../providers/model_provider.dart';
import '../../widgets/progress_indicator_widget.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uploadService = UploadService();
  final _picker = ImagePicker();
  
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'dwg', 'dxf'],
      allowMultiple: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
        // Limit to 3 files max
        if (_selectedFiles.length > 3) {
          _selectedFiles = _selectedFiles.take(3).toList();
        }
      });
    }
  }

  Future<void> _uploadModel() async {
    if (_selectedFiles.isEmpty || _titleController.text.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // Create model record with CAD file support
      final modelData = await Supabase.instance.client.from('models').insert({
        'user_id': userId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'original_image_url': '',
        'cad_file_urls': [],
        'status': 'pending',
        'model_type': 'cad_based',
      }).select().single();

      final modelId = modelData['id'];

      // Upload all CAD files
      final uploadedUrls = <String>[];
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        final fileUrl = await _uploadService.uploadCADFile(file, userId, modelId, i);
        uploadedUrls.add(fileUrl);
        
        setState(() {
          _uploadProgress = (i + 1) / _selectedFiles.length;
        });
      }
      
      // Update model with CAD file URLs
      await Supabase.instance.client
          .from('models')
          .update({'cad_file_urls': uploadedUrls})
          .eq('id', modelId);

      // Trigger 3D generation from CAD files
      await _trigger3DGenerationFromCAD(modelId, uploadedUrls);

      // Refresh models list
      if (mounted) {
        context.read<ModelProvider>().loadUserModels();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _trigger3DGenerationFromCAD(String modelId, List<String> cadFileUrls) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.1;
      });

      // Initialize CAD processing service with open-source APIs
      final cadProcessingService = CADProcessingService(
        apiKey: 'your-hunyuan3d-api-key', // Should be from environment config
        useLocal: false, // Set to true for local deployment
      );

      if (cadFileUrls.isEmpty) {
        throw Exception('No CAD files found for processing');
      }

      setState(() {
        _uploadProgress = 0.2;
      });

      // Get processing recommendations
      final recommendations = cadProcessingService.getProcessingRecommendations(cadFileUrls);
      
      // Update model with processing info
      await Supabase.instance.client
          .from('models')
          .update({
            'status': 'processing',
            'cad_processing_notes': 'Starting CAD processing with ${recommendations['estimated_time']} estimated time...',
          })
          .eq('id', modelId);

      setState(() {
        _uploadProgress = 0.3;
      });

      // Process CAD files using open-source pipeline
      final result = await cadProcessingService.processCADFiles(
        cadFileUrls: cadFileUrls,
        modelId: modelId,
        outputFormat: 'glb',
        quality: 'high',
        processingOptions: {
          'merge_strategy': 'automatic',
          'coordinate_system': 'unified',
          'validation_level': 'strict',
        },
      );

      if (result['success']) {
        setState(() {
          _uploadProgress = 0.9;
        });

        // Update model with generated 3D model
        await Supabase.instance.client
            .from('models')
            .update({
              'generated_model_url': result['model_url'],
              'status': 'completed',
              'cad_processing_notes': result['cad_processing_notes'],
            })
            .eq('id', modelId);

        setState(() {
          _uploadProgress = 1.0;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('3D model generated successfully using open-source APIs!')),
        );

        Navigator.pop(context);
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      await Supabase.instance.client
          .from('models')
          .update({
            'status': 'failed',
            'cad_processing_notes': 'Processing failed: $e',
          })
          .eq('id', modelId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CAD Files'),
      ),
      body: _isUploading
          ? ProgressIndicatorWidget(
              progress: _uploadProgress,
              message: 'Processing 3D model...',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedFiles.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_present, size: 40, color: Colors.blue),
                              const SizedBox(height: 8),
                              Text(
                                '${_selectedFiles.length} CAD file${_selectedFiles.length > 1 ? 's' : ''} selected',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ..._selectedFiles.map((file) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  path.basename(file.path),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                            ],
                          )
                        : const Center(child: Icon(Icons.add_file, size: 50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Model Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedFiles.isNotEmpty && !_isUploading ? _uploadModel : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Generate 3D Model from CAD Files'),
                  ),
                ],
              ),
            ),
    );
  }
}