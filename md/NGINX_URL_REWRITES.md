# Nginx URL Rewrites for cloudcoder.dev/ghost

This document contains all the URL rewrite rules configured in Nginx for the Ghost CMS application.

## Admin URLs

### Basic Admin Routes
```nginx
# Main admin interface
rewrite ^/ghost/admin/?$ /ghost/admin/index.cfm last;
rewrite ^/ghost/admin/dashboard/?$ /ghost/admin/index.cfm last;

# Authentication
rewrite ^/ghost/admin/login/?$ /ghost/admin/login.cfm last;
rewrite ^/ghost/admin/logout/?$ /ghost/admin/logout.cfm last;
```

### Posts Management
```nginx
# Posts listing and operations
rewrite ^/ghost/admin/posts/?$ /ghost/admin/posts.cfm last;
rewrite ^/ghost/admin/posts-spike/?$ /ghost/admin/posts-spike.cfm last;
rewrite ^/ghost/admin/posts-spike-proper/?$ /ghost/admin/posts-spike-proper.cfm last;

# Post creation and editing
rewrite ^/ghost/admin/posts/new/?$ /ghost/admin/posts/new.cfm last;
rewrite ^/ghost/admin/posts/edit/([a-zA-Z0-9-]+)/?$ /ghost/admin/posts/edit.cfm?id=$1 last;
```

### Other Admin Sections
```nginx
# Content management
rewrite ^/ghost/admin/pages/?$ /ghost/admin/pages.cfm last;
rewrite ^/ghost/admin/tags/?$ /ghost/admin/tags.cfm last;
rewrite ^/ghost/admin/members/?$ /ghost/admin/members.cfm last;

# Settings
rewrite ^/ghost/admin/settings/?$ /ghost/admin/settings.cfm last;
rewrite ^/ghost/admin/settings/([a-zA-Z0-9-]+)/?$ /ghost/admin/settings.cfm?section=$1 last;
```

## API URLs

### Admin API Endpoints
```nginx
# Posts API for admin operations
rewrite ^/ghost/api/admin/posts/?$ /ghost/api/admin/posts.cfm last;
rewrite ^/ghost/api/admin/posts/([a-zA-Z0-9-]+)/?$ /ghost/api/admin/posts.cfm?id=$1 last;
```

### Content API Endpoints
```nginx
# Public content API
rewrite ^/ghost/api/content/posts/?$ /ghost/api/content/posts.cfm last;
rewrite ^/ghost/api/content/posts/([a-zA-Z0-9-]+)/?$ /ghost/api/content/posts.cfm?id=$1 last;
rewrite ^/ghost/api/content/tags/?$ /ghost/api/content/tags.cfm last;
rewrite ^/ghost/api/content/authors/?$ /ghost/api/content/authors.cfm last;
```

## Blog Frontend URLs

### Public Blog Routes
```nginx
# Blog home and pagination
rewrite ^/ghost/blog/?$ /ghost/blog/index.cfm last;
rewrite ^/ghost/blog/page/([0-9]+)/?$ /ghost/blog/index.cfm?page=$1 last;

# Content filtering
rewrite ^/ghost/blog/tag/([a-zA-Z0-9-]+)/?$ /ghost/blog/tag.cfm?slug=$1 last;
rewrite ^/ghost/blog/author/([a-zA-Z0-9-]+)/?$ /ghost/blog/author.cfm?slug=$1 last;

# Individual posts
rewrite ^/ghost/blog/([a-zA-Z0-9-]+)/?$ /ghost/blog/post.cfm?slug=$1 last;
```

## Special Redirects

### Favicon Handling
```nginx
# Admin login favicon
location = /ghost/admin/login/favicon.ico {
    rewrite ^.*$ /ghost/admin/assets/images/favicon.ico permanent;
}

# General favicon redirect
location ~ /ghost/.*/favicon\.ico$ {
    rewrite ^.*$ /ghost/assets/images/favicon.ico permanent;
}
```

## Asset Serving

### Admin Assets
```nginx
# Admin assets - serve directly
location /ghost/admin/assets/ {
    alias /var/www/sites/cloudcoder.dev/wwwroot/ghost/admin/assets/;
    expires 30d;
    add_header Cache-Control "public";
}
```

### Testing Directory
```nginx
# Testing directory - direct access
location /ghost/testing/ {
    try_files $uri $uri/ @ghostcfm;
}
```

## URL Pattern Explanations

### Regex Capture Groups
- `([a-zA-Z0-9-]+)` - Captures alphanumeric characters and hyphens for IDs/slugs
- `([0-9]+)` - Captures numeric values for pagination
- `/?$` - Optional trailing slash at end of URL

### URL Examples

#### Admin URLs
- `https://cloudcoder.dev/ghost/admin/` → `/ghost/admin/index.cfm`
- `https://cloudcoder.dev/ghost/admin/posts/` → `/ghost/admin/posts.cfm`
- `https://cloudcoder.dev/ghost/admin/posts/edit/my-post-123/` → `/ghost/admin/posts/edit.cfm?id=my-post-123`
- `https://cloudcoder.dev/ghost/admin/settings/general/` → `/ghost/admin/settings.cfm?section=general`

#### API URLs
- `https://cloudcoder.dev/ghost/api/content/posts/` → `/ghost/api/content/posts.cfm`
- `https://cloudcoder.dev/ghost/api/admin/posts/abc123/` → `/ghost/api/admin/posts.cfm?id=abc123`

#### Blog URLs
- `https://cloudcoder.dev/ghost/blog/` → `/ghost/blog/index.cfm`
- `https://cloudcoder.dev/ghost/blog/page/2/` → `/ghost/blog/index.cfm?page=2`
- `https://cloudcoder.dev/ghost/blog/tag/technology/` → `/ghost/blog/tag.cfm?slug=technology`
- `https://cloudcoder.dev/ghost/blog/my-awesome-post/` → `/ghost/blog/post.cfm?slug=my-awesome-post`

## Notes

### SEO-Friendly Features
- All URLs are clean without `.cfm` extensions
- Proper trailing slash handling
- Consistent URL structure
- Search engine friendly patterns

### Performance Considerations
- Static assets cached for 30 days
- Direct file serving for assets
- Optimized proxy configuration for CFML files

### Security
- Testing directory access controlled
- Admin assets properly secured
- Favicon redirects prevent 404 errors

---

*This configuration supports the Ghost CMS implementation in CFML with SEO-optimized URLs and proper asset handling.*