-- Add CAD file support to models table
-- This migration adds support for uploading and processing CAD files

-- Add new columns to models table
ALTER TABLE models
ADD COLUMN IF NOT EXISTS cad_file_urls TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS source_files_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS model_type TEXT DEFAULT 'image_based',
ADD COLUMN IF NOT EXISTS cad_processing_notes TEXT;

-- Create index for model_type for better query performance
CREATE INDEX IF NOT EXISTS idx_models_model_type ON models(model_type);

-- Update RLS policies to allow CAD file uploads
-- The existing policies already handle user-specific access, so no changes needed

-- Update storage bucket policies for CAD files
-- CAD files will be stored in the same 3d-uploads bucket under user-specific paths

-- Grant necessary permissions for CAD file operations
-- These are already handled by the existing storage policies

-- Add comments for new columns
COMMENT ON COLUMN models.cad_file_urls IS 'Array of URLs for uploaded CAD files (PDF, DWG, DXF)';
COMMENT ON COLUMN models.source_files_count IS 'Number of source CAD files used for generation';
COMMENT ON COLUMN models.model_type IS 'Type of model generation: image_based or cad_based';
COMMENT ON COLUMN models.cad_processing_notes IS 'Additional notes from CAD processing pipeline';