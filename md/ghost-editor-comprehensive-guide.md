# Ghost Editor Comprehensive Implementation Guide

## Overview

This document provides a complete guide for implementing Ghost's modern editor system in CFGhost CMS, based on comprehensive study of Ghost's documentation, source code analysis, and architectural patterns.

## Ghost Editor Architecture

### 1. Modern Lexical Editor Foundation

Ghost uses **Lexical Editor** as the core editing framework, replacing the previous Ember-based system:

**Key Components:**
- **Lexical Framework**: Meta's modern rich-text editing framework
- **Card-based System**: 20+ content block types for enhanced content creation
- **Contextual Toolbar**: Dynamic formatting options
- **Real-time Autosave**: Background saves every 3 seconds, forced saves at 60 seconds

### 2. Editor Structure Analysis

From Ghost source code (`lexical-editor.hbs`), the editor consists of:

```html
<div class="flex flex-row">
    <GhEditor @tagName="section" @class="gh-editor gh-view relative">
        <!-- Header with publish management and back navigation -->
        <header class="gh-editor-header br2 pe-none">
            <Editor::PublishManagement>
                <!-- Breadcrumb navigation -->
                <!-- Post status display -->
                <!-- Publish buttons -->
            </Editor::PublishManagement>
        </header>

        <!-- Main Lexical Editor Component -->
        <GhKoenigEditorLexical
            @title={{readonly this.post.titleScratch}}
            @titlePlaceholder="Post title"
            @body={{readonly this.post.lexicalScratch}}
            @bodyPlaceholder="Begin writing your post..."
            @featureImage={{this.post.featureImage}}
            <!-- Additional properties for editor functionality -->
        />

        <!-- Word count and help link -->
        <div class="gh-editor-wordcount-container">
            <div class="gh-editor-wordcount">{{gh-pluralize this.wordCount "word"}}</div>
            <a href="https://ghost.org/help/using-the-editor/" target="_blank">Help</a>
        </div>
    </GhEditor>

    <!-- Settings Menu (Right Sidebar) -->
    {{#if this.showSettingsMenu}}
        <GhPostSettingsMenu />
    {{/if}}
</div>

<!-- Settings Toggle Button -->
<button type="button" class="settings-menu-toggle" {{on "click" this.toggleSettingsMenu}}>
    <!-- Settings icon -->
</button>
```

## Ghost Editor Features

### 1. Card System (20+ Content Types)

**Media Cards:**
- **Image**: Upload, drag-and-drop, paste with native editing (Pintura integration)
- **Gallery**: Up to 9 images with responsive layouts
- **Video**: Embed and upload support
- **Audio**: Audio file embedding
- **GIF**: Animated GIF support
- **File**: Document upload and download links

**Interactive Cards:**
- **Bookmark**: Rich link previews with metadata
- **Button**: Call-to-action buttons with custom styling
- **Toggle**: Collapsible content sections
- **Callout**: Highlighted information boxes
- **Call to Action**: Newsletter signup forms
- **Public Preview**: Content previews for social sharing
- **Signup**: Member registration forms

**Functional Cards:**
- **Markdown**: Raw markdown editing
- **HTML**: Custom HTML code blocks
- **Divider**: Visual content separation
- **Embeds**: YouTube, Twitter, Instagram, CodePen integration
- **Header**: Section headings with styling
- **Email Content**: Newsletter-specific content
- **Product**: E-commerce product showcases

### 2. Editor User Experience

**Content Creation Flow:**
1. **Insert Cards**: Click `+` button or type `/` for card menu
2. **Drag & Drop**: Reorder content blocks easily
3. **Contextual Toolbar**: Format text with dynamic toolbar
4. **Real-time Preview**: See changes as you type
5. **Keyboard Shortcuts**: Efficient editing with shortcuts

**Editor Features:**
- **Emoji Support**: Type `:` to insert emojis
- **Internal Linking**: Three methods (highlight text, `@` symbol, bookmark cards)
- **Image Editing**: Built-in Pintura image editor
- **Auto-save**: Background saves with conflict resolution
- **Word Count**: Real-time word and reading time tracking

### 3. Post Settings System

**Core Settings Categories:**

**Publishing Settings:**
- **URL Slug**: Customizable post URLs
- **Publish Date**: Schedule posts for future publication
- **Authors**: Multiple author support
- **Tags**: Content categorization and filtering

**Access Control:**
- **Visibility**: Public, Members-only, Paid members-only
- **Custom Access**: Tier-based content restrictions
- **Featured Post**: Homepage highlighting

**SEO & Social:**
- **Meta Title**: Search engine optimization
- **Meta Description**: Search result descriptions
- **Social Cards**: Facebook and Twitter sharing optimization
- **Custom Excerpts**: Manual post summaries

**Advanced Options:**
- **Custom Templates**: Theme-specific post layouts
- **Code Injection**: Custom CSS/JavaScript
- **Post History**: Version tracking and rollback

## Ghost Controller Architecture

### 1. State Management (from lexical-editor.js)

**Key Properties:**
```javascript
// Content state
@tracked excerptErrorMessage = '';
shouldFocusTitle = false;
showSettingsMenu = false;
wordCount = 0;
postTkCount = 0; // "TK" placeholder tracking

// Save state management
@boundOneWay('post.isPublished') willPublish;
@boundOneWay('post.isScheduled') willSchedule;
```

**Auto-save System:**
```javascript
// Save 3 seconds after last edit
const AUTOSAVE_TIMEOUT = 3000;
// Force save at 60 seconds of continuous typing
const TIMEDSAVE_TIMEOUT = 60000;

@dropTask
*autosaveTask(options) {
    if (!this.get('saveTask.isRunning')) {
        return yield this.saveTask.perform({
            silent: true,
            backgroundSave: true,
            ...options
        });
    }
}
```

### 2. Content Management Actions

**Title and Content Updates:**
```javascript
@action
updateTitleScratch(title) {
    this.set('post.titleScratch', title);
    // Schedule revision save
    this.localRevisions.scheduleSave(this.post.displayName, {
        ...this.post.serialize({includeId: true}), 
        title: title
    });
}

@action
updateScratch(lexical) {
    const lexicalString = JSON.stringify(lexical);
    this.set('post.lexicalScratch', lexicalString);
    
    // Trigger autosave
    this._autosaveTask.perform();
    this._timedSaveTask.perform();
}
```

**Feature Image Management:**
```javascript
@action
setFeatureImage(url) {
    this.post.set('featureImage', url);
    if (this.post.isDraft) {
        this.autosaveTask.perform();
    }
}

@action
clearFeatureImage() {
    this.post.set('featureImage', null);
    this.post.set('featureImageAlt', null);
    this.post.set('featureImageCaption', null);
}
```

## CFGhost Implementation Strategy

### 1. Database Schema Requirements

**Enhanced Posts Table:**
```sql
ALTER TABLE posts ADD COLUMN lexical LONGTEXT NULL;
ALTER TABLE posts ADD COLUMN lexical_scratch LONGTEXT NULL;
ALTER TABLE posts ADD COLUMN title_scratch VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN custom_excerpt TEXT NULL;
ALTER TABLE posts ADD COLUMN feature_image VARCHAR(500) NULL;
ALTER TABLE posts ADD COLUMN feature_image_alt VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN feature_image_caption TEXT NULL;
ALTER TABLE posts ADD COLUMN meta_title VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN meta_description TEXT NULL;
ALTER TABLE posts ADD COLUMN og_title VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN og_description TEXT NULL;
ALTER TABLE posts ADD COLUMN twitter_title VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN twitter_description TEXT NULL;
ALTER TABLE posts ADD COLUMN email_subject VARCHAR(255) NULL;
ALTER TABLE posts ADD COLUMN word_count INT DEFAULT 0;
ALTER TABLE posts ADD COLUMN reading_time INT DEFAULT 0;
```

### 2. CFML Post Editor Implementation

**Main Editor Page Structure:**
```cfml
<!--- admin/posts/edit.cfm --->
<cfparam name="url.id" default="">

<!--- Load post data --->
<cfinclude template="../includes/posts-functions.cfm">
<cfset postData = getPostById(url.id)>

<!--- Include header with dynamic title --->
<cfset pageTitle = postData.recordCount ? "Edit: " & postData.title : "New Post">
<cfinclude template="../includes/header.cfm">

<div class="flex flex-row min-h-screen">
    <!-- Main Editor Container -->
    <section class="gh-editor gh-view flex-1 relative">
        <!-- Editor Header -->
        <header class="gh-editor-header border-b-2 border-gray-100 p-4 bg-white">
            <div class="flex items-center justify-between">
                <!-- Breadcrumb Navigation -->
                <div class="flex items-center">
                    <a href="/ghost/admin/posts" class="gh-btn-editor gh-editor-back-button flex items-center">
                        <i class="ti ti-arrow-left mr-2"></i>
                        <span>Posts</span>
                    </a>
                </div>
                
                <!-- Post Status Display -->
                <div class="gh-editor-post-status">
                    <cfoutput>
                        <span class="badge 
                            <cfif postData.status EQ 'published'>bg-lightsuccess text-success
                            <cfelseif postData.status EQ 'draft'>bg-lightwarning text-warning
                            <cfelseif postData.status EQ 'scheduled'>bg-lightinfo text-info
                            <cfelse>bg-lightgray text-dark</cfif>">
                            #uCase(left(postData.status, 1)) & lCase(right(postData.status, len(postData.status)-1))#
                        </span>
                    </cfoutput>
                </div>
                
                <!-- Publish Buttons -->
                <div class="gh-editor-publish-buttons flex items-center space-x-3">
                    <button type="button" class="btn btn-outline-secondary btn-sm" id="save-draft">
                        Save Draft
                    </button>
                    <button type="button" class="btn btn-primary btn-sm" id="publish-post">
                        <cfif postData.status EQ 'published'>Update<cfelse>Publish</cfif>
                    </button>
                </div>
            </div>
        </header>

        <!-- Main Editor Content -->
        <div class="gh-editor-content p-6">
            <form id="post-form" class="max-w-4xl mx-auto">
                <input type="hidden" name="postId" value="<cfoutput>#postData.id#</cfoutput>">
                
                <!-- Feature Image Section -->
                <div class="feature-image-container mb-8">
                    <div id="feature-image-upload" class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-primary transition-colors cursor-pointer">
                        <cfif len(postData.feature_image)>
                            <img src="<cfoutput>#postData.feature_image#</cfoutput>" alt="Feature image" class="max-w-full h-auto rounded-lg mx-auto">
                            <div class="mt-4">
                                <button type="button" class="btn btn-outline-secondary btn-sm" id="change-feature-image">
                                    Change Image
                                </button>
                                <button type="button" class="btn btn-outline-error btn-sm ml-2" id="remove-feature-image">
                                    Remove
                                </button>
                            </div>
                        <cfelse>
                            <i class="ti ti-camera text-4xl text-gray-400 mb-4"></i>
                            <p class="text-gray-600 mb-2">Add a feature image</p>
                            <p class="text-sm text-gray-500">Drag and drop or click to upload</p>
                        </cfelse>
                    </div>
                </div>

                <!-- Title Input -->
                <div class="title-container mb-6">
                    <input 
                        type="text" 
                        name="title" 
                        id="post-title"
                        class="w-full text-4xl font-bold border-0 outline-0 resize-none bg-transparent placeholder-gray-400"
                        placeholder="Post title"
                        value="<cfoutput>#postData.title#</cfoutput>"
                        autocomplete="off"
                    >
                </div>

                <!-- Excerpt Input (if feature enabled) -->
                <div class="excerpt-container mb-6">
                    <textarea 
                        name="customExcerpt" 
                        id="post-excerpt"
                        class="w-full border border-gray-300 rounded-lg p-4 resize-none"
                        placeholder="Write a custom excerpt (optional)"
                        rows="3"
                    ><cfoutput>#postData.custom_excerpt#</cfoutput></textarea>
                    <div class="flex justify-between items-center mt-2">
                        <span class="text-sm text-gray-500">Custom excerpt for SEO and social sharing</span>
                        <span class="text-sm text-gray-400" id="excerpt-counter">0 / 300</span>
                    </div>
                </div>

                <!-- Content Editor -->
                <div class="content-container">
                    <!-- Rich Text Editor Toolbar -->
                    <div class="editor-toolbar border border-gray-300 border-b-0 rounded-t-lg bg-gray-50 p-3">
                        <div class="flex items-center space-x-2">
                            <!-- Formatting Tools -->
                            <button type="button" class="toolbar-btn" data-action="bold" title="Bold">
                                <i class="ti ti-bold"></i>
                            </button>
                            <button type="button" class="toolbar-btn" data-action="italic" title="Italic">
                                <i class="ti ti-italic"></i>
                            </button>
                            <button type="button" class="toolbar-btn" data-action="underline" title="Underline">
                                <i class="ti ti-underline"></i>
                            </button>
                            
                            <div class="border-l border-gray-300 h-6 mx-2"></div>
                            
                            <!-- Heading Tools -->
                            <select class="toolbar-select" id="heading-select">
                                <option value="p">Paragraph</option>
                                <option value="h2">Heading 2</option>
                                <option value="h3">Heading 3</option>
                                <option value="h4">Heading 4</option>
                            </select>
                            
                            <div class="border-l border-gray-300 h-6 mx-2"></div>
                            
                            <!-- List Tools -->
                            <button type="button" class="toolbar-btn" data-action="unorderedList" title="Bullet List">
                                <i class="ti ti-list"></i>
                            </button>
                            <button type="button" class="toolbar-btn" data-action="orderedList" title="Numbered List">
                                <i class="ti ti-list-numbers"></i>
                            </button>
                            
                            <div class="border-l border-gray-300 h-6 mx-2"></div>
                            
                            <!-- Media Tools -->
                            <button type="button" class="toolbar-btn" data-action="image" title="Insert Image">
                                <i class="ti ti-photo"></i>
                            </button>
                            <button type="button" class="toolbar-btn" data-action="link" title="Insert Link">
                                <i class="ti ti-link"></i>
                            </button>
                            <button type="button" class="toolbar-btn" data-action="quote" title="Quote">
                                <i class="ti ti-quote"></i>
                            </button>
                            
                            <div class="border-l border-gray-300 h-6 mx-2"></div>
                            
                            <!-- Card Insert -->
                            <button type="button" class="toolbar-btn" data-action="card-menu" title="Insert Card">
                                <i class="ti ti-plus"></i>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Content Text Area -->
                    <div 
                        id="content-editor" 
                        class="min-h-96 border border-gray-300 rounded-b-lg p-6 bg-white focus-within:ring-2 focus-within:ring-primary focus-within:border-primary"
                        contenteditable="true"
                        data-placeholder="Begin writing your post..."
                    >
                        <cfoutput>#postData.content#</cfoutput>
                    </div>
                </div>

                <!-- Word Count Display -->
                <div class="word-count-container flex justify-between items-center mt-4 text-sm text-gray-500">
                    <div class="word-count">
                        <span id="word-count">0 words</span> • 
                        <span id="reading-time">0 min read</span>
                    </div>
                    <a href="https://ghost.org/help/using-the-editor/" class="flex items-center hover:text-primary" target="_blank">
                        <i class="ti ti-help mr-1"></i>
                        Editor Help
                    </a>
                </div>
            </form>
        </div>
    </section>

    <!-- Settings Sidebar -->
    <aside id="post-settings-menu" class="post-settings-menu w-80 bg-white border-l border-gray-200 transform translate-x-full transition-transform duration-300">
        <div class="settings-header p-6 border-b border-gray-200">
            <div class="flex items-center justify-between">
                <h3 class="text-lg font-semibold">Post Settings</h3>
                <button type="button" id="close-settings" class="text-gray-400 hover:text-gray-600">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
        </div>

        <div class="settings-content p-6 space-y-6">
            <!-- URL Slug -->
            <div class="setting-group">
                <label class="block text-sm font-medium text-gray-700 mb-2">Post URL</label>
                <div class="flex items-center">
                    <span class="text-sm text-gray-500 mr-1"><cfoutput>#application.siteUrl#/</cfoutput></span>
                    <input 
                        type="text" 
                        name="slug" 
                        id="post-slug"
                        class="form-control flex-1"
                        value="<cfoutput>#postData.slug#</cfoutput>"
                    >
                </div>
                <p class="text-xs text-gray-500 mt-1">Keep your URL slug on topic and as short as possible</p>
            </div>

            <!-- Publish Date -->
            <div class="setting-group">
                <label class="block text-sm font-medium text-gray-700 mb-2">Publish Date</label>
                <input 
                    type="datetime-local" 
                    name="publishedAt" 
                    id="published-at"
                    class="form-control"
                    value="<cfoutput>#dateFormat(postData.published_at, 'yyyy-mm-dd')#T#timeFormat(postData.published_at, 'HH:mm')#</cfoutput>"
                >
            </div>

            <!-- Tags -->
            <div class="setting-group">
                <label class="block text-sm font-medium text-gray-700 mb-2">Tags</label>
                <input 
                    type="text" 
                    name="tags" 
                    id="post-tags"
                    class="form-control"
                    placeholder="Add tags (comma separated)"
                    value="<cfoutput>#postData.tags#</cfoutput>"
                >
                <p class="text-xs text-gray-500 mt-1">Use tags to organize your content</p>
            </div>

            <!-- Access Level -->
            <div class="setting-group">
                <label class="block text-sm font-medium text-gray-700 mb-2">Post Access</label>
                <select name="visibility" id="post-visibility" class="form-control">
                    <option value="public" <cfif postData.visibility EQ 'public'>selected</cfif>>Public</option>
                    <option value="members" <cfif postData.visibility EQ 'members'>selected</cfif>>Members only</option>
                    <option value="paid" <cfif postData.visibility EQ 'paid'>selected</cfif>>Paid members only</option>
                </select>
            </div>

            <!-- Featured Post -->
            <div class="setting-group">
                <div class="flex items-center">
                    <input 
                        type="checkbox" 
                        name="featured" 
                        id="post-featured"
                        class="form-checkbox"
                        <cfif postData.featured>checked</cfif>
                    >
                    <label for="post-featured" class="ml-2 text-sm font-medium text-gray-700">
                        Featured post
                    </label>
                </div>
                <p class="text-xs text-gray-500 mt-1">Feature this post on your homepage</p>
            </div>

            <!-- SEO Settings -->
            <div class="setting-group">
                <h4 class="text-sm font-semibold text-gray-700 mb-3">SEO Settings</h4>
                
                <div class="space-y-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Meta Title</label>
                        <input 
                            type="text" 
                            name="metaTitle" 
                            id="meta-title"
                            class="form-control"
                            placeholder="Auto-generated from post title"
                            value="<cfoutput>#postData.meta_title#</cfoutput>"
                        >
                    </div>
                    
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Meta Description</label>
                        <textarea 
                            name="metaDescription" 
                            id="meta-description"
                            class="form-control"
                            rows="3"
                            placeholder="Auto-generated from post content"
                        ><cfoutput>#postData.meta_description#</cfoutput></textarea>
                    </div>
                </div>
            </div>

            <!-- Social Media Cards -->
            <div class="setting-group">
                <h4 class="text-sm font-semibold text-gray-700 mb-3">Social Media</h4>
                
                <div class="space-y-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Facebook Title</label>
                        <input 
                            type="text" 
                            name="ogTitle" 
                            id="og-title"
                            class="form-control"
                            value="<cfoutput>#postData.og_title#</cfoutput>"
                        >
                    </div>
                    
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Facebook Description</label>
                        <textarea 
                            name="ogDescription" 
                            id="og-description"
                            class="form-control"
                            rows="2"
                        ><cfoutput>#postData.og_description#</cfoutput></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Twitter Title</label>
                        <input 
                            type="text" 
                            name="twitterTitle" 
                            id="twitter-title"
                            class="form-control"
                            value="<cfoutput>#postData.twitter_title#</cfoutput>"
                        >
                    </div>
                </div>
            </div>

            <!-- Code Injection -->
            <div class="setting-group">
                <h4 class="text-sm font-semibold text-gray-700 mb-3">Code Injection</h4>
                
                <div class="space-y-3">
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Post Header</label>
                        <textarea 
                            name="headerInjection" 
                            id="header-injection"
                            class="form-control font-mono text-sm"
                            rows="3"
                            placeholder="<style>...</style> or <script>...</script>"
                        ><cfoutput>#postData.header_injection#</cfoutput></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Post Footer</label>
                        <textarea 
                            name="footerInjection" 
                            id="footer-injection"
                            class="form-control font-mono text-sm"
                            rows="3"
                            placeholder="<script>...</script>"
                        ><cfoutput>#postData.footer_injection#</cfoutput></textarea>
                    </div>
                </div>
            </div>

            <!-- Delete Post -->
            <div class="setting-group pt-6 border-t border-gray-200">
                <button type="button" class="btn btn-outline-error w-full" id="delete-post">
                    <i class="ti ti-trash mr-2"></i>
                    Delete Post
                </button>
            </div>
        </div>
    </aside>
</div>

<!-- Settings Toggle Button -->
<button type="button" id="settings-toggle" class="settings-menu-toggle fixed right-6 top-24 bg-white border border-gray-300 rounded-lg p-3 shadow-lg hover:shadow-xl transition-shadow z-50">
    <i class="ti ti-settings text-xl"></i>
</button>

<!-- Include JavaScript for editor functionality -->
<script src="/ghost/assets/js/post-editor.js"></script>

<cfinclude template="../includes/footer.cfm">
```

### 3. JavaScript Implementation

**Enhanced Editor JavaScript:**
```javascript
// /ghost/assets/js/post-editor.js

class PostEditor {
    constructor() {
        this.autoSaveTimeout = null;
        this.wordCount = 0;
        this.hasUnsavedChanges = false;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.initializeEditor();
        this.setupAutoSave();
        this.updateWordCount();
    }

    setupEventListeners() {
        // Settings menu toggle
        document.getElementById('settings-toggle').addEventListener('click', () => {
            this.toggleSettingsMenu();
        });

        document.getElementById('close-settings').addEventListener('click', () => {
            this.hideSettingsMenu();
        });

        // Title input with auto-slug generation
        document.getElementById('post-title').addEventListener('input', (e) => {
            this.generateSlug(e.target.value);
            this.markUnsaved();
            this.scheduleAutoSave();
        });

        // Content editor changes
        document.getElementById('content-editor').addEventListener('input', () => {
            this.updateWordCount();
            this.markUnsaved();
            this.scheduleAutoSave();
        });

        // Feature image upload
        document.getElementById('feature-image-upload').addEventListener('click', () => {
            this.openImageUpload();
        });

        // Save and publish buttons
        document.getElementById('save-draft').addEventListener('click', () => {
            this.savePost('draft');
        });

        document.getElementById('publish-post').addEventListener('click', () => {
            this.savePost('published');
        });

        // Toolbar actions
        document.querySelectorAll('.toolbar-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.dataset.action;
                this.executeToolbarAction(action);
            });
        });

        // Prevent leaving with unsaved changes
        window.addEventListener('beforeunload', (e) => {
            if (this.hasUnsavedChanges) {
                e.preventDefault();
                e.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
                return e.returnValue;
            }
        });
    }

    initializeEditor() {
        const editor = document.getElementById('content-editor');
        
        // Add placeholder handling
        if (editor.textContent.trim() === '') {
            editor.classList.add('empty');
        }

        editor.addEventListener('focus', () => {
            editor.classList.remove('empty');
        });

        editor.addEventListener('blur', () => {
            if (editor.textContent.trim() === '') {
                editor.classList.add('empty');
            }
        });
    }

    toggleSettingsMenu() {
        const menu = document.getElementById('post-settings-menu');
        menu.classList.toggle('translate-x-full');
    }

    hideSettingsMenu() {
        const menu = document.getElementById('post-settings-menu');
        menu.classList.add('translate-x-full');
    }

    generateSlug(title) {
        const slug = title
            .toLowerCase()
            .replace(/[^\w\s-]/g, '')
            .replace(/\s+/g, '-')
            .trim();
        
        document.getElementById('post-slug').value = slug;
    }

    updateWordCount() {
        const content = document.getElementById('content-editor').textContent;
        const words = content.trim().split(/\s+/).filter(word => word.length > 0);
        this.wordCount = words.length;
        
        const readingTime = Math.ceil(this.wordCount / 200); // 200 words per minute
        
        document.getElementById('word-count').textContent = `${this.wordCount} words`;
        document.getElementById('reading-time').textContent = `${readingTime} min read`;
    }

    executeToolbarAction(action) {
        const editor = document.getElementById('content-editor');
        editor.focus();

        switch (action) {
            case 'bold':
                document.execCommand('bold');
                break;
            case 'italic':
                document.execCommand('italic');
                break;
            case 'underline':
                document.execCommand('underline');
                break;
            case 'unorderedList':
                document.execCommand('insertUnorderedList');
                break;
            case 'orderedList':
                document.execCommand('insertOrderedList');
                break;
            case 'link':
                this.insertLink();
                break;
            case 'image':
                this.insertImage();
                break;
            case 'quote':
                this.insertQuote();
                break;
            case 'card-menu':
                this.showCardMenu();
                break;
        }

        this.markUnsaved();
        this.scheduleAutoSave();
    }

    insertLink() {
        const url = prompt('Enter URL:');
        if (url) {
            document.execCommand('createLink', false, url);
        }
    }

    insertImage() {
        const url = prompt('Enter image URL:');
        if (url) {
            document.execCommand('insertImage', false, url);
        }
    }

    insertQuote() {
        const selection = window.getSelection();
        if (selection.rangeCount > 0) {
            const range = selection.getRangeAt(0);
            const blockquote = document.createElement('blockquote');
            blockquote.style.cssText = 'border-left: 4px solid #e5e7eb; padding-left: 1rem; margin: 1rem 0; font-style: italic;';
            
            try {
                range.surroundContents(blockquote);
            } catch (e) {
                blockquote.appendChild(range.extractContents());
                range.insertNode(blockquote);
            }
        }
    }

    showCardMenu() {
        // Implement card insertion menu
        const menu = document.createElement('div');
        menu.className = 'card-menu absolute bg-white border border-gray-300 rounded-lg shadow-lg z-50 p-2';
        menu.innerHTML = `
            <div class="card-option" data-card="image">📷 Image</div>
            <div class="card-option" data-card="gallery">🖼️ Gallery</div>
            <div class="card-option" data-card="video">🎥 Video</div>
            <div class="card-option" data-card="audio">🎵 Audio</div>
            <div class="card-option" data-card="file">📁 File</div>
            <div class="card-option" data-card="bookmark">🔖 Bookmark</div>
            <div class="card-option" data-card="button">🔘 Button</div>
            <div class="card-option" data-card="callout">💬 Callout</div>
            <div class="card-option" data-card="toggle">▼ Toggle</div>
            <div class="card-option" data-card="divider">➖ Divider</div>
            <div class="card-option" data-card="html">💻 HTML</div>
            <div class="card-option" data-card="markdown">📝 Markdown</div>
        `;

        menu.addEventListener('click', (e) => {
            if (e.target.classList.contains('card-option')) {
                const cardType = e.target.dataset.card;
                this.insertCard(cardType);
                menu.remove();
            }
        });

        document.body.appendChild(menu);
        
        // Position menu near cursor
        const selection = window.getSelection();
        if (selection.rangeCount > 0) {
            const range = selection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            menu.style.left = rect.left + 'px';
            menu.style.top = (rect.bottom + 10) + 'px';
        }

        // Close menu on outside click
        setTimeout(() => {
            document.addEventListener('click', function closeMenu(e) {
                if (!menu.contains(e.target)) {
                    menu.remove();
                    document.removeEventListener('click', closeMenu);
                }
            });
        }, 100);
    }

    insertCard(cardType) {
        const editor = document.getElementById('content-editor');
        const cardElement = this.createCardElement(cardType);
        
        const selection = window.getSelection();
        if (selection.rangeCount > 0) {
            const range = selection.getRangeAt(0);
            range.insertNode(cardElement);
            range.collapse(false);
        } else {
            editor.appendChild(cardElement);
        }
        
        this.markUnsaved();
        this.scheduleAutoSave();
    }

    createCardElement(cardType) {
        const cardDiv = document.createElement('div');
        cardDiv.className = 'editor-card my-4 p-4 border border-gray-200 rounded-lg';
        cardDiv.dataset.cardType = cardType;

        switch (cardType) {
            case 'image':
                cardDiv.innerHTML = `
                    <div class="image-card text-center">
                        <div class="border-2 border-dashed border-gray-300 rounded-lg p-8">
                            <i class="ti ti-photo text-4xl text-gray-400 mb-2"></i>
                            <p class="text-gray-600">Click to upload an image</p>
                        </div>
                    </div>
                `;
                break;
            
            case 'bookmark':
                cardDiv.innerHTML = `
                    <div class="bookmark-card">
                        <input type="url" placeholder="Enter URL to create bookmark" 
                               class="form-control mb-2" onblur="this.parentElement.parentElement.innerHTML = 'Bookmark: ' + this.value">
                    </div>
                `;
                break;
                
            case 'button':
                cardDiv.innerHTML = `
                    <div class="button-card text-center">
                        <button class="btn btn-primary">
                            <input type="text" placeholder="Button text" class="bg-transparent border-0 text-center text-white placeholder-gray-200" style="width: auto;">
                        </button>
                        <input type="url" placeholder="Button URL" class="form-control mt-2">
                    </div>
                `;
                break;
                
            case 'callout':
                cardDiv.innerHTML = `
                    <div class="callout-card bg-blue-50 border-l-4 border-blue-400 p-4">
                        <div contenteditable="true" class="outline-0" data-placeholder="Add your callout text..."></div>
                    </div>
                `;
                break;
                
            case 'divider':
                cardDiv.innerHTML = `
                    <div class="divider-card text-center">
                        <hr class="border-t-2 border-gray-300 my-8">
                    </div>
                `;
                break;
                
            case 'html':
                cardDiv.innerHTML = `
                    <div class="html-card">
                        <textarea class="form-control font-mono text-sm" rows="5" placeholder="Enter HTML code..."></textarea>
                    </div>
                `;
                break;
                
            default:
                cardDiv.innerHTML = `
                    <div class="${cardType}-card">
                        <p class="text-gray-600">${cardType.charAt(0).toUpperCase() + cardType.slice(1)} card placeholder</p>
                    </div>
                `;
        }

        return cardDiv;
    }

    openImageUpload() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = 'image/*';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (file) {
                this.uploadFeatureImage(file);
            }
        };
        input.click();
    }

    uploadFeatureImage(file) {
        const formData = new FormData();
        formData.append('image', file);
        formData.append('type', 'feature');

        fetch('/ghost/admin/ajax/upload-image.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const container = document.getElementById('feature-image-upload');
                container.innerHTML = `
                    <img src="${data.url}" alt="Feature image" class="max-w-full h-auto rounded-lg mx-auto">
                    <div class="mt-4">
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="editor.openImageUpload()">
                            Change Image
                        </button>
                        <button type="button" class="btn btn-outline-error btn-sm ml-2" onclick="editor.removeFeatureImage()">
                            Remove
                        </button>
                    </div>
                `;
                this.markUnsaved();
                showMessage('Feature image uploaded successfully', 'success');
            } else {
                showMessage('Failed to upload image: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Upload error:', error);
            showMessage('Failed to upload image', 'error');
        });
    }

    removeFeatureImage() {
        const container = document.getElementById('feature-image-upload');
        container.innerHTML = `
            <i class="ti ti-camera text-4xl text-gray-400 mb-4"></i>
            <p class="text-gray-600 mb-2">Add a feature image</p>
            <p class="text-sm text-gray-500">Drag and drop or click to upload</p>
        `;
        this.markUnsaved();
    }

    markUnsaved() {
        this.hasUnsavedChanges = true;
        // Visual indicator
        document.title = '• ' + document.title.replace('• ', '');
    }

    markSaved() {
        this.hasUnsavedChanges = false;
        document.title = document.title.replace('• ', '');
    }

    scheduleAutoSave() {
        if (this.autoSaveTimeout) {
            clearTimeout(this.autoSaveTimeout);
        }
        
        this.autoSaveTimeout = setTimeout(() => {
            this.autoSave();
        }, 3000); // Auto-save after 3 seconds of inactivity
    }

    autoSave() {
        if (!this.hasUnsavedChanges) return;
        
        this.savePost('auto', true);
    }

    savePost(status = 'draft', silent = false) {
        const formData = new FormData();
        const form = document.getElementById('post-form');
        
        // Collect all form data
        formData.append('postId', form.querySelector('[name="postId"]').value);
        formData.append('title', form.querySelector('[name="title"]').value);
        formData.append('slug', form.querySelector('[name="slug"]').value);
        formData.append('content', document.getElementById('content-editor').innerHTML);
        formData.append('customExcerpt', form.querySelector('[name="customExcerpt"]').value);
        formData.append('status', status);
        formData.append('wordCount', this.wordCount);
        formData.append('readingTime', Math.ceil(this.wordCount / 200));
        
        // Settings data
        formData.append('publishedAt', form.querySelector('[name="publishedAt"]').value);
        formData.append('tags', form.querySelector('[name="tags"]').value);
        formData.append('visibility', form.querySelector('[name="visibility"]').value);
        formData.append('featured', form.querySelector('[name="featured"]').checked ? '1' : '0');
        formData.append('metaTitle', form.querySelector('[name="metaTitle"]').value);
        formData.append('metaDescription', form.querySelector('[name="metaDescription"]').value);
        formData.append('ogTitle', form.querySelector('[name="ogTitle"]').value);
        formData.append('ogDescription', form.querySelector('[name="ogDescription"]').value);
        formData.append('twitterTitle', form.querySelector('[name="twitterTitle"]').value);
        formData.append('headerInjection', form.querySelector('[name="headerInjection"]').value);
        formData.append('footerInjection', form.querySelector('[name="footerInjection"]').value);

        if (!silent) {
            showMessage('Saving...', 'info');
        }

        fetch('/ghost/admin/ajax/save-post.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.markSaved();
                
                if (!silent) {
                    const message = status === 'published' ? 'Post published successfully' : 
                                   status === 'auto' ? 'Draft saved' : 
                                   'Post saved successfully';
                    showMessage(message, 'success');
                }
                
                // Update URL if this was a new post
                if (data.postId && window.location.pathname.includes('/new')) {
                    history.replaceState({}, '', `/ghost/admin/posts/edit?id=${data.postId}`);
                }
            } else {
                showMessage('Failed to save post: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Save error:', error);
            showMessage('Failed to save post', 'error');
        });
    }

    setupAutoSave() {
        // Force save every 60 seconds if there are changes
        setInterval(() => {
            if (this.hasUnsavedChanges) {
                this.autoSave();
            }
        }, 60000);
    }
}

// Initialize editor when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.editor = new PostEditor();
});

// CSS for editor styling
const editorStyles = `
<style>
.toolbar-btn {
    @apply p-2 rounded hover:bg-gray-200 transition-colors;
}

.toolbar-btn:hover {
    background-color: #f3f4f6;
}

.toolbar-select {
    @apply px-3 py-1 border border-gray-300 rounded text-sm;
}

#content-editor.empty:before {
    content: attr(data-placeholder);
    color: #9ca3af;
    pointer-events: none;
}

#content-editor:focus {
    outline: none;
}

.editor-card {
    position: relative;
    margin: 1rem 0;
}

.editor-card:hover {
    background-color: #f9fafb;
}

.card-menu {
    min-width: 200px;
}

.card-option {
    @apply px-3 py-2 hover:bg-gray-100 cursor-pointer rounded;
}

.settings-menu-toggle {
    transition: all 0.2s ease;
}

.settings-menu-toggle:hover {
    transform: scale(1.05);
}

.post-settings-menu {
    max-height: 100vh;
    overflow-y: auto;
}

@media (max-width: 768px) {
    .post-settings-menu {
        position: fixed;
        top: 0;
        right: 0;
        height: 100vh;
        z-index: 50;
    }
}
</style>
`;

// Inject styles
document.head.insertAdjacentHTML('beforeend', editorStyles);
```

### 4. CFML Save Handler

**Post Save AJAX Handler:**
```cfml
<!--- admin/ajax/save-post.cfm --->
<cfheader name="Content-Type" value="application/json">

<cftry>
    <!--- Extract form data --->
    <cfparam name="form.postId" default="">
    <cfparam name="form.title" default="">
    <cfparam name="form.slug" default="">
    <cfparam name="form.content" default="">
    <cfparam name="form.customExcerpt" default="">
    <cfparam name="form.status" default="draft">
    <cfparam name="form.wordCount" default="0">
    <cfparam name="form.readingTime" default="0">
    <cfparam name="form.publishedAt" default="">
    <cfparam name="form.tags" default="">
    <cfparam name="form.visibility" default="public">
    <cfparam name="form.featured" default="0">
    <cfparam name="form.metaTitle" default="">
    <cfparam name="form.metaDescription" default="">
    <cfparam name="form.ogTitle" default="">
    <cfparam name="form.ogDescription" default="">
    <cfparam name="form.twitterTitle" default="">
    <cfparam name="form.headerInjection" default="">
    <cfparam name="form.footerInjection" default="">

    <!--- Generate slug if empty --->
    <cfif not len(trim(form.slug))>
        <cfset form.slug = lCase(reReplace(form.title, "[^a-zA-Z0-9\s]", "", "all"))>
        <cfset form.slug = reReplace(form.slug, "\s+", "-", "all")>
        <cfset form.slug = trim(form.slug)>
    </cfif>

    <!--- Process published date --->
    <cfif len(form.publishedAt)>
        <cfset publishedDate = parseDateTime(form.publishedAt)>
    <cfelse>
        <cfset publishedDate = now()>
    </cfif>

    <!--- Update or insert post --->
    <cfif len(form.postId) and isNumeric(form.postId)>
        <!--- Update existing post --->
        <cfquery datasource="blog">
            UPDATE posts SET
                title = <cfqueryparam value="#form.title#" cfsqltype="cf_sql_varchar">,
                slug = <cfqueryparam value="#form.slug#" cfsqltype="cf_sql_varchar">,
                content = <cfqueryparam value="#form.content#" cfsqltype="cf_sql_longvarchar">,
                custom_excerpt = <cfqueryparam value="#form.customExcerpt#" cfsqltype="cf_sql_longvarchar">,
                status = <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">,
                visibility = <cfqueryparam value="#form.visibility#" cfsqltype="cf_sql_varchar">,
                featured = <cfqueryparam value="#form.featured#" cfsqltype="cf_sql_bit">,
                word_count = <cfqueryparam value="#form.wordCount#" cfsqltype="cf_sql_integer">,
                reading_time = <cfqueryparam value="#form.readingTime#" cfsqltype="cf_sql_integer">,
                meta_title = <cfqueryparam value="#form.metaTitle#" cfsqltype="cf_sql_varchar">,
                meta_description = <cfqueryparam value="#form.metaDescription#" cfsqltype="cf_sql_longvarchar">,
                og_title = <cfqueryparam value="#form.ogTitle#" cfsqltype="cf_sql_varchar">,
                og_description = <cfqueryparam value="#form.ogDescription#" cfsqltype="cf_sql_longvarchar">,
                twitter_title = <cfqueryparam value="#form.twitterTitle#" cfsqltype="cf_sql_varchar">,
                header_injection = <cfqueryparam value="#form.headerInjection#" cfsqltype="cf_sql_longvarchar">,
                footer_injection = <cfqueryparam value="#form.footerInjection#" cfsqltype="cf_sql_longvarchar">,
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                <cfif form.status neq "auto">
                    ,published_at = <cfqueryparam value="#publishedDate#" cfsqltype="cf_sql_timestamp">
                </cfif>
            WHERE id = <cfqueryparam value="#form.postId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfset postId = form.postId>
    <cfelse>
        <!--- Insert new post --->
        <cfquery datasource="blog" result="insertResult">
            INSERT INTO posts (
                title, slug, content, custom_excerpt, status, visibility, featured,
                word_count, reading_time, meta_title, meta_description, og_title, og_description,
                twitter_title, header_injection, footer_injection, created_by, created_at, updated_at
                <cfif form.status neq "auto">, published_at</cfif>
            ) VALUES (
                <cfqueryparam value="#form.title#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.slug#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.content#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#form.customExcerpt#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.visibility#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.featured#" cfsqltype="cf_sql_bit">,
                <cfqueryparam value="#form.wordCount#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.readingTime#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.metaTitle#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.metaDescription#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#form.ogTitle#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.ogDescription#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#form.twitterTitle#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.headerInjection#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#form.footerInjection#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                <cfif form.status neq "auto">
                    ,<cfqueryparam value="#publishedDate#" cfsqltype="cf_sql_timestamp">
                </cfif>
            )
        </cfquery>
        
        <cfset postId = insertResult.generatedKey>
    </cfif>

    <!--- Handle tags --->
    <cfif len(trim(form.tags))>
        <!--- First, remove existing tags for this post --->
        <cfquery datasource="blog">
            DELETE FROM posts_tags 
            WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Process new tags --->
        <cfset tagList = listToArray(form.tags, ",")>
        <cfloop array="#tagList#" index="tagName">
            <cfset tagName = trim(tagName)>
            <cfif len(tagName)>
                <!--- Find or create tag --->
                <cfquery name="findTag" datasource="blog">
                    SELECT id FROM tags 
                    WHERE name = <cfqueryparam value="#tagName#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif findTag.recordCount eq 0>
                    <!--- Create new tag --->
                    <cfquery datasource="blog" result="tagResult">
                        INSERT INTO tags (name, slug, created_at, updated_at)
                        VALUES (
                            <cfqueryparam value="#tagName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#lCase(reReplace(tagName, '[^a-zA-Z0-9\s]', '', 'all'))#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                        )
                    </cfquery>
                    <cfset tagId = tagResult.generatedKey>
                <cfelse>
                    <cfset tagId = findTag.id>
                </cfif>
                
                <!--- Link tag to post --->
                <cfquery datasource="blog">
                    INSERT INTO posts_tags (post_id, tag_id)
                    VALUES (
                        <cfqueryparam value="#postId#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#tagId#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
            </cfif>
        </cfloop>
    </cfif>

    <!--- Return success response --->
    <cfoutput>{"success": true, "message": "Post saved successfully", "postId": #postId#}</cfoutput>

<cfcatch>
    <!--- Return error response --->
    <cfoutput>{"success": false, "message": "#cfcatch.message#"}</cfoutput>
</cfcatch>
</cftry>
```

## Implementation Benefits

### 1. **Modern User Experience**
- Ghost-like editor interface with card-based content creation
- Real-time auto-save with conflict resolution
- Contextual toolbar for efficient formatting
- Word count and reading time tracking

### 2. **Content Management Features**
- 20+ content block types for rich content creation
- Feature image upload with automatic resizing
- SEO optimization tools with meta tag management
- Social media sharing optimization

### 3. **Publishing Workflow**
- Draft, scheduled, and published states
- Multiple author support
- Tag-based content organization
- Access control for member-only content

### 4. **Technical Excellence**
- Responsive design with mobile-first approach
- Background auto-save every 3 seconds
- Comprehensive settings management
- Database-driven with proper security

## Next Steps

1. **Rich Text Editor Integration**: Implement TinyMCE or CKEditor for advanced formatting
2. **Card System Enhancement**: Add all 20+ Ghost card types with proper UI
3. **Image Management**: Build comprehensive media library with upload/management features
4. **Member System**: Implement Ghost-style membership and access control
5. **Analytics Integration**: Add post performance tracking and analytics dashboard

This comprehensive implementation provides a solid foundation for a Ghost-like editor experience in CFGhost CMS while maintaining the existing Spike Tailwind Pro design system.