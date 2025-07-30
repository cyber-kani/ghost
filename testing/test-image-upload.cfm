<!--- Test Image Upload --->
<cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Image Upload</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .upload-area { border: 2px dashed #ccc; padding: 40px; text-align: center; margin: 20px 0; }
            .result { margin-top: 20px; padding: 20px; background: #f5f5f5; }
            .error { background: #ffebee; color: #c62828; }
            .success { background: #e8f5e9; color: #2e7d32; }
        </style>
    </head>
    <body>
        <h1>Test Feature Image Upload (SEO Optimized)</h1>
        
        <div style="margin-bottom: 20px; padding: 20px; background: #e3f2fd; border-radius: 5px;">
            <h3>SEO Context (Optional)</h3>
            <p style="margin-bottom: 10px;">
                <label>Post Title: <input type="text" id="postTitle" placeholder="e.g., Summer Beach Vacation Guide" style="width: 300px; padding: 5px;"></label>
            </p>
            <p>
                <label>Alt Text: <input type="text" id="altText" placeholder="e.g., Beautiful sunset at the beach" style="width: 300px; padding: 5px;"></label>
            </p>
            <p style="font-size: 12px; color: #666; margin-top: 10px;">
                Priority: Alt Text > Post Title > Original filename. The system will generate an SEO-friendly filename like: "beautiful-sunset-at-the-beach-a1b2c3d4.jpg"
            </p>
        </div>
        
        <div class="upload-area">
            <p>Select an image to test upload functionality</p>
            <input type="file" id="testImage" accept="image/*" onchange="testUpload()">
        </div>
        
        <div id="result"></div>
        
        <script>
        function testUpload() {
            const input = document.getElementById('testImage');
            const resultDiv = document.getElementById('result');
            
            if (input.files && input.files[0]) {
                const file = input.files[0];
                
                resultDiv.innerHTML = '<p>Uploading...</p>';
                
                const formData = new FormData();
                formData.append('file', file);
                formData.append('type', 'feature');
                
                // Add SEO context
                const postTitle = document.getElementById('postTitle').value;
                const altText = document.getElementById('altText').value;
                
                if (postTitle) {
                    formData.append('postTitle', postTitle);
                }
                if (altText) {
                    formData.append('altText', altText);
                }
                
                // Log what we're sending
                console.log('Uploading file:', file.name);
                console.log('File type:', file.type);
                console.log('File size:', file.size);
                
                fetch('/ghost/admin/ajax/upload-image.cfm', {
                    method: 'POST',
                    body: formData
                })
                .then(response => {
                    console.log('Response status:', response.status);
                    return response.text();
                })
                .then(text => {
                    console.log('Raw response:', text);
                    try {
                        const data = JSON.parse(text);
                        if (data.success) {
                            resultDiv.className = 'result success';
                            resultDiv.innerHTML = `
                                <h3>Upload Successful!</h3>
                                <p><strong>URL:</strong> ${data.url}</p>
                                <p><strong>Filename:</strong> ${data.filename}</p>
                                <img src="${data.url}" style="max-width: 300px; margin-top: 10px;">
                            `;
                        } else {
                            resultDiv.className = 'result error';
                            resultDiv.innerHTML = `
                                <h3>Upload Failed</h3>
                                <p><strong>Error:</strong> ${data.message}</p>
                                <p><strong>Detail:</strong> ${data.detail || 'No additional details'}</p>
                            `;
                        }
                    } catch (e) {
                        resultDiv.className = 'result error';
                        resultDiv.innerHTML = `
                            <h3>Parse Error</h3>
                            <p>Could not parse response</p>
                            <pre>${text}</pre>
                        `;
                    }
                })
                .catch(error => {
                    resultDiv.className = 'result error';
                    resultDiv.innerHTML = `
                        <h3>Network Error</h3>
                        <p>${error.message}</p>
                    `;
                    console.error('Upload error:', error);
                });
            }
        }
        </script>
    </body>
    </html>
<cfelse>
    <p>Please log in to test image upload</p>
</cfif>