# CFGhost - CFML Implementation of Ghost CMS Architecture

## Overview

CFGhost is a Ghost CMS-inspired content management system built using CFML (ColdFusion), designed to replicate Ghost's functionality and user experience while leveraging CFML's server-side capabilities. This document outlines the current implementation status and architectural decisions based on analysis of Ghost v5+ source code.

**Project Status**: Production-ready for basic content management
**Technology Stack**: CFML (Lucee), MySQL, TailwindCSS, Spike Tailwind Pro
**Domain**: https://clitools.app/ghost/

## Current Implementation Status

### ✅ Completed Core Features

#### 1. **Authentication & Session Management**
- **Google OAuth Integration**: Firebase authentication with Google Sign-In
- **Email/Password Authentication**: Traditional login with SHA-256 password hashing
- **Dual Authentication Support**: Both OAuth and traditional login working
- **Session Management**: Unified session handling across application scopes
- **User Roles**: Support for Owner, Administrator, Editor, Author, Contributor roles

#### 2. **URL Routing System**
- **Clean URL Structure**: SEO-friendly URLs without .cfm extensions
- **Single Entry Point**: All requests route through index.cfm → router.cfm
- **Query Parameter Handling**: Nginx parameter duplication fixes
- **Profile Route**: /admin/profile for user profile management

#### 3. **Posts Management**
- **Database Integration**: MySQL with proper column qualification
- **Status Filtering**: Draft, Published, Scheduled post types
- **Author Management**: Multi-author support with proper attribution
- **Query Parameter Cleanup**: Handles nginx parameter duplication

#### 4. **User Profile System**
- **Complete Profile Management**: Full user profile page with database integration
- **Profile Image Upload**: Avatar upload with automatic resizing and storage
- **Real-time Updates**: AJAX form submission with visual feedback
- **Social Media Integration**: Bio, location, website, social media fields
- **Quick Stats Dashboard**: Visual metrics display

#### 5. **Admin Interface**
- **Spike Tailwind Pro Template**: Professional admin dashboard design
- **Responsive Design**: Mobile-friendly interface with hamburger navigation
- **Floating Notifications**: Ghost-style toast messages for user feedback
- **Dynamic Header**: User profile display with avatar and name
- **Navigation Structure**: Hierarchical menu system with active states

### 🚧 Partially Implemented

#### 1. **Content Editor**
- Basic post editing form exists
- Needs rich text editor integration (TinyMCE/CKEditor)
- Missing drag-and-drop media upload

#### 2. **Media Management**
- Profile image upload working
- General media library needs implementation
- Image optimization needs enhancement

### ❌ Not Yet Implemented

#### 1. **Ghost-Inspired Features**
- Membership system for paid content
- Newsletter functionality and email broadcasting
- Theme system with Handlebars-like templating
- Advanced analytics and performance tracking
- SEO tools and meta tag management

#### 2. **API Layer**
- REST API endpoints for external integrations
- Webhook system for third-party services
- Content API for public content access

## Core Architecture

### **Technology Stack Evolution**

Ghost has undergone significant architectural changes:

**Legacy Stack (Pre-5.0):**
- **Backend**: Node.js with Express.js
- **Admin Interface**: Ember.js framework
- **Database**: MySQL/SQLite
- **Templating**: Handlebars.js

**Modern Stack (5.0+):**
- **Backend**: Node.js with Express.js (unchanged)
- **Admin Interface**: React with TypeScript
- **Database**: MySQL/SQLite (unchanged)
- **Templating**: Handlebars.js (unchanged)
- **Build System**: Vite for modern asset building

### **Application Structure**

Ghost is organized as a monorepo with multiple applications:

```
ghost/
├── apps/                          # Modern React applications
│   ├── admin-x-settings/          # Settings interface (React/TypeScript)
│   ├── portal/                    # Member portal (React)
│   ├── signup-form/               # Signup forms (React)
│   └── comments-ui/               # Comments system (React)
├── ghost/                         # Core Ghost application
│   ├── admin/                     # Legacy Ember.js admin (being phased out)
│   ├── core/                      # Backend API and business logic
│   └── content/                   # Content management
└── packages/                      # Shared packages and utilities
```

## Content Management System

### **Posts and Pages Architecture**

Ghost distinguishes between two primary content types:

**Posts:**
- Blog entries with publication dates
- Support for drafts, published, scheduled, and sent states
- Featured post capability
- Author attribution and multi-author support

**Pages:**
- Static content (About, Contact, etc.)
- No publication dates
- Same editing capabilities as posts

**Content Status Workflow:**
```javascript
// From posts.js route analysis
const statuses = {
    draft: 'Content being written',
    scheduled: 'Content scheduled for future publication',
    published: 'Live content visible to readers',
    sent: 'Newsletter content sent to subscribers'
};
```

### **Content Editor System**

Ghost features a modern card-based editor with 20+ content block types:

**Core Content Blocks:**
1. **Text Blocks**: Paragraph, heading, quote, list
2. **Media Blocks**: Image, gallery, video, file
3. **Embed Blocks**: YouTube, Twitter, Instagram, CodePen
4. **Advanced Blocks**: HTML, markdown, divider, button
5. **Newsletter Blocks**: Email-specific content blocks

**Editor Features:**
- **Lexical Editor**: Modern rich-text editing framework
- **Drag & Drop**: Reorder content blocks easily
- **Markdown Support**: Write in markdown or rich text
- **Real-time Preview**: See changes as you type
- **Mobile Editing**: Responsive editor interface

## Admin Interface Architecture

### **Modern React Applications**

Ghost's admin interface is transitioning to React-based applications:

**admin-x-settings** (React/TypeScript):
```typescript
// From Settings.tsx analysis
const Settings: React.FC = () => {
    return (
        <>
            <div className='mb-[60vh] px-8 pt-16 tablet:max-w-[760px]'>
                <GeneralSettings />
                <SiteSettings />
                <MembershipSettings />
                <EmailSettings />
                <GrowthSettings />
                <AdvancedSettings />
            </div>
        </>
    );
};
```

**Key React App Features:**
- **TypeScript**: Full type safety
- **Tailwind CSS**: Modern utility-first styling
- **Component Architecture**: Reusable UI components
- **Responsive Design**: Mobile-first approach

### **Legacy Ember.js Admin**

The original admin interface uses Ember.js patterns:

**Posts Management** (from posts.js route):
```javascript
// Query parameters for filtering
queryParams = {
    type: {refreshModel: true},        // draft, published, scheduled, sent, featured
    visibility: {refreshModel: true},  // public, members, paid
    author: {refreshModel: true},      // filter by author
    tag: {refreshModel: true},         // filter by tag
    order: {refreshModel: true}        // sort order
};

// Status filtering logic
_getTypeFilters(type) {
    let status = '[draft,scheduled,published,sent]';
    switch (type) {
        case 'draft': status = 'draft'; break;
        case 'published': status = 'published'; break;
        case 'scheduled': status = 'scheduled'; break;
        case 'sent': status = 'sent'; break;
    }
    return { status };
}
```

**Posts Controller Architecture**:
```javascript
// Available filter types
const TYPES = [
    {name: 'All posts', value: null},
    {name: 'Draft posts', value: 'draft'},
    {name: 'Published posts', value: 'published'},
    {name: 'Email only posts', value: 'sent'},
    {name: 'Scheduled posts', value: 'scheduled'},
    {name: 'Featured posts', value: 'featured'}
];

const VISIBILITIES = [
    {name: 'All access', value: null},
    {name: 'Public', value: 'public'},
    {name: 'Members-only', value: 'members'},
    {name: 'Paid members-only', value: '[paid,tiers]'}
];
```

## Membership & Newsletter System

### **Member Management**

Ghost includes built-in membership functionality:

**Member Types:**
- **Free Members**: Basic newsletter subscribers
- **Paid Members**: Subscription-based access
- **Complimentary**: Free access to paid content
- **Tier-based**: Multiple subscription levels

**Authentication:**
- **Magic Links**: Passwordless authentication
- **Member Portal**: Self-service account management
- **Stripe Integration**: Payment processing
- **Webhooks**: Real-time subscription updates

### **Newsletter Features**

**Email Broadcasting:**
- **Newsletter Posts**: Content sent via email
- **Subscriber Segmentation**: Target specific member groups
- **Email Templates**: Customizable email designs
- **Analytics**: Open rates, click tracking
- **Bulk Import/Export**: Member list management

**Integration Points:**
```javascript
// From posts route - newsletter post handling
if (filterStatuses.includes('sent')) {
    // Handle newsletter-specific posts
    publishedAndSentInfinityModel = this.infinity.model(
        this.modelName, 
        {filter: this._filterString({status: 'sent'})}
    );
}
```

## Analytics & Performance

### **Built-in Analytics**

Ghost includes comprehensive analytics:

**Content Analytics:**
- **Post Performance**: Views, engagement metrics
- **Member Analytics**: Growth, churn, engagement
- **Email Analytics**: Open rates, click-through rates
- **Traffic Sources**: Referral tracking

**Analytics Implementation**:
```javascript
// From posts route - analytics integration
async _fetchAnalyticsForPosts(model) {
    if (!this.settings.webAnalyticsEnabled && !this.settings.membersTrackSources) {
        return;
    }
    
    const promises = [];
    
    if (this.settings.webAnalyticsEnabled) {
        const postUuids = posts.map(post => post.uuid);
        promises.push(this.postAnalytics.loadVisitorCounts(postUuids));
    }
    
    if (this.settings.membersTrackSources) {
        promises.push(this.postAnalytics.loadMemberCounts(posts));
    }
    
    if (promises.length > 0) {
        await Promise.all(promises);
    }
}
```

## Database Architecture

### **Core Tables Structure**

Ghost uses a well-defined database schema:

**Posts Table:**
- **id**: Primary key
- **uuid**: Universal identifier
- **title**: Post title
- **slug**: URL slug
- **status**: draft, published, scheduled, sent
- **visibility**: public, members, paid, tiers
- **type**: post, page
- **feature_image**: Featured image URL
- **created_at, updated_at, published_at**: Timestamps
- **meta_title, meta_description**: SEO metadata

**Users Table:**
- **id**: Primary key
- **name, email**: Basic user information
- **status**: active, inactive, locked
- **roles**: Owner, Administrator, Editor, Author, Contributor

**Members Table:**
- **id**: Primary key
- **email**: Member email
- **status**: free, paid, comped
- **subscriptions**: Stripe subscription data

### **Relationships**

**Many-to-Many Relationships:**
- **posts_authors**: Posts can have multiple authors
- **posts_tags**: Posts can have multiple tags
- **posts_meta**: Extended metadata for posts

## API Architecture

### **Admin API**

Ghost provides a comprehensive Admin API:

**Endpoints:**
- **Posts**: CRUD operations for content
- **Pages**: Static page management
- **Users**: User and author management
- **Tags**: Content categorization
- **Settings**: Site configuration
- **Members**: Membership management

**Authentication:**
- **Session-based**: Admin interface authentication
- **JWT Tokens**: API access tokens
- **Webhooks**: Event-driven integrations

### **Content API**

Public API for reading published content:

**Public Endpoints:**
- **Posts**: Published content only
- **Pages**: Public pages
- **Tags**: Public tag information
- **Authors**: Author profiles
- **Settings**: Public site settings

## Theme System

### **Handlebars Templating**

Ghost uses Handlebars for theme templating:

**Template Hierarchy:**
```
theme/
├── index.hbs          # Homepage
├── post.hbs           # Single post
├── page.hbs           # Single page
├── tag.hbs            # Tag archive
├── author.hbs         # Author archive
├── default.hbs        # Base template
└── partials/          # Reusable template parts
```

**Handlebars Helpers:**
```handlebars
{{!-- Ghost-specific helpers --}}
{{#get "posts" limit="5"}}
    {{#foreach posts}}
        <h2>{{title}}</h2>
        <p>{{excerpt}}</p>
    {{/foreach}}
{{/get}}

{{!-- Built-in helpers --}}
{{date published_at format="MMMM Do, YYYY"}}
{{reading_time}}
{{#has tag="featured"}}Featured Content{{/has}}
```

## Modern Development Patterns

### **React Component Architecture**

New Ghost applications follow modern React patterns:

**Component Structure:**
```typescript
// Type-safe props
interface SettingsProps {
    setting: Setting;
    onUpdate: (setting: Setting) => void;
}

// Functional components with hooks
const SettingsComponent: React.FC<SettingsProps> = ({setting, onUpdate}) => {
    const [value, setValue] = useState(setting.value);
    
    return (
        <div className="setting-group">
            <label>{setting.label}</label>
            <input 
                value={value}
                onChange={(e) => setValue(e.target.value)}
            />
        </div>
    );
};
```

**State Management:**
- **React Hooks**: useState, useEffect, useContext
- **Component State**: Local state management
- **Props Drilling**: Controlled component patterns

### **Build System**

**Vite Configuration:**
- **Fast Development**: Hot module replacement
- **TypeScript Support**: Built-in TypeScript compilation
- **Asset Optimization**: Automatic code splitting
- **Modern JavaScript**: ES modules and modern syntax

## Integration Patterns

### **Third-Party Integrations**

**Common Integration Points:**
- **Stripe**: Payment processing for subscriptions
- **Mailgun**: Email delivery service
- **Google Analytics**: Advanced analytics
- **Social Platforms**: Auto-posting to social media
- **CDN Services**: Asset delivery optimization

### **Webhook System**

Ghost provides webhooks for real-time integrations:

**Available Events:**
- **Post Published**: New content notifications
- **Member Signup**: New member registrations
- **Subscription Events**: Payment and subscription changes
- **Site Settings**: Configuration updates

## Performance Optimization

### **Caching Strategy**

**Built-in Caching:**
- **Template Caching**: Compiled Handlebars templates
- **Database Query Caching**: Optimized database queries
- **Static Asset Caching**: CDN-friendly asset handling
- **Redis Integration**: External caching layer support

### **Image Optimization**

**Responsive Images:**
- **Multiple Sizes**: Automatic image resizing
- **Modern Formats**: WebP and AVIF support
- **Lazy Loading**: Built-in lazy loading
- **CDN Integration**: Optimized image delivery

## Security Architecture

### **Content Security**

**Input Sanitization:**
- **XSS Protection**: Content sanitization
- **SQL Injection Prevention**: Parameterized queries
- **CSRF Protection**: Cross-site request forgery prevention
- **Rate Limiting**: API abuse prevention

**Access Control:**
- **Role-based Permissions**: Granular user permissions
- **Content Visibility**: Member-only content protection
- **Admin Authentication**: Secure admin access
- **API Key Management**: Secure API access

## Deployment & Scaling

### **Production Deployment**

**Server Requirements:**
- **Node.js**: Latest LTS version
- **Database**: MySQL 8.0+ or MariaDB
- **Memory**: Minimum 1GB RAM
- **Storage**: SSD recommended for performance

**Scaling Considerations:**
- **Database Optimization**: Proper indexing and query optimization
- **CDN Integration**: Static asset delivery
- **Load Balancing**: Multiple Ghost instances
- **Caching Layers**: Redis or Memcached

### **Docker Support**

Ghost provides official Docker images:

```dockerfile
# Official Ghost Docker setup
FROM ghost:5-alpine
COPY config.production.json /var/lib/ghost/config.production.json
EXPOSE 2368
```

## CFML Implementation Guidelines

### **Adapting Ghost Patterns for CFML**

**Post Management:**
```coldfusion
<!--- Mirror Ghost's post filtering logic --->
<cffunction name="getPostsByType" returntype="query">
    <cfargument name="type" type="string" default="all">
    <cfargument name="visibility" type="string" default="all">
    <cfargument name="author" type="string" default="">
    <cfargument name="tag" type="string" default="">
    
    <cfset var sql = "SELECT p.*, u.name as author_name FROM posts p 
                      INNER JOIN users u ON p.created_by = u.id WHERE 1=1">
    
    <cfswitch expression="#arguments.type#">
        <cfcase value="draft">
            <cfset sql &= " AND p.status = 'draft'">
        </cfcase>
        <cfcase value="published">
            <cfset sql &= " AND p.status = 'published'">
        </cfcase>
        <cfcase value="scheduled">
            <cfset sql &= " AND p.status = 'scheduled'">
        </cfcase>
        <cfcase value="sent">
            <cfset sql &= " AND p.status = 'sent'">
        </cfcase>
    </cfswitch>
    
    <cfif len(arguments.visibility) and arguments.visibility neq "all">
        <cfset sql &= " AND p.visibility = :visibility">
    </cfif>
    
    <cfquery name="local.result" datasource="blog">
        #preserveSingleQuotes(sql)#
        <cfif len(arguments.visibility) and arguments.visibility neq "all">
            <cfqueryparam name="visibility" value="#arguments.visibility#" cfsqltype="cf_sql_varchar">
        </cfif>
    </cfquery>
    
    <cfreturn local.result>
</cffunction>
```

**Admin Interface Patterns:**
```coldfusion
<!--- Implement Ghost's admin navigation structure --->
<nav class="gh-nav">
    <ul class="gh-nav-list">
        <li class="gh-nav-item">
            <a href="/ghost/admin" class="gh-nav-link">
                <i class="icon-dashboard"></i>
                <span>Dashboard</span>
            </a>
        </li>
        <li class="gh-nav-item">
            <a href="/ghost/admin/posts" class="gh-nav-link">
                <i class="icon-posts"></i>
                <span>Posts</span>
            </a>
            <ul class="gh-nav-submenu">
                <li><a href="/ghost/admin/posts?type=draft">Drafts</a></li>
                <li><a href="/ghost/admin/posts?type=published">Published</a></li>
                <li><a href="/ghost/admin/posts?type=scheduled">Scheduled</a></li>
            </ul>
        </li>
    </ul>
</nav>
```

### **Database Schema Adaptation**

**Posts Table for CFML:**
```sql
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    status ENUM('draft', 'published', 'scheduled', 'sent') DEFAULT 'draft',
    visibility ENUM('public', 'members', 'paid', 'tiers') DEFAULT 'public',
    type ENUM('post', 'page') DEFAULT 'post',
    feature_image VARCHAR(500),
    excerpt TEXT,
    content LONGTEXT,
    meta_title VARCHAR(255),
    meta_description TEXT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,
    INDEX idx_status (status),
    INDEX idx_visibility (visibility),
    INDEX idx_type (type),
    INDEX idx_published_at (published_at),
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

## Migration Strategy

### **From Legacy Systems to Ghost-like Architecture**

**Phase 1: Database Schema Alignment**
1. Update existing tables to match Ghost schema
2. Add missing fields (uuid, visibility, meta fields)
3. Implement proper indexing for performance

**Phase 2: Admin Interface Modernization**
1. Implement React components for settings
2. Update post management with Ghost-style filtering
3. Add card-based content editor

**Phase 3: API Development**
1. Create REST API endpoints matching Ghost API
2. Implement authentication and authorization
3. Add webhook system for integrations

**Phase 4: Theme System**
1. Implement Handlebars-like templating
2. Create theme structure and helper functions
3. Add responsive image handling

## Best Practices & Recommendations

### **Content Management**

1. **Status Workflow**: Implement clear draft → published workflow
2. **Version Control**: Track content changes and revisions
3. **SEO Optimization**: Automatic meta tag generation
4. **Image Handling**: Responsive image generation and optimization

### **Performance**

1. **Database Optimization**: Proper indexing and query optimization
2. **Caching Strategy**: Multi-layer caching implementation
3. **Asset Optimization**: Minification and compression
4. **CDN Integration**: Global content delivery

### **Security**

1. **Input Validation**: Comprehensive data sanitization
2. **Access Control**: Role-based permission system
3. **HTTPS Only**: Secure communication protocols
4. **Regular Updates**: Keep dependencies current

### **Scalability**

1. **Modular Architecture**: Separate concerns into distinct modules
2. **API-First Design**: Build with API integration in mind
3. **Horizontal Scaling**: Design for multiple server instances
4. **Monitoring**: Comprehensive logging and monitoring

This architectural guide provides the foundation for implementing a modern, Ghost-inspired content management system using any technology stack while maintaining the core principles and user experience that make Ghost successful in the publishing world.