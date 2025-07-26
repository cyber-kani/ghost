#!/bin/bash

# Ghost CMS Upload Limits Fix Script
# Run this script with sudo to fix 413 Content Too Large errors

echo "🔧 Fixing Ghost CMS upload limits and 403 errors..."

# Create backup directory
mkdir -p /tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)

# 1. Fix file permissions first
echo "📁 Setting file permissions..."
chown -R www-data:www-data /var/www/sites/clitools.app/wwwroot/ghost
chmod -R 755 /var/www/sites/clitools.app/wwwroot/ghost

# Create and set permissions for upload directories
mkdir -p /var/www/sites/clitools.app/wwwroot/ghost/content/{images,videos,audio,files}
chown -R www-data:www-data /var/www/sites/clitools.app/wwwroot/ghost/content
chmod -R 777 /var/www/sites/clitools.app/wwwroot/ghost/content

# 2. Create nginx temp directory
mkdir -p /var/tmp/nginx_uploads
chown -R www-data:www-data /var/tmp/nginx_uploads
chmod 755 /var/tmp/nginx_uploads

# 3. Fix PHP configuration
echo "🐘 Updating PHP configuration..."

# Find PHP version
PHP_VERSION=$(php -v | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "Detected PHP version: $PHP_VERSION"

# Update PHP-FPM pool config
PHP_POOL_CONFIG="/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"
if [ -f "$PHP_POOL_CONFIG" ]; then
    cp "$PHP_POOL_CONFIG" "/tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)/www.conf.backup"
    
    # Add our settings to the pool config
    echo "" >> "$PHP_POOL_CONFIG"
    echo "; Ghost CMS Upload Settings" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[upload_max_filesize] = 100M" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[post_max_size] = 110M" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[max_execution_time] = 600" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[max_input_time] = 600" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[memory_limit] = 256M" >> "$PHP_POOL_CONFIG"
    echo "php_admin_value[max_file_uploads] = 20" >> "$PHP_POOL_CONFIG"
fi

# Update main PHP config
PHP_INI="/etc/php/$PHP_VERSION/fpm/php.ini"
if [ -f "$PHP_INI" ]; then
    cp "$PHP_INI" "/tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)/php.ini.backup"
    
    # Update PHP settings
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' "$PHP_INI"
    sed -i 's/post_max_size = .*/post_max_size = 110M/' "$PHP_INI"
    sed -i 's/max_execution_time = .*/max_execution_time = 600/' "$PHP_INI"
    sed -i 's/max_input_time = .*/max_input_time = 600/' "$PHP_INI"
    sed -i 's/memory_limit = .*/memory_limit = 256M/' "$PHP_INI"
    sed -i 's/max_file_uploads = .*/max_file_uploads = 20/' "$PHP_INI"
fi

# 4. Fix Apache configuration (if Apache is being used)
if command -v apache2 >/dev/null 2>&1; then
    echo "🌐 Updating Apache configuration..."
    
    # Enable required modules
    a2enmod rewrite headers
    
    # Update main Apache config
    APACHE_CONF="/etc/apache2/apache2.conf"
    if [ -f "$APACHE_CONF" ]; then
        cp "$APACHE_CONF" "/tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)/apache2.conf.backup"
        
        # Add settings if they don't exist
        if ! grep -q "LimitRequestBody 115343360" "$APACHE_CONF"; then
            echo "" >> "$APACHE_CONF"
            echo "# Ghost CMS Upload Settings" >> "$APACHE_CONF"
            echo "LimitRequestBody 115343360" >> "$APACHE_CONF"
            echo "TimeOut 600" >> "$APACHE_CONF"
            echo "KeepAliveTimeout 600" >> "$APACHE_CONF"
        fi
    fi
fi

# 5. Fix Nginx configuration (if Nginx is being used)
if command -v nginx >/dev/null 2>&1; then
    echo "🌐 Updating Nginx configuration..."
    
    NGINX_CONF="/etc/nginx/nginx.conf"
    if [ -f "$NGINX_CONF" ]; then
        cp "$NGINX_CONF" "/tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)/nginx.conf.backup"
        
        # Add upload settings to http block if not present
        if ! grep -q "client_max_body_size.*100M" "$NGINX_CONF"; then
            sed -i '/http {/a\\tclient_max_body_size 100M;\n\tclient_body_timeout 600s;\n\tclient_header_timeout 600s;\n\tclient_body_temp_path /var/tmp/nginx_uploads;' "$NGINX_CONF"
        fi
    fi
    
    # Copy our server block config
    if [ -f "/var/www/sites/clitools.app/wwwroot/ghost/nginx-server-block.conf" ]; then
        cp "/var/www/sites/clitools.app/wwwroot/ghost/nginx-server-block.conf" "/etc/nginx/sites-available/ghost"
        ln -sf "/etc/nginx/sites-available/ghost" "/etc/nginx/sites-enabled/ghost"
    fi
fi

# 6. Restart services
echo "🔄 Restarting services..."

if command -v php-fpm >/dev/null 2>&1; then
    systemctl restart php$PHP_VERSION-fpm
    echo "✅ PHP-FPM restarted"
fi

if command -v apache2 >/dev/null 2>&1; then
    systemctl restart apache2
    echo "✅ Apache restarted"
fi

if command -v nginx >/dev/null 2>&1; then
    nginx -t && systemctl restart nginx
    echo "✅ Nginx restarted"
fi

# 7. Test configuration
echo "🧪 Testing configuration..."

echo "Current PHP limits:"
php -r "echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;"
php -r "echo 'post_max_size: ' . ini_get('post_max_size') . PHP_EOL;"
php -r "echo 'max_execution_time: ' . ini_get('max_execution_time') . PHP_EOL;"

echo ""
echo "File permissions for upload directories:"
ls -la /var/www/sites/clitools.app/wwwroot/ghost/content/

echo ""
echo "✅ Configuration update complete!"
echo "📋 Backup files saved to: /tmp/ghost-config-backup/$(date +%Y%m%d_%H%M%S)/"
echo ""
echo "🔍 If you still get 413 errors, check these:"
echo "   1. Verify your web server (Apache/Nginx) is actually running"
echo "   2. Check if there's a load balancer or CDN with its own limits"
echo "   3. Verify the correct virtual host is being used"
echo "   4. Check server error logs for more details"
echo ""
echo "📝 Log locations:"
echo "   - Apache: /var/log/apache2/error.log"
echo "   - Nginx: /var/log/nginx/error.log"
echo "   - PHP-FPM: /var/log/php$PHP_VERSION-fpm.log"