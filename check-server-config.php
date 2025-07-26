<?php
// Ghost CMS Server Configuration Checker
// Run this to see current PHP upload limits and server info

header('Content-Type: text/html; charset=utf-8');

echo "<h1>🔧 Ghost CMS Server Configuration Check</h1>";
echo "<style>
body { font-family: Arial, sans-serif; margin: 20px; }
.good { color: green; }
.bad { color: red; }
.warning { color: orange; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
</style>";

// Check PHP version
$phpVersion = phpversion();
echo "<h2>PHP Information</h2>";
echo "<p><strong>PHP Version:</strong> $phpVersion</p>";

// Check upload settings
echo "<h2>Upload Settings</h2>";
echo "<table>";
echo "<tr><th>Setting</th><th>Current Value</th><th>Recommended</th><th>Status</th></tr>";

$settings = [
    'upload_max_filesize' => ['current' => ini_get('upload_max_filesize'), 'recommended' => '100M'],
    'post_max_size' => ['current' => ini_get('post_max_size'), 'recommended' => '110M'],
    'max_execution_time' => ['current' => ini_get('max_execution_time'), 'recommended' => '600'],
    'max_input_time' => ['current' => ini_get('max_input_time'), 'recommended' => '600'],
    'memory_limit' => ['current' => ini_get('memory_limit'), 'recommended' => '256M'],
    'max_file_uploads' => ['current' => ini_get('max_file_uploads'), 'recommended' => '20']
];

foreach ($settings as $setting => $values) {
    $current = $values['current'];
    $recommended = $values['recommended'];
    
    // Convert to bytes for comparison
    $currentBytes = convertToBytes($current);
    $recommendedBytes = convertToBytes($recommended);
    
    $status = $currentBytes >= $recommendedBytes ? "<span class='good'>✓ Good</span>" : "<span class='bad'>✗ Needs Update</span>";
    
    echo "<tr>";
    echo "<td>$setting</td>";
    echo "<td>$current</td>";
    echo "<td>$recommended</td>";
    echo "<td>$status</td>";
    echo "</tr>";
}

echo "</table>";

// Check server software
echo "<h2>Server Information</h2>";
echo "<p><strong>Server Software:</strong> " . $_SERVER['SERVER_SOFTWARE'] . "</p>";
echo "<p><strong>Document Root:</strong> " . $_SERVER['DOCUMENT_ROOT'] . "</p>";

// Check directory permissions
echo "<h2>Directory Permissions</h2>";
$dirs = [
    '/var/www/sites/clitools.app/wwwroot/ghost/content',
    '/var/www/sites/clitools.app/wwwroot/ghost/content/images',
    '/var/www/sites/clitools.app/wwwroot/ghost/content/videos',
    '/var/www/sites/clitools.app/wwwroot/ghost/content/audio'
];

echo "<table>";
echo "<tr><th>Directory</th><th>Exists</th><th>Writable</th><th>Permissions</th></tr>";

foreach ($dirs as $dir) {
    $exists = is_dir($dir) ? "<span class='good'>✓ Yes</span>" : "<span class='bad'>✗ No</span>";
    $writable = is_writable($dir) ? "<span class='good'>✓ Yes</span>" : "<span class='bad'>✗ No</span>";
    $perms = is_dir($dir) ? substr(sprintf('%o', fileperms($dir)), -4) : 'N/A';
    
    echo "<tr>";
    echo "<td>$dir</td>";
    echo "<td>$exists</td>";
    echo "<td>$writable</td>";
    echo "<td>$perms</td>";
    echo "</tr>";
}

echo "</table>";

// Test file upload
echo "<h2>File Upload Test</h2>";
echo "<p>Current working directory: " . getcwd() . "</p>";
echo "<p>Upload temp directory: " . sys_get_temp_dir() . "</p>";
echo "<p>Disk free space: " . formatBytes(disk_free_space('.')) . "</p>";

// Configuration file recommendations
echo "<h2>🔧 Fix Instructions</h2>";

if (strpos($_SERVER['SERVER_SOFTWARE'], 'Apache') !== false) {
    echo "<h3>Apache Configuration:</h3>";
    echo "<p>Run this command:</p>";
    echo "<pre>sudo /var/www/sites/clitools.app/wwwroot/ghost/fix-upload-limits.sh</pre>";
    echo "<p>Or manually edit your .htaccess file in the ghost directory.</p>";
} elseif (strpos($_SERVER['SERVER_SOFTWARE'], 'nginx') !== false) {
    echo "<h3>Nginx Configuration:</h3>";
    echo "<p>1. Run the fix script:</p>";
    echo "<pre>sudo /var/www/sites/clitools.app/wwwroot/ghost/fix-upload-limits.sh</pre>";
    echo "<p>2. Copy the nginx config:</p>";
    echo "<pre>sudo cp /var/www/sites/clitools.app/wwwroot/ghost/nginx-server-block.conf /etc/nginx/sites-available/ghost</pre>";
}

echo "<h3>Manual PHP Configuration:</h3>";
echo "<p>Edit your php.ini file and add these values:</p>";
echo "<pre>";
echo "upload_max_filesize = 100M\n";
echo "post_max_size = 110M\n";
echo "max_execution_time = 600\n";
echo "max_input_time = 600\n";
echo "memory_limit = 256M\n";
echo "max_file_uploads = 20\n";
echo "</pre>";

echo "<p>Then restart your web server and PHP-FPM:</p>";
echo "<pre>";
echo "sudo systemctl restart nginx  # or apache2\n";
echo "sudo systemctl restart php8.1-fpm\n";
echo "</pre>";

// Helper functions
function convertToBytes($val) {
    $val = trim($val);
    $last = strtolower($val[strlen($val)-1]);
    $val = (int)$val;
    switch($last) {
        case 'g': $val *= 1024;
        case 'm': $val *= 1024;
        case 'k': $val *= 1024;
    }
    return $val;
}

function formatBytes($bytes, $precision = 2) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
        $bytes /= 1024;
    }
    return round($bytes, $precision) . ' ' . $units[$i];
}
?>