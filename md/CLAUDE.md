# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This directory contains a CFML-based blog system built with ColdFusion, MySQL, and modern web technologies. The project follows object-oriented programming principles and is optimized for performance, SEO, and mobile responsiveness.

## Technology Stack

- **Server-Side**: CFML (ColdFusion) with CFC components
- **Database**: MySQL (cc_prob database, "blog" datasource)
- **Frontend Framework**: Fomantic-UI (https://fomantic-ui.com/)
- **Design System**: Google Material3 + Apple UX Guidelines
- **Animations**: GSAP (primary choice)
- **Web Server**: Nginx with Lucee on Tomcat

## Database Configuration

- **Database**: `cc_prob` (MySQL)
- **Datasource Name**: `blog`
- **Connection**: Configured in Lucee Administrator

## Project Structure

```
/var/www/sites/cloudcoder.dev/wwwroot/ghost/
├── assets/                     # Frontend assets
│   ├── css/                    # Stylesheets
│   ├── js/                     # JavaScript files
│   ├── images/                 # Image files (max 2000px width)
│   └── videos/                 # Video assets
├── admin/                      # Admin interface
│   └── assets/                 # Separate admin assets
├── components/                 # CFC components
├── includes/                   # Common includes (header/footer)
├── logs/                       # Error and debug logs
├── src/                        # References and downloaded sources
├── testing/                    # All testing files
└── config/                     # Configuration files
```

## Development Guidelines

### CFML Best Practices
- Use CFML tags for markup generation
- Implement CFC functions for performance optimization
- Follow object-oriented programming principles
- No try-catch error handling (let errors bubble up)
- Enable/disable debug mode for development

### Frontend Standards
- **Responsive Design**: Mobile-first approach
- **Mobile Navigation**: Hamburger menu implementation
- **Image Optimization**: Lazy loading, max 2000px width
- **Button Consistency**: Same size regardless of text content
- **Layout Consistency**: Single UI/UX pattern throughout

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

- Clean URLs without file extensions
- SEO-friendly routing
- Examples: `/blog/post-title`, `/admin/dashboard`

## Debug Configuration

- **Debug Mode**: Toggle on/off for development
- **Error Display**: Show on screen when debug enabled
- **Error Logging**: Always log to files in `logs/` folder
- **Log Location**: `/var/www/sites/cloudcoder.dev/wwwroot/ghost/logs/`

## Design System

### UI Framework
- **Primary**: Fomantic-UI components
- **Design Language**: Google Material3
- **UX Guidelines**: Apple Human Interface Guidelines
- **Responsive**: Mobile-first breakpoints

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

- No try-catch error handling (transparent error reporting)
- Proper CSP headers via Nginx configuration
- Secure database connections
- Input validation in CFC components