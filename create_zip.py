import os
import zipfile
import sys

def create_codes_zip():
    zip_path = 'codes.zip'
    file_count = 0
    
    try:
        # Remove existing zip if exists
        if os.path.exists(zip_path):
            os.remove(zip_path)
            sys.stdout.write('Removed existing codes.zip\n')
            sys.stdout.flush()
        
        # Create zip file
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Walk through lib directory
            for root, dirs, files in os.walk('lib'):
                for file in files:
                    if file.endswith('.dart'):
                        file_path = os.path.join(root, file)
                        # Add to zip with relative path
                        arcname = os.path.relpath(file_path, '.')
                        zipf.write(file_path, arcname)
                        file_count += 1
                        sys.stdout.write(f'Added: {arcname}\n')
                        sys.stdout.flush()
        
        sys.stdout.write(f'\n✅ codes.zip created successfully with {file_count} files!\n')
        sys.stdout.flush()
        
    except Exception as e:
        sys.stderr.write(f'Error: {str(e)}\n')
        sys.stderr.flush()
        sys.exit(1)

if __name__ == '__main__':
    create_codes_zip()

