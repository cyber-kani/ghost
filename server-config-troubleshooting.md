# Server Configuration Troubleshooting Guide

## 403 Forbidden & Upload Issues Fix

This guide covers how to fix 403 errors and increase file upload limits for the Ghost CMS implementation.

## Files Updated

1. **`.htaccess`** - Apache configuration (already updated)
2. **`nginx-server-block.conf`** - Nginx server block (already updated)
3. **`nginx.conf`** - General Nginx config (already updated)

## Manual Server Configuration Steps

### For Apache Servers

1. **Check if mod_rewrite is enabled:**
   ```bash
   sudo a2enmod rewrite
   sudo a2enmod headers
   sudo systemctl restart apache2
   ```

2. **Set proper directory permissions:**
   ```bash
   sudo chown -R www-data:www-data /var/www/sites/clitools.app/wwwroot/ghost
   sudo chmod -R 755 /var/www/sites/clitools.app/wwwroot/ghost
   sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content
   ```

3. **Check Apache main config** (`/etc/apache2/apache2.conf`):
   ```apache
   # Add these if not present:
   ServerTokens Prod
   ServerSignature Off
   
   # Increase limits globally
   LimitRequestBody 115343360
   TimeOut 600
   KeepAliveTimeout 600
   ```

4. **Virtual Host Configuration** (add to your site's vhost):
   ```apache
   <VirtualHost *:80>
       DocumentRoot /var/www/sites/clitools.app/wwwroot
       ServerName clitools.app
       
       <Directory "/var/www/sites/clitools.app/wwwroot">
           AllowOverride All
           Require all granted
       </Directory>
       
       # Large file upload settings
       LimitRequestBody 115343360
   </VirtualHost>
   ```

### For Nginx Servers

1. **Check main nginx.conf** (`/etc/nginx/nginx.conf`):
   ```nginx
   http {
       # Add these in the http block
       client_max_body_size 100M;
       client_body_timeout 600s;
       client_header_timeout 600s;
       keepalive_timeout 600s;
       send_timeout 600s;
       
       # Create temp directory
       client_body_temp_path /var/tmp/nginx_uploads;
   }
   ```

2. **Create temp directory:**
   ```bash
   sudo mkdir -p /var/tmp/nginx_uploads
   sudo chown -R www-data:www-data /var/tmp/nginx_uploads
   sudo chmod 755 /var/tmp/nginx_uploads
   ```

3. **Copy the server block config:**
   ```bash
   sudo cp /var/www/sites/clitools.app/wwwroot/ghost/nginx-server-block.conf /etc/nginx/sites-available/ghost
   sudo ln -s /etc/nginx/sites-available/ghost /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### For PHP-FPM (if using)

1. **Edit PHP-FPM pool config** (`/etc/php/8.1/fpm/pool.d/www.conf`):
   ```ini
   ; Increase these values
   php_admin_value[upload_max_filesize] = 100M
   php_admin_value[post_max_size] = 110M
   php_admin_value[max_execution_time] = 600
   php_admin_value[max_input_time] = 600
   php_admin_value[memory_limit] = 256M
   ```

2. **Edit main PHP config** (`/etc/php/8.1/fpm/php.ini`):
   ```ini
   upload_max_filesize = 100M
   post_max_size = 110M
   max_execution_time = 600
   max_input_time = 600
   memory_limit = 256M
   max_file_uploads = 20
   ```

3. **Restart PHP-FPM:**
   ```bash
   sudo systemctl restart php8.1-fpm
   ```

### For ColdFusion (if applicable)

1. **ColdFusion Administrator Settings:**
   - Go to ColdFusion Administrator → Server Settings → Request Tuning
   - Set "Maximum size of post data": 100 MB
   - Set "Request timeout": 600 seconds
   - Set "Template cache size": 256 MB

2. **Application.cfc settings** (already updated in the main file):
   ```cfml
   this.requestTimeOut = 600;
   this.sessionTimeout = createTimeSpan(0,2,0,0);
   ```

## File Permissions Fix

Run these commands to fix file permissions:

```bash
# Set ownership
sudo chown -R www-data:www-data /var/www/sites/clitools.app/wwwroot/ghost

# Set base permissions
sudo chmod -R 755 /var/www/sites/clitools.app/wwwroot/ghost

# Make upload directories writable
sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content
sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content/images
sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content/videos
sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content/audio

# Create missing directories if needed
sudo mkdir -p /var/www/sites/clitools.app/wwwroot/ghost/content/{images,videos,audio,files}
sudo chown -R www-data:www-data /var/www/sites/clitools.app/wwwroot/ghost/content
sudo chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content
```

## Testing Upload Limits

Create a test file to verify upload limits:

```bash
# Test with a 50MB file
dd if=/dev/zero of=/tmp/test50mb.txt bs=1M count=50

# Try uploading via curl
curl -X POST \
  -F "file=@/tmp/test50mb.txt" \
  https://clitools.app/ghost/admin/ajax/upload-image.cfm
```

## Common Error Codes & Solutions

- **403 Forbidden**: Check file permissions and directory ownership
- **413 Request Entity Too Large**: Increase client_max_body_size (Nginx) or LimitRequestBody (Apache)
- **408 Request Timeout**: Increase timeout values in server config
- **500 Internal Server Error**: Check server error logs for specific issues

## Log Locations

- **Apache**: `/var/log/apache2/error.log`
- **Nginx**: `/var/log/nginx/error.log`
- **PHP-FPM**: `/var/log/php8.1-fpm.log`
- **ColdFusion**: Check CF Administrator → Debugging & Logging → Log Files

## Verification Commands

```bash
# Check current PHP limits
php -i | grep -E "(upload_max_filesize|post_max_size|max_execution_time)"

# Check nginx config
sudo nginx -t

# Check Apache config
sudo apache2ctl configtest

# Check file permissions
ls -la /var/www/sites/clitools.app/wwwroot/ghost/content/

# Check disk space
df -h /var/www/sites/clitools.app/wwwroot/ghost/
```

## Summary of Changes Made

1. **Increased upload limits to 100MB** (from 20MB)
2. **Extended timeout to 600 seconds** (from 300s)
3. **Added proper directory permissions** for upload folders
4. **Enhanced error handling** with custom error pages
5. **Added CORS headers** for cross-origin uploads
6. **Improved buffer sizes** for large file handling
7. **Added file type support** for audio files