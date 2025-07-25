# Ghost CMS - ColdFusion Implementation

A modern Ghost CMS implementation built with ColdFusion, providing a complete blogging platform with an intuitive admin interface.

## Features

### Admin Interface
- **Modern UI**: Clean, responsive admin panel with Ghost-like styling
- **Post Editor**: Advanced block-based editor with image support, captions, and formatting
- **Content Management**: Full CRUD operations for posts, pages, and tags
- **User Management**: Author profiles and user authentication
- **Dashboard**: Analytics and content overview

### Post Editor Features
- Block-based editing similar to Ghost
- Image upload and management
- Rich text formatting (Bold, Italic, Links, Headings, Quotes, Lists)
- Image captions and alt text
- Auto-save functionality
- Word count tracking
- Drag & drop block reordering

### Technical Features
- **ColdFusion Components**: Modular service architecture
- **MySQL Database**: Robust data storage
- **AJAX Operations**: Smooth user experience
- **Responsive Design**: Mobile-friendly interface
- **SEO Optimized**: Clean URLs and meta management

## Architecture

```
ghost/
├── admin/                  # Admin interface
│   ├── post/              # Post editing
│   │   ├── edit-simple.cfm    # Main post editor
│   │   └── edit.cfm           # Alternative editor
│   ├── ajax/              # AJAX endpoints
│   ├── assets/            # CSS, JS, images
│   ├── includes/          # Common includes
│   └── *.cfm             # Admin pages
├── components/            # ColdFusion components
│   ├── BaseService.cfc    # Base service class
│   ├── PostService.cfc    # Post operations
│   ├── PostServiceSimple.cfc
│   ├── SimplePostService.cfc
│   └── UserService.cfc    # User management
├── config/               # Configuration
│   └── database.cfm      # Database settings
├── assets/               # Public assets
├── md/                   # Documentation
└── src/                  # Source code reference
```

## Database Schema

### Core Tables
- `posts` - Blog posts and pages
- `users` - Authors and administrators  
- `tags` - Content categorization
- `post_tags` - Many-to-many relationship

### Key Fields
- **Posts**: title, content, slug, status, author_id, created_at, updated_at
- **Users**: name, email, role, profile data
- **Tags**: name, slug, description

## Installation

1. **Database Setup**
   ```sql
   -- Create database and tables
   -- Import schema from config/database.cfm
   ```

2. **ColdFusion Configuration**
   - Ensure ColdFusion server is running
   - Configure datasource for MySQL database
   - Set up application mappings

3. **File Permissions**
   ```bash
   chmod 755 ghost/
   chmod 644 ghost/**/*.cfm
   ```

## Usage

### Admin Access
Navigate to `/ghost/admin/` to access the administration interface.

### Creating Posts
1. Go to Posts section
2. Click "New Post"
3. Use the block editor to create content
4. Add images, formatting, and metadata
5. Save as draft or publish

### Post Editor
- **Text Blocks**: Click + button to add content blocks
- **Images**: Upload via URL or file upload
- **Formatting**: Select text for formatting toolbar
- **Captions**: Click on images to add captions
- **Delete**: Select blocks and press Delete key

## Development

### Component Structure
- **BaseService.cfc**: Common database and utility methods
- **PostService.cfc**: Complete post management operations
- **PostServiceSimple.cfc**: Simplified post operations
- **UserService.cfc**: User authentication and management

### Adding Features
1. Create component methods in appropriate service
2. Add admin interface pages
3. Implement AJAX endpoints for dynamic operations
4. Update database schema if needed

### Customization
- Modify CSS in `admin/assets/css/`
- Extend components for additional functionality
- Add new content types by extending post model

## API Endpoints

### AJAX Operations
- `POST /admin/ajax/create-post.cfm` - Create new post
- `POST /admin/ajax/update-post.cfm` - Update existing post
- `POST /admin/ajax/delete-post.cfm` - Delete post
- `POST /admin/ajax/upload-image.cfm` - Upload images
- `POST /admin/ajax/quick-publish.cfm` - Quick publish
- `POST /admin/ajax/duplicate-post.cfm` - Duplicate post

## Browser Support
- Chrome/Chromium 60+
- Firefox 55+
- Safari 11+
- Edge 79+

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

Open source project - see individual component licenses.

## Version History

- **v1.0.0** - Initial ColdFusion implementation
- Block-based editor with Ghost-like interface
- Complete admin panel
- Post, page, and tag management
- User authentication system

---

Built with ❤️ using ColdFusion and modern web technologies.