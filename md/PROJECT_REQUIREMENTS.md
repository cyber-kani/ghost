# CFGhost - Ghost CMS CFML Implementation Requirements

## Database Specifications

### Primary Database
- **Database Name**: `cc_prod` (MySQL)
- **CFML Datasource**: `blog`
- **Configuration**: Must be configured in Lucee Administrator
- **Exclusive Use**: Only use MySQL cc_prod database for this project

## Frontend Framework & Design

### UI Framework
- **Primary Framework**: TailwindCSS 3.4.3 with Spike Tailwind Pro template
- **Secondary Framework**: Bootstrap 5 (for modals and components)
- **Design System**: Ghost CMS-inspired interface with card-based editor
- **UX Guidelines**: Modern content management best practices
- **Responsive**: Mobile-first approach with responsive breakpoints

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
- **Base Path**: `/var/www/sites/clitools.app/wwwroot/ghost/`
- **Domain**: `https://clitools.app/ghost/`
- **Constraint**: Work ONLY within this directory

### Folder Organization
```
/var/www/sites/clitools.app/wwwroot/ghost/
├── assets/                     # Main frontend assets
│   ├── css/                    # Stylesheets
│   ├── js/                     # JavaScript files
│   ├── images/                 # Images (max 2000px width)
│   └── videos/                 # Video files
├── admin/                      # Admin interface
│   ├── posts/                  # Posts management
│   │   └── edit-ghost-style.cfm # Ghost-style editor
│   ├── ajax/                   # AJAX handlers
│   ├── includes/               # Common includes
│   └── assets/                 # Separate admin assets folder
├── content/                    # User-generated content
│   └── images/                 # Uploaded images
│       ├── profile/            # Profile images
│       └── 2025/               # Year-based organization
├── components/                 # CFC components
├── logs/                       # Error and debug logs
├── src/                        # References & downloaded sources
│   ├── ghost-source/           # Ghost CMS source code
│   └── spike-tailwind-pro/     # Design template
├── testing/                    # All testing files
├── config/                     # Configuration files
│   ├── firebase.cfm            # Firebase config
│   └── oauth.cfm               # OAuth settings
├── md/                         # All markdown files
├── router.cfm                  # URL routing
├── index.cfm                   # Entry point
└── Application.cfc             # Application config
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
- **Primary Choice**: CSS transitions and animations
- **JavaScript**: Modern ES6+ for interactive components
- **Editor Features**: Drag & drop, inline toolbars, card interactions
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

## Authentication & Session Management

### Authentication Methods
- **Primary**: Firebase Google OAuth
- **Secondary**: Email/password with SHA-256 hashing
- **Session Variables**: Use uppercase (ISLOGGEDIN, USERID)
- **User Roles**: Owner, Administrator, Editor, Author, Contributor

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

## Ghost-Style Editor Implementation

### Content Card Types (15 Implemented)
1. **Paragraph Card**: Rich text with inline formatting toolbar
2. **Heading Card**: H1-H6 support with size selector
3. **Image Card**: Upload, captions, alt text, width settings
4. **Video Card**: YouTube/Vimeo embeds, width and loop settings
5. **Audio Card**: Audio file upload with custom player
6. **File Card**: Document uploads with download interface
7. **Product Card**: E-commerce cards with ratings and CTAs
8. **Bookmark Card**: Internal post links with preview
9. **Callout Card**: Highlighted content with emoji icons
10. **Toggle Card**: Expandable/collapsible content
11. **Embed Card**: Social media and third-party embeds
12. **Markdown Card**: Markdown editor with preview
13. **HTML Card**: Raw HTML input
14. **Divider Card**: Section separators
15. **Button Card**: CTA buttons with styles

### Editor Features
- **Drag & Drop**: Card reordering and file uploads
- **Autosave**: Automatic saving with visual feedback
- **Unsaved Changes Detection**: Prevents data loss
- **Real-time Preview**: Live content preview
- **Post Settings**: SEO, scheduling, tags, excerpts

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

## Recent Implementation Status

### ✅ Completed Features
- Ghost-style post editor with all 15 card types
- Authentication system (Google OAuth + email/password)
- User profile management with image upload
- Clean URL routing system
- Posts management with filtering
- Autosave and unsaved changes detection
- SEO meta settings
- Drag & drop functionality
- Real-time preview

### 🚧 In Progress
- Preview page improvements
- Header card implementation
- Gallery card implementation
- Call to Action card implementation

### ❌ Not Started
- Social media preview cards
- Newsletter functionality
- Membership system
- API endpoints
- Analytics integration