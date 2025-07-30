<!--- SEO Image Naming Test Tool --->
<!DOCTYPE html>
<html>
<head>
    <title>SEO Image Naming Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; max-width: 1200px; margin: 0 auto; }
        .test-section { background: #f5f5f5; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
        .example { background: white; padding: 15px; margin: 10px 0; border-radius: 3px; border: 1px solid #ddd; }
        .example h4 { margin-top: 0; color: #0066cc; }
        code { background: #f0f0f0; padding: 2px 5px; border-radius: 3px; font-family: monospace; }
        .success { color: #28a745; }
        .info { color: #17a2b8; }
        .warning { color: #ffc107; }
        .recent-uploads { margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f0f0f0; font-weight: bold; }
        .filename { font-family: monospace; background: #f9f9f9; padding: 2px 5px; }
        .old { color: #666; text-decoration: line-through; }
        .new { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <h1>SEO Image Naming Test & Examples</h1>
    
    <div class="test-section">
        <h2>How SEO Image Naming Works</h2>
        <p>The system automatically generates SEO-friendly filenames based on the following priority:</p>
        <ol>
            <li><strong>Alt Text</strong> (highest priority)</li>
            <li><strong>Post Title</strong> (if no alt text)</li>
            <li><strong>Image Type</strong> (e.g., "feature-image", "content-image")</li>
            <li><strong>Original Filename</strong> (fallback)</li>
        </ol>
        <p>All filenames are:</p>
        <ul>
            <li>Converted to lowercase</li>
            <li>Special characters replaced with hyphens</li>
            <li>Limited to 60 characters (breaking at word boundaries)</li>
            <li>Appended with a unique 8-character ID to prevent conflicts</li>
        </ul>
    </div>
    
    <div class="test-section">
        <h2>Examples</h2>
        
        <div class="example">
            <h4>Example 1: With Alt Text</h4>
            <p><strong>Input:</strong></p>
            <ul>
                <li>Original file: <code class="old">IMG_4235.jpg</code></li>
                <li>Post Title: <code>"Summer Vacation 2024"</code></li>
                <li>Alt Text: <code>"Beautiful sunset over the ocean with palm trees"</code></li>
            </ul>
            <p><strong>Result:</strong> <code class="new">beautiful-sunset-over-the-ocean-with-palm-trees-a1b2c3d4.jpg</code></p>
            <p class="success">✓ SEO optimized using alt text</p>
        </div>
        
        <div class="example">
            <h4>Example 2: With Post Title Only</h4>
            <p><strong>Input:</strong></p>
            <ul>
                <li>Original file: <code class="old">photo.png</code></li>
                <li>Post Title: <code>"10 Best Coffee Shops in New York City"</code></li>
                <li>Alt Text: <em>(empty)</em></li>
            </ul>
            <p><strong>Result:</strong> <code class="new">10-best-coffee-shops-in-new-york-city-e5f6g7h8.png</code></p>
            <p class="success">✓ SEO optimized using post title</p>
        </div>
        
        <div class="example">
            <h4>Example 3: Long Title (Truncated)</h4>
            <p><strong>Input:</strong></p>
            <ul>
                <li>Original file: <code class="old">screenshot.webp</code></li>
                <li>Post Title: <code>"The Complete Guide to Understanding Machine Learning Algorithms and Their Applications in Modern Business"</code></li>
                <li>Alt Text: <em>(empty)</em></li>
            </ul>
            <p><strong>Result:</strong> <code class="new">the-complete-guide-to-understanding-machine-learning-i9j0k1l2.webp</code></p>
            <p class="info">ℹ Truncated at word boundary to fit 60 character limit</p>
        </div>
        
        <div class="example">
            <h4>Example 4: Special Characters</h4>
            <p><strong>Input:</strong></p>
            <ul>
                <li>Original file: <code class="old">image@2x.jpg</code></li>
                <li>Post Title: <code>"What's New in PHP 8.3? Features & Performance!"</code></li>
                <li>Alt Text: <em>(empty)</em></li>
            </ul>
            <p><strong>Result:</strong> <code class="new">what-s-new-in-php-8-3-features-performance-m3n4o5p6.jpg</code></p>
            <p class="success">✓ Special characters converted to hyphens</p>
        </div>
        
        <div class="example">
            <h4>Example 5: Feature Image Default</h4>
            <p><strong>Input:</strong></p>
            <ul>
                <li>Original file: <code class="old">upload.gif</code></li>
                <li>Post Title: <em>(empty)</em></li>
                <li>Alt Text: <em>(empty)</em></li>
                <li>Type: <code>feature</code></li>
            </ul>
            <p><strong>Result:</strong> <code class="new">feature-image-q7r8s9t0.gif</code></p>
            <p class="warning">⚠ Using type-based naming (no context provided)</p>
        </div>
    </div>
    
    <div class="test-section">
        <h2>SEO Benefits</h2>
        <ul>
            <li><strong>Better Search Rankings:</strong> Descriptive filenames help search engines understand image content</li>
            <li><strong>Improved Accessibility:</strong> Alt text in filenames aids screen readers</li>
            <li><strong>User Experience:</strong> Clear filenames make content management easier</li>
            <li><strong>Social Sharing:</strong> Descriptive URLs look better when shared</li>
        </ul>
    </div>
    
    <div class="test-section">
        <h2>Test the System</h2>
        <p>Ready to test the SEO image naming?</p>
        <p><a href="/ghost/testing/test-image-upload.cfm" style="display: inline-block; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">Go to Image Upload Test →</a></p>
    </div>
    
    <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
        <div class="recent-uploads">
            <h2>Recent Uploads</h2>
            <!--- Get recent images from the uploads directory --->
            <cftry>
                <cfset currentYear = year(now())>
                <cfset currentMonth = numberFormat(month(now()), '00')>
                <cfset uploadPath = expandPath("/ghost/content/images/#currentYear#/#currentMonth#/")>
                
                <cfif directoryExists(uploadPath)>
                    <cfdirectory action="list" directory="#uploadPath#" name="qImages" filter="*.jpg,*.jpeg,*.png,*.gif,*.webp" sort="dateLastModified DESC">
                    
                    <cfif qImages.recordCount>
                        <table>
                            <tr>
                                <th>Filename</th>
                                <th>Size</th>
                                <th>Uploaded</th>
                                <th>Preview</th>
                            </tr>
                            <cfloop query="qImages" endrow="10">
                                <tr>
                                    <td class="filename">#name#</td>
                                    <td>#numberFormat(size/1024, "0.0")# KB</td>
                                    <td>#dateFormat(dateLastModified, "mmm dd")# #timeFormat(dateLastModified, "HH:nn")#</td>
                                    <td><a href="/ghost/content/images/#currentYear#/#currentMonth#/#name#" target="_blank">View</a></td>
                                </tr>
                            </cfloop>
                        </table>
                    <cfelse>
                        <p>No images uploaded this month yet.</p>
                    </cfif>
                <cfelse>
                    <p>Upload directory not found for current month.</p>
                </cfif>
            <cfcatch>
                <p>Unable to retrieve recent uploads.</p>
            </cfcatch>
            </cftry>
        </div>
    </cfif>
</body>
</html>