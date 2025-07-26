# Spike Tailwind Pro Template - Design Style Guide

## Overview

Spike Tailwind Pro is a comprehensive admin dashboard template that provides the design foundation for the CFGhost CMS admin interface. This template offers modern, clean, and professional UI components built with TailwindCSS 3.4.3.

## Template Structure

### **Layout System**
- **Framework**: TailwindCSS 3.4.3 with custom theme extensions
- **Grid System**: 12-column responsive grid (`grid grid-cols-12 gap-6`)
- **Layout Variants**: 
  - Main (default)
  - Dark mode
  - Horizontal navigation
  - Mini sidebar
  - RTL (Right-to-left) support

### **Typography**
- **Primary Font**: Plus Jakarta Sans (Google Fonts)
- **Weights Available**: 400, 500, 600, 700
- **Icon System**: 
  - Iconify icons (`iconify-icon`)
  - Tabler Icons webfont
  - Solar icon pack for interface elements

## Core Components

### **Card Components**
```html
<div class="card mb-6">
  <div class="card-body">
    <h5 class="card-title">Title Here</h5>
    <p class="card-subtitle">Subtitle text</p>
    <!-- Card content -->
  </div>
</div>
```

**Key Classes:**
- `card` - Base card container
- `card-body` - Content wrapper with padding
- `card-title` - Primary heading
- `card-subtitle` - Secondary text
- `mb-6` - Margin bottom spacing

### **Navigation Structure**

#### Sidebar Navigation
- **Container**: `application-sidebar-brand`
- **Accordion System**: `hs-accordion` for collapsible menus
- **Navigation Items**: Hierarchical structure with icons and labels
- **Mobile Support**: Overlay system for responsive design

#### Header Components
- **Toggle Button**: Sidebar collapse/expand functionality
- **Logo System**: Multiple variants for different themes/layouts
- **Search Bar**: Integrated search functionality
- **User Menu**: Profile dropdown with settings

### **Color System & Theming**

#### Theme Variants
- **Light Theme**: Default bright interface
- **Dark Theme**: Dark background with light text
- **Color Themes**: Multiple predefined color schemes

#### Status Colors
- **Primary**: Blue (`bg-lightprimary`, `text-primary`)
- **Success**: Green (`bg-lightsuccess`, `text-success`)
- **Warning**: Orange/Yellow (`bg-lightwarning`, `text-warning`)
- **Error**: Red (`bg-lighterror`, `text-error`)
- **Info**: Light blue (`bg-lightinfo`, `text-info`)

#### Badge System
```html
<div class="badge bg-lightwarning dark:bg-darkwarning border-warning text-warning">
  Status Text
</div>
```

### **Form Components**

#### Input Fields
- **Base Class**: `form-control`
- **Input Groups**: Support for icons and addons
- **Validation States**: Error and success styling
- **Grid Layout**: Responsive form layouts

#### Buttons
```html
<button class="btn btn-primary">Primary Button</button>
<button class="btn btn-outline-secondary">Secondary Button</button>
```

**Button Variants:**
- `btn-primary` - Main action buttons
- `btn-secondary` - Secondary actions
- `btn-outline-*` - Outline style variants
- `btn-sm`, `btn-lg` - Size variants

### **Table Components**

#### DataTable Integration
- **Base Class**: `table`
- **DataTables.js**: Enhanced functionality
- **Responsive**: Mobile-friendly table layouts
- **Styling**: Consistent with overall theme

#### Table Features
- Sorting and pagination
- Search functionality
- Export capabilities
- Row selection
- Custom column rendering

### **Layout Containers**

#### Main Structure
```html
<div id="main-wrapper" class="flex p-5">
  <aside id="application-sidebar-brand"><!-- Sidebar --></aside>
  <div class="body-wrapper">
    <div class="container-fluid">
      <div class="grid grid-cols-12 gap-6">
        <!-- Content grid -->
      </div>
    </div>
  </div>
</div>
```

#### Container Types
- `container` - Standard container
- `container-fluid` - Full width container
- `full-container` - Maximum width utilization

## Design Patterns

### **Responsive Design**
- **Mobile First**: Progressive enhancement approach
- **Breakpoints**: Standard TailwindCSS breakpoints
- **Navigation**: Collapsible sidebar for mobile
- **Grid System**: Flexible column layouts

### **Accessibility Features**
- **ARIA Labels**: Proper labeling for screen readers
- **Keyboard Navigation**: Full keyboard support
- **Focus States**: Visible focus indicators
- **Color Contrast**: WCAG compliant color ratios

### **Animation & Interactions**
- **Smooth Transitions**: CSS transitions for hover states
- **Loading States**: Spinner and skeleton components
- **Hover Effects**: Consistent interaction feedback
- **Toast Notifications**: User feedback system

## CFGhost CMS Integration

### **Why Spike Tailwind Pro is Perfect for CFGhost Admin**

1. **Blog-Focused Design**: Template includes blog post management interfaces
2. **Card-Based Layout**: Matches CFGhost's current post card design
3. **Modern Aesthetics**: Clean, professional interface suitable for content management
4. **Comprehensive Components**: All necessary admin interface elements included
5. **TailwindCSS Foundation**: Consistent with current CFGhost admin styling approach

### **Key Components for CFGhost Admin**

#### Posts Management
**Blog Post Card Pattern:**
```html
<div class="lg:col-span-4 md:col-span-6 col-span-12">
  <div class="card overflow-hidden group animate-card">
    <div class="relative">
      <a href="post-detail.html">
        <img src="featured-image.jpg" class="w-full max-w-full" alt="...">
      </a>
      <span class="badge border-0 font-semibold leading-tight text-xs bg-white dark:bg-dark text-dark dark:text-white absolute right-4 bottom-4">
        2 min Read
      </span>
    </div>
    <div class="card-body p-5">
      <div class="relative w-fit">
        <img src="author-avatar.jpg" alt="" class="rounded-full -mt-10 h-10 w-10">
      </div>
      <span class="bg-lightgray dark:bg-darkgray text-dark dark:text-white text-xs badge border-0 leading-tight font-semibold mt-5 block w-fit">
        Category
      </span>
      <a class="block my-4 font-semibold text-dark dark:text-darklink text-lg group-hover:text-primary" href="post-detail.html">
        Post Title Here
      </a>
      <div class="flex items-center gap-4">
        <div class="flex items-center gap-2 text-bodytext dark:text-darklink">
          <i class="ti ti-eye text-dark dark:text-darklink text-lg"></i>4,150
        </div>
        <div class="flex items-center gap-2 text-bodytext dark:text-darklink">
          <i class="ti ti-message-2 text-dark dark:text-darklink text-lg"></i>38
        </div>
        <div class="flex items-center text-xs ms-auto text-bodytext dark:text-darklink">
          <i class="ti ti-point text-bodytext dark:text-darklink"></i>Jan 15
        </div>
      </div>
    </div>
  </div>
</div>
```

**Data Table with Actions:**
```html
<div class="table-responsive">
  <table class="table">
    <thead>
      <tr>
        <th>Title</th>
        <th>Status</th>
        <th>Author</th>
        <th>Date</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="font-medium">Post Title</td>
        <td>
          <div class="badge bg-lightgray dark:bg-darkgray text-dark dark:text-white">
            Published
          </div>
        </td>
        <td>Author Name</td>
        <td>2024-01-15</td>
        <td class="whitespace-nowrap relative">
          <a class="text-xl hs-tooltip hs-tooltip-toggle" href="javascript:void(0)">
            <i class="ti ti-dots-vertical"></i>
            <span class="tooltip hs-tooltip-content">Edit</span>
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

#### Dashboard Elements
- **Statistics Cards**: Post counts, analytics with trend indicators
- **Recent Activity**: Latest posts and actions in timeline format
- **Quick Actions**: New post, settings access with prominent CTAs
- **Navigation**: Hierarchical accordion menu structure

#### Form Components
- **Post Editor**: Rich text editing interface with toolbar
- **Settings Forms**: Configuration panels with validation
- **Media Upload**: Drag-and-drop image handling
- **Metadata**: SEO and social sharing options with preview

### **Implementation Benefits**

1. **Consistency**: Unified design language across all admin pages
2. **Maintainability**: Well-structured CSS with TailwindCSS utilities
3. **Responsiveness**: Works seamlessly across all device sizes
4. **Customization**: Easy to modify colors, spacing, and components
5. **Performance**: Optimized CSS with minimal overhead

## File Structure

The Spike Tailwind Pro template is organized into three main directories:

### **spike-tailwind-pro/** (Compiled/Production Files)
```
spike-tailwind-pro/
├── assets/
│   ├── css/theme.css           # Compiled main stylesheet
│   ├── images/                 # Template images and icons
│   ├── js/                     # Compiled JavaScript components
│   └── libs/                   # Third-party libraries (Preline, ApexCharts, etc.)
├── main/                       # Default layout variant
├── dark/                       # Dark theme variant
├── horizontal/                 # Horizontal navigation layout
├── minisidebar/               # Collapsed sidebar layout
├── rtl/                       # Right-to-left layout
├── docs/                      # Documentation pages
└── landingpage/               # Landing page example
```

### **spike-tailwind-source/** (Development Source)
```
spike-tailwind-source/
├── src/
│   ├── assets/
│   │   ├── tailwind/
│   │   │   ├── tailwind.css    # Source TailwindCSS file
│   │   │   ├── components/     # Component-specific styles
│   │   │   └── utilities/      # Utility classes
│   │   ├── js/                 # Source JavaScript files
│   │   └── images/             # Source images
│   ├── main/                   # Main theme source files
│   ├── dark/                   # Dark theme source files
│   └── [other variants]/       # Other layout variants
├── gulpfile.js                 # Gulp build configuration
├── package.json                # Node.js dependencies
└── tailwind.config.js          # TailwindCSS configuration
```

### **spike-tailwind-starter/** (Minimal Starter Kit)
```
spike-tailwind-starter/
├── src/
│   ├── assets/
│   │   ├── tailwind/tailwind.css
│   │   └── js/vendor.min.js
│   ├── index.html              # Basic starter page
│   └── partials/               # Essential partials
├── gulpfile.js
├── package.json
└── tailwind.config.js
```

## Build System & Dependencies

### **Development Dependencies**
The template uses a comprehensive build system based on Node.js and Gulp:

**Key Dependencies (from package.json):**
```json
{
  "dependencies": {
    "@preline/dropdown": "^2.0.2",
    "@preline/input-number": "^2.0.2", 
    "@preline/overlay": "^2.0.2",
    "@preline/stepper": "^2.0.2",
    "@preline/tooltip": "^2.0.2",
    "@tabler/icons": "^2.44.0",
    "apexcharts": "^3.45.1",
    "fullcalendar": "^6.1.9",
    "iconify-icon": "^1.0.8",
    "preline": "^2.0.2",
    "tailwindcss": "^3.4.1"
  }
}
```

### **TailwindCSS Configuration**
**Custom Theme Extensions:**
```javascript
module.exports = {
  darkMode: 'class',
  content: ['node_modules/preline/dist/*.js','./src/**/*.html'],
  theme: {
    fontFamily: {
      sans: ['Plus Jakarta Sans', 'sans-serif'],
    },
    extend: {
      colors: {
        primary: "var(--color-primary)",
        secondary: "var(--color-secondary)",
        lightprimary: "var(--color-lightprimary)",
        lightsecondary: "var(--color-lightsecondary)",
        // ... and many more custom color variables
      },
      fontSize: {
        "fs_15": "15px",
        "fs_13": "13px", 
        "fs_12": "12px",
        // ... custom font sizes
      }
    }
  }
}
```

### **Gulp Build Process**
The template includes automated build tasks for:
- **SCSS/CSS compilation** with TailwindCSS processing
- **JavaScript minification** and concatenation
- **Image optimization** with modern formats
- **File watching** for development
- **Browser synchronization** for live reload
- **Distribution building** for production

### **Component Architecture**

#### **Preline UI Integration**
The template extensively uses Preline UI components:
- **Dropdowns**: `hs-dropdown` for menus and filters
- **Overlays**: `hs-overlay` for modals and sidebars  
- **Tooltips**: `hs-tooltip` for contextual information
- **Steppers**: `hs-stepper` for multi-step forms
- **Input Numbers**: Enhanced numeric inputs

#### **Icon System**
Multiple icon libraries are integrated:
- **Tabler Icons**: Primary icon set (`ti ti-*` classes)
- **Iconify**: Additional icons (`iconify-icon` components)
- **Solar Icons**: Specific icon pack for interface elements

#### **JavaScript Applications**
Ready-to-use JavaScript modules for:
- **ApexCharts**: Data visualization and analytics
- **DataTables**: Advanced table functionality
- **FullCalendar**: Calendar and scheduling
- **Owl Carousel**: Image and content sliders
- **Dropzone**: File upload handling

## Customization Guidelines

### **Color Customization**
- Modify CSS custom properties for theme colors
- Update TailwindCSS configuration for new color schemes
- Maintain consistency across light/dark variants

### **Layout Modifications**
- Adjust grid breakpoints for different screen sizes
- Customize sidebar width and navigation structure
- Modify container max-widths for content areas

### **Component Extensions**
- Add new card variants for specific content types
- Create custom form components for Ghost-specific fields
- Implement additional table features for content management

## CFGhost CMS Implementation Recommendations

### **Adapting Spike Components for CFGhost Admin**

## CFGhost Current Implementation Status

### **Authentication System - Dual Login Support**

CFGhost now supports both Google OAuth and traditional email/password authentication:

#### Firebase Google OAuth Integration
```html
<!-- Firebase Configuration in login.cfm -->
<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
    import { getAuth, signInWithPopup, GoogleAuthProvider } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';
    
    const firebaseConfig = {
        // Firebase configuration
    };
    
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const provider = new GoogleAuthProvider();
</script>
```

#### Email/Password Authentication  
- SHA-256 password hashing for security
- Session management with CFML uppercase variables
- Proper error handling and validation

### **Session Management System**

CFGhost uses unified session management across the application:

```cfml
<!-- Session Variables (uppercase for CFML compatibility) -->
<cfset session.ISLOGGEDIN = true>
<cfset session.USERID = userLogin.id>
<cfset session.USERNAME = userLogin.name>
<cfset session.USEREMAIL = userLogin.email>
<cfset session.USERROLE = userLogin.role_name ?: "Author">
```

### **User Profile System**

Complete user profile management with:
- Profile image upload with automatic resizing
- Social media integration (bio, location, website, social links)
- Real-time AJAX form updates
- Quick Stats dashboard with visual metrics

### **Alert and Notification Messages**

#### Floating Toast Notifications (Primary Method)
CFGhost uses floating toast-style notifications for all user feedback. These appear in the top-right corner and auto-dismiss after 5 seconds:

```javascript
// Show message function for consistent notifications
function showMessage(message, type) {
    // Remove any existing messages
    const existingMessage = document.querySelector('.alert-message');
    if (existingMessage) {
        existingMessage.remove();
    }
    
    // Create message element
    const messageEl = document.createElement('div');
    messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
    messageEl.style.animation = 'slideInRight 0.3s ease-out';
    
    if (type === 'success') {
        messageEl.className += ' bg-success text-white';
        messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
    } else if (type === 'error') {
        messageEl.className += ' bg-error text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
    } else if (type === 'warning') {
        messageEl.className += ' bg-warning text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-triangle me-2"></i>${message}`;
    } else {
        messageEl.className += ' bg-primary text-white';
        messageEl.innerHTML = `<i class="ti ti-info-circle me-2"></i>${message}`;
    }
    
    // Add to page
    document.body.appendChild(messageEl);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        messageEl.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            messageEl.remove();
        }, 300);
    }, 5000);
}
```

#### Message Types and Colors
- **Success**: `bg-success` (green) - For successful operations like "Profile updated successfully"
- **Error**: `bg-error` (red) - For errors like "Invalid email or password"
- **Warning**: `bg-warning` (orange) - For warnings like "Session expiring soon"
- **Info**: `bg-primary` (blue) - For informational messages

#### Usage Examples
```javascript
// Success message
showMessage('Profile updated successfully', 'success');

// Error message
showMessage('Invalid email or password', 'error');

// Warning message
showMessage('Your session will expire in 5 minutes', 'warning');

// Info message
showMessage('New features available', 'info');
```

#### Animation CSS
```css
@keyframes slideInRight {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes slideOutRight {
    from {
        transform: translateX(0);
        opacity: 1;
    }
    to {
        transform: translateX(100%);
        opacity: 0;
    }
}
```

#### Inline Alert Messages (Alternative)
For form validation or static alerts that need to persist, use inline messages:

```html
<!-- Error Message -->
<div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-alert-circle text-red-500 mr-2"></i>
    <span class="text-sm font-medium">Error message here</span>
</div>

<!-- Success Message -->
<div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-check-circle text-green-500 mr-2"></i>
    <span class="text-sm font-medium">Success message here</span>
</div>

<!-- Warning Message -->
<div class="bg-yellow-50 border border-yellow-200 text-yellow-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-alert-triangle text-yellow-500 mr-2"></i>
    <span class="text-sm font-medium">Warning message here</span>
</div>

<!-- Info Message -->
<div class="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-lg mb-6 flex items-center">
    <i class="ti ti-info-circle text-blue-500 mr-2"></i>
    <span class="text-sm font-medium">Info message here</span>
</div>
```

### **Adapting Spike Components for CFGhost Admin**

#### **Posts List Page Enhancement**
Replace the current simple table with the Spike blog card layout:
```html
<!-- Current CFGhost posts.cfm can be enhanced with: -->
<div class="grid grid-cols-12 gap-6">
  <cfloop array="#postsResult.data#" index="post">
    <div class="lg:col-span-4 md:col-span-6 col-span-12">
      <div class="card overflow-hidden group animate-card">
        <!-- Enhanced post card with status indicators, author info, and actions -->
      </div>
    </div>
  </cfloop>
</div>
```

#### **Status Badge System**
Implement Spike's badge patterns for post status:
```html
<cfswitch expression="#post.status#">
  <cfcase value="published">
    <span class="badge bg-lightsuccess text-success">Published</span>
  </cfcase>
  <cfcase value="draft">
    <span class="badge bg-lightwarning text-warning">Draft</span>
  </cfcase>
  <cfcase value="scheduled">
    <span class="badge bg-lightinfo text-info">Scheduled</span>
  </cfcase>
</cfswitch>
```

#### **Navigation Integration**
Update the CFGhost sidebar to use Spike's accordion navigation:
```html
<nav class="hs-accordion-group w-full flex flex-col">
  <ul id="sidebarnav">
    <li class="sidebar-item">
      <a class="sidebar-link" href="/ghost/admin">
        <iconify-icon icon="solar:screencast-2-line-duotone"></iconify-icon>
        <span class="hide-menu">Dashboard</span>
      </a>
    </li>
    <li class="hs-accordion sidebar-item">
      <a class="cursor-pointer hs-accordion-toggle sidebar-link">
        <iconify-icon icon="solar:book-2-line-duotone"></iconify-icon>
        <span class="hide-menu">Posts</span>
      </a>
      <div class="hs-accordion-content">
        <ul>
          <li><a href="/ghost/admin/posts">All Posts</a></li>
          <li><a href="/ghost/admin/posts/drafts">Drafts</a></li>
          <li><a href="/ghost/admin/posts?type=published">Published</a></li>
        </ul>
      </div>
    </li>
  </ul>
</nav>
```

### **Asset Integration Strategy**

#### **CSS Integration**
1. Copy `spike-tailwind-pro/assets/css/theme.css` to CFGhost assets
2. Update CFML templates to include Spike stylesheets
3. Customize color variables for CFGhost branding

#### **JavaScript Integration**
1. Include Preline UI components for enhanced interactions
2. Integrate ApexCharts for analytics dashboard
3. Add DataTables for advanced post management features

#### **Image Assets**
1. Replace placeholder images with CFGhost-specific imagery
2. Update logos and branding elements
3. Optimize images for CFGhost's content management context

### **Migration Checklist**

- [ ] **Assets Setup**: Copy and organize Spike assets in CFGhost directory structure
- [ ] **Template Updates**: Integrate Spike HTML patterns into existing CFML templates
- [ ] **Styling**: Apply Spike's TailwindCSS classes to CFGhost components
- [ ] **JavaScript**: Add Preline UI functionality for interactive elements
- [ ] **Icons**: Replace current icons with Tabler/Iconify icon system
- [ ] **Responsive**: Test all layouts across device breakpoints
- [ ] **Dark Mode**: Implement dark theme toggle functionality
- [ ] **Accessibility**: Ensure all Spike components meet accessibility standards

This design system provides a solid foundation for creating a modern, professional, and user-friendly CFGhost CMS admin interface that maintains consistency while offering the flexibility needed for content management workflows.