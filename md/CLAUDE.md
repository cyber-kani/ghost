# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is CFGhost - a Ghost CMS-inspired content management system built using CFML (ColdFusion), designed to replicate Ghost's functionality and user experience. The project uses the Spike Tailwind Pro admin template for the UI.

## Technology Stack

- **Server-Side**: CFML (ColdFusion) on Lucee
- **Database**: MySQL (cc_prod database, "blog" datasource)
- **Frontend Framework**: TailwindCSS 3.4.3 with Spike Tailwind Pro template
- **Design System**: Spike Admin Dashboard + CFGhost CMS patterns
- **JavaScript**: Modern ES6+ with AJAX
- **Web Server**: Nginx with Lucee on Tomcat

## Database Configuration

- **Database**: `cc_prod` (MySQL)
- **Datasource Name**: `blog`
- **Connection**: Configured in Lucee Administrator
- **Important**: Always use datasource "blog" not "ghost_prod"

## Project Structure

```
/var/www/sites/clitools.app/wwwroot/ghost/    # CFGhost root directory
├── admin/                      # Admin interface
│   ├── posts.cfm              # Posts management
│   ├── profile.cfm            # User profile management
│   ├── ajax/                  # AJAX handlers
│   ├── includes/              # Common includes (header/footer)
│   └── assets/                # Admin-specific assets
├── content/                    # User-generated content
│   └── images/
│       └── profile/           # Profile images
├── assets/                     # Frontend assets
│   ├── css/                   # Stylesheets (TailwindCSS)
│   ├── js/                    # JavaScript files
│   └── images/                # Static images
├── md/                        # Documentation
├── src/                       # Source materials
│   ├── ghost-source/          # Ghost CMS source code
│   └── spike-tailwind-pro/    # Template files
└── router.cfm                 # Main routing logic
```

## Development Guidelines

### CFML Best Practices
- Use CFML tags for markup generation
- Implement CFC functions for performance optimization
- Follow object-oriented programming principles
- No try-catch error handling (let errors bubble up)
- Enable/disable debug mode for development

### Frontend Standards
- **CSS Framework**: TailwindCSS with Spike theme classes
- **Component Library**: Spike Tailwind Pro components
- **Icons**: Tabler Icons (ti ti-*) 
- **Message Notifications**: Floating toast-style alerts
- **Form Handling**: AJAX with real-time feedback
- **Image Upload**: Automatic resizing for profiles
- **Error Styling**: Consistent error messages with Tailwind classes

### SEO Optimization
- SEO-optimized URLs without file extensions
- Proper meta tags and structured data
- Clean URL routing without .cfm extensions
- Mobile-friendly responsive design

### Performance Requirements
- Lazy loading for images
- GSAP for animations (primary choice)
- Optimized CFC components
- Efficient database queries

## URL Structure

- Clean URLs without file extensions via router.cfm
- SEO-friendly routing with single entry point
- Examples: 
  - `/ghost/admin/posts` - Posts listing
  - `/ghost/admin/profile` - User profile
  - `/ghost/admin/posts?type=published` - Filtered views

## Debug Configuration

- **Debug Mode**: Toggle on/off for development
- **Error Display**: Show on screen when debug enabled
- **Error Logging**: Always log to files in `logs/` folder
- **Log Location**: `/var/www/sites/cloudcoder.dev/wwwroot/ghost/logs/`

## Design System

### UI Framework
- **Primary**: Spike Tailwind Pro admin template
- **CSS**: TailwindCSS 3.4.3
- **Design Pattern**: CFGhost CMS interface
- **Responsive**: Mobile-first with lg: breakpoints

### Alert/Error Message Patterns
Use consistent styling for all alert messages:
```html
<!-- Error -->
<div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-alert-circle text-red-500 mr-2"></i>
    <span class="text-sm font-medium">Error message</span>
</div>

<!-- Success -->
<div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-check-circle text-green-500 mr-2"></i>
    <span class="text-sm font-medium">Success message</span>
</div>
```

### Layout Standards
- Common header and footer across all pages
- Consistent button sizing
- Single layout pattern for all UI elements
- Hamburger menu for mobile navigation

## Development Workflow

### Local Development
```bash
# Test CFML functionality
# Access via browser: http://localhost/ghost/

# View logs
tail -f /var/www/sites/cloudcoder.dev/wwwroot/ghost/logs/error.log
```

### Testing
- All tests in `testing/` folder
- Keep main folders clean
- Separate test databases if needed

### Asset Management
- Frontend assets in `assets/` folder
- Admin assets separate in `admin/assets/`
- Source files and references in `src/` folder

## Server Configuration

### Nginx Configuration
- Handle SEO-friendly URLs
- Resolve CSP issues through web server config
- Proper CFML routing setup

### Lucee/Tomcat
- Configure "blog" datasource
- Set up application mappings
- Enable/disable debug mode

## Security Considerations

- Parameterized queries with cfqueryparam
- Input validation on all form submissions
- File upload validation and size limits
- Image resizing to prevent oversized uploads
- Secure database connections

## Recent Updates

1. **Profile System**: Complete user profile management with image upload
2. **Database Fix**: Updated datasource from "ghost_prod" to "blog"
3. **UI Enhancements**: Floating notifications, Quick Stats dashboard
4. **Header Integration**: Dynamic user data display with profile images
5. **Form Features**: Auto-slug generation, character counters, live previews

## Common Issues & Solutions

1. **Datasource Error**: Always use datasource="blog" not "ghost_prod"
2. **Form Submission**: Check for form fields, not just URL parameters
3. **Image Upload**: Ensure /content/images/profile/ has write permissions
4. **Message Display**: Use showMessage() function for consistent notifications