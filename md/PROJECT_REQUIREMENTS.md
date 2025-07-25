# CFML Blog System - Project Requirements

## Database Specifications

### Primary Database
- **Database Name**: `cc_prob` (MySQL)
- **CFML Datasource**: `blog`
- **Configuration**: Must be configured in Lucee Administrator

## Frontend Framework & Design

### UI Framework
- **Primary Framework**: [Fomantic-UI](https://fomantic-ui.com/)
- **Design System**: Google Material3 design principles
- **UX Guidelines**: Apple User Experience Guidelines
- **Responsive**: Mobile-first approach with hamburger menu

### Visual Standards
- **Button Consistency**: All buttons same size regardless of text content
- **Layout Unity**: Single consistent layout pattern for entire site
- **UI Consistency**: Maintain uniform UI/UX across all pages

## Server-Side Technology

### CFML Requirements
- **Language**: CFML (ColdFusion) only for server-side
- **Architecture**: Use CFML tags for markup
- **Performance**: Implement CFC (ColdFusion Component) functions for optimization
- **Programming Paradigm**: Follow object-oriented programming principles

### Server Stack
- **Web Server**: Nginx
- **CFML Engine**: Lucee running on Tomcat
- **Database**: MySQL

## Project Directory Structure

### Working Directory
- **Base Path**: `/var/www/sites/cloudcoder.dev/wwwroot/ghost/`
- **Constraint**: Work ONLY within this directory

### Folder Organization
```
/var/www/sites/cloudcoder.dev/wwwroot/ghost/
├── assets/                     # Main frontend assets
│   ├── css/                    # Stylesheets
│   ├── js/                     # JavaScript files
│   ├── images/                 # Images (max 2000px width)
│   └── videos/                 # Video files
├── admin/                      # Admin interface
│   └── assets/                 # Separate admin assets
├── components/                 # CFC components
├── includes/                   # Header/footer includes
├── logs/                       # Error and debug logs
├── src/                        # References & downloaded sources
├── testing/                    # All testing files
└── config/                     # Configuration files
```

## Image & Media Standards

### Image Specifications
- **Maximum Width**: 2000 pixels
- **Loading Strategy**: Implement lazy loading for all images
- **Optimization**: Ensure proper compression and format selection

### Media Organization
- **Images**: Store in `assets/images/`
- **Videos**: Store in `assets/videos/`
- **Admin Media**: Separate folder in `admin/assets/`

## SEO Optimization Requirements

### URL Structure
- **Clean URLs**: No file extensions (.cfm) in URLs
- **SEO-Friendly**: Optimized URL patterns
- **Examples**: `/blog/post-title`, `/admin/dashboard`

### SEO Standards
- **Meta Tags**: Comprehensive meta tag implementation
- **Structured Data**: Proper schema markup
- **Mobile-Friendly**: Responsive design for mobile SEO
- **Page Speed**: Optimized loading performance

## Animation & Interaction

### Animation Framework
- **Primary Choice**: GSAP (GreenSock Animation Platform)
- **Fallback**: Only consider other options after GSAP evaluation
- **Performance**: Ensure smooth animations on all devices

### Mobile Interactions
- **Navigation**: Hamburger menu for mobile view
- **Touch-Friendly**: Optimize for touch interactions
- **Responsive**: Adapt animations for different screen sizes

## Error Handling & Debugging

### Error Management
- **No Try-Catch**: Do not handle errors with try-catch blocks
- **Transparent Errors**: Let errors bubble up naturally
- **Error Logging**: Log all errors to files in `logs/` folder

### Debug Configuration
- **Debug Mode**: Toggle-able debug mode
- **Screen Display**: Show errors on screen when debug enabled
- **Log Files**: Always maintain error logs in server logs folder
- **Log Location**: Keep logs inside `logs/` folder

## Security & Server Configuration

### Content Security Policy (CSP)
- **Configuration**: Modify webserver (Nginx) config for CSP issues
- **Implementation**: Handle CSP through server configuration, not application code

### Nginx Configuration
- **URL Routing**: Handle clean URLs without extensions
- **CSP Headers**: Proper Content Security Policy implementation
- **CFML Integration**: Ensure proper Lucee/CFML routing

## Development & Testing Standards

### Testing Requirements
- **Testing Location**: All testing MUST be in `testing/` folder
- **Clean Folders**: Keep main application folders clean
- **Separation**: Separate test environments from production code

### Code Organization
- **Source Files**: Keep references and downloaded sources in `src/` folder
- **Documentation**: Maintain separate documentation
- **Version Control**: Proper file organization for version control

## Layout & Navigation Standards

### Common Elements
- **Header**: Maintain common header across all frontend pages
- **Footer**: Maintain common footer across all frontend pages
- **Consistency**: Single layout pattern for entire application

### Admin Interface
- **Separate Assets**: Admin has its own assets folder
- **Distinct Design**: Admin interface can have different styling
- **Functionality**: Admin-specific features and navigation

## Performance Optimization

### CFC Implementation
- **Object-Oriented**: Use CFC functions for performance optimization
- **Caching**: Implement appropriate caching strategies
- **Database**: Optimize database queries and connections

### Frontend Performance
- **Lazy Loading**: Implement for images and heavy content
- **Asset Optimization**: Minimize CSS/JS files
- **Mobile Performance**: Ensure fast loading on mobile devices

## Development Workflow

### Directory Maintenance
- **Clean Structure**: Keep main folders organized and clean
- **Asset Management**: Proper organization of CSS, JS, images, videos
- **Documentation**: Maintain comprehensive documentation

### Quality Assurance
- **Mobile Testing**: Test on various mobile devices
- **Cross-Browser**: Ensure compatibility across browsers
- **Performance Testing**: Regular performance optimization checks
- **SEO Validation**: Regular SEO optimization validation