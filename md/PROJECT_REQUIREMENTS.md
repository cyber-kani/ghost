# CFML Blog System - Project Requirements

## Database Specifications

### Primary Database
- **Database Name**: `cc_prob` (MySQL)
- **CFML Datasource**: `blog`
- **Configuration**: Must be configured in Lucee Administrator
- **Exclusive Use**: Only use MySQL cc_prob database for this project

## Frontend Framework & Design

### UI Framework
- **Primary Framework**: [Fomantic-UI](https://fomantic-ui.com/)
- **Design System**: Google Material3 design principles
- **UX Guidelines**: Apple User Experience Guidelines
- **Responsive**: Mobile-first approach with hamburger menu

### Visual Standards
- **Button Consistency**: All buttons same size regardless of text content - do not change button size depending on text
- **Layout Unity**: Single consistent layout pattern for entire site
- **UI Consistency**: Maintain uniform UI/UX across all pages
- **Layout Principle**: Stick to one layout for all UI and UX elements

## Server-Side Technology

### CFML Requirements
- **Language**: CFML (ColdFusion) only for server-side
- **Syntax**: Use CFML tags (not CFML scripts)
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
│   └── assets/                 # Separate admin assets folder
├── components/                 # CFC components
├── includes/                   # Header/footer includes
├── logs/                       # Error and debug logs
├── src/                        # References & downloaded sources
├── testing/                    # All testing files
├── config/                     # Configuration files
└── md/                         # All markdown files
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
- **Clean URLs**: No file extensions (.cfm) in URLs - use SEO optimized URLs without filename
- **SEO-Friendly**: Built on SEO optimization standards
- **Examples**: `/blog/post-title`, `/admin/dashboard`

### SEO Standards
- **Meta Tags**: Comprehensive meta tag implementation
- **Structured Data**: Proper schema markup
- **Mobile-Friendly**: Responsive design for mobile SEO
- **Page Speed**: Optimized loading performance

## Animation & Interaction

### Animation Framework
- **Primary Choice**: GSAP (GreenSock Animation Platform) - use GSAP first before checking other options
- **Fallback**: Only consider other options after GSAP evaluation
- **Performance**: Ensure smooth animations on all devices

### Mobile Interactions
- **Navigation**: Hamburger menu for mobile view
- **Touch-Friendly**: Optimize for touch interactions
- **Responsive**: Make sites responsive and mobile friendly

## Error Handling & Debugging

### Error Management
- **No Try-Catch**: Do not handle errors with try-catch blocks
- **Transparent Errors**: Let errors bubble up naturally
- **Error Logging**: Log errors to log file in server

### Debug Configuration
- **Debug Mode**: Enable/disable debug mode to show errors on screen
- **Screen Display**: Show errors on screen when debug enabled
- **Log Files**: Keep logs inside logs folder
- **Error Logging**: Always log errors to files in `logs/` folder

## Security & Server Configuration

### Content Security Policy (CSP)
- **Configuration**: CSP issues modify the webserver config
- **Implementation**: Handle CSP through server configuration, not application code

### Nginx Configuration
- **URL Routing**: Handle clean URLs without extensions
- **CSP Headers**: Proper Content Security Policy implementation
- **CFML Integration**: Nginx web server with Lucee running on top of Tomcat

## Development & Testing Standards

### Testing Requirements
- **Testing Location**: All testing MUST be done inside testing folder
- **Clean Folders**: Keep main folders clean
- **Separation**: Separate test environments from production code

### Code Organization
- **Source Files**: Keep all reference and downloaded source in src folder
- **Documentation**: Keep all md files inside md folder
- **Version Control**: Proper file organization for version control

## Layout & Navigation Standards

### Common Elements
- **Header**: Maintain common header for frontend
- **Footer**: Maintain common footer for frontend
- **Consistency**: Single layout pattern for entire application

### Admin Interface
- **Separate Assets**: Maintain different assets folder for admin
- **Distinct Design**: Admin interface can have different styling
- **Functionality**: Admin-specific features and navigation

## Performance Optimization

### CFC Implementation
- **Object-Oriented**: Use CFC functions for performance optimization
- **Caching**: Implement appropriate caching strategies
- **Database**: Optimize database queries and connections

### Frontend Performance
- **Lazy Loading**: Use lazy loader for images
- **Asset Optimization**: Keep assets in assets folder with separate folders for images, videos, js, and css
- **Mobile Performance**: Ensure fast loading on mobile devices

## Development Workflow

### Directory Maintenance
- **Clean Structure**: Keep main folders organized and clean
- **Asset Management**: Create folders for images, videos, js, and css within assets
- **Documentation**: Maintain comprehensive documentation

### Quality Assurance
- **Mobile Testing**: Test on various mobile devices
- **Cross-Browser**: Ensure compatibility across browsers
- **Performance Testing**: Regular performance optimization checks
- **SEO Validation**: Regular SEO optimization validation