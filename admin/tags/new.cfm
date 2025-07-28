<!--- New Tag Page --->
<cfparam name="request.dsn" default="blog">

<cfset pageTitle = "New tag">
<cfinclude template="../includes/header.cfm">

<!--- Initialize new tag data --->
<cfscript>
    tagData = {
        id: "",
        name: "",
        slug: "",
        description: "",
        feature_image: "",
        visibility: "public",
        meta_title: "",
        meta_description: "",
        canonical_url: "",
        accent_color: "",
        og_title: "",
        og_description: "",
        og_image: "",
        twitter_title: "",
        twitter_description: "",
        twitter_image: "",
        codeinjection_head: "",
        codeinjection_foot: "",
        created_at: now(),
        updated_at: now(),
        created_by: session.USERID ?: "1",
        updated_by: session.USERID ?: "1"
    };
    
    isNew = true;
</cfscript>

<!-- Modern Tag Editor -->
<div class="body-wrapper">
    <div class="container-fluid">
        <form id="tagForm">
            
            <!-- Modern Breadcrumb Card -->
            <div class="card mb-6 shadow-none">
                <div class="card-body p-6">
                    <div class="sm:flex items-center justify-between">
                        <div>
                            <h4 class="font-semibold text-xl text-dark dark:text-white">New Tag</h4>
                            <p class="text-sm text-gray-600 mt-1">Create a new tag to organize your content</p>
                        </div>
                        <ol class="flex items-center" aria-label="Breadcrumb">
                            <li class="flex items-center">
                                <a class="text-sm font-medium" href="/ghost/admin">Home</a>
                            </li>
                            <li>
                                <div class="h-1 w-1 rounded-full bg-bodytext mx-2.5 flex items-center mt-1"></div>
                            </li>
                            <li class="flex items-center">
                                <a class="text-sm font-medium" href="/ghost/admin/tags">Tags</a>
                            </li>
                            <li>
                                <div class="h-1 w-1 rounded-full bg-bodytext mx-2.5 flex items-center mt-1"></div>
                            </li>
                            <li class="flex items-center text-sm font-medium" aria-current="page">New</li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Main Content Card -->
            <div class="card">
                <div class="card-body">
                    <!-- Header with Actions -->
                    <div class="flex items-center justify-between mb-6">
                        <h5 class="text-lg font-semibold">Tag Details</h5>
                        <div class="flex gap-2">
                            <button type="button" class="btn btn-outline-primary" onclick="window.location.href='/ghost/admin/tags'">
                                <i class="ti ti-arrow-left me-2"></i>Cancel
                            </button>
                            <button type="button" class="btn btn-primary" onclick="saveTag()">
                                <i class="ti ti-device-floppy me-2"></i>Create Tag
                            </button>
                        </div>
                    </div>
                    
                    <!-- Two Column Layout -->
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <div>
                            <!-- Name and Color -->
                            <div class="flex gap-4 mb-6">
                                <div class="flex-1">
                                    <label for="tag-name" class="form-label">Name</label>
                                    <input type="text" 
                                           class="form-control" 
                                           id="tag-name" 
                                           name="name" 
                                           value="<cfoutput>#tagData.name#</cfoutput>"
                                           placeholder="Enter tag name"
                                           oninput="updateSlug()">
                                    <p class="text-xs text-gray-500 mt-1">
                                        Start with # to create internal tags.
                                        <a href="https://ghost.org/help/organising-content/#private-tags" target="_blank" rel="noopener noreferrer" class="text-primary hover:underline">Learn more</a>
                                    </p>
                                </div>

                                <div class="w-36">
                                    <label for="accent-color" class="form-label">Color</label>
                                    <div class="relative">
                                        <input type="text" 
                                               placeholder="15171A" 
                                               id="accent-color"
                                               name="accent_color" 
                                               maxlength="6" 
                                               value="<cfoutput>#tagData.accent_color#</cfoutput>"
                                               class="form-control"
                                               style="padding-right: 3.5rem;"
                                               oninput="updateAccentColor()">
                                        <div class="absolute inset-y-0 right-0 flex items-center pr-3">
                                            <div class="w-7 h-7 rounded border border-gray-300 cursor-pointer overflow-hidden" id="colorPreview" style="background: #15171A;">
                                                <input type="color" 
                                                       id="colorPicker"
                                                       class="opacity-0 w-full h-full cursor-pointer" 
                                                       value="#15171A"
                                                       onchange="updateColorFromPicker()">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Slug -->
                            <div class="mb-6">
                                <label for="tag-slug" class="form-label">Slug</label>
                                <input type="text" 
                                       value="<cfoutput>#tagData.slug#</cfoutput>"
                                       id="tag-slug" 
                                       name="slug" 
                                       class="form-control"
                                       placeholder="tag-slug"
                                       oninput="updateSlugPreview()">
                                <p class="text-xs text-gray-500 mt-1">
                                    <cfoutput>https://example.com/tag/</cfoutput><span id="slugPreview" class="font-medium"></span>
                                </p>
                            </div>

                            <!-- Description -->
                            <div class="mb-6">
                                <label for="tag-description" class="form-label">Description</label>
                                <textarea id="tag-description" 
                                          name="description" 
                                          class="form-control"
                                          rows="4"
                                          maxlength="500"
                                          placeholder="Enter a brief description of the tag"
                                          oninput="updateCharCount('tag-description', 500)"><cfoutput>#tagData.description#</cfoutput></textarea>
                                <div class="flex justify-between mt-1">
                                    <p class="text-xs text-gray-500">Describe what this tag is about</p>
                                    <p class="text-xs text-gray-500"><span id="tag-description-count">0</span>/500</p>
                                </div>
                            </div>
                        </div>

                        <!-- Tag Image -->
                        <div>
                            <label class="form-label">Tag Image</label>
                            <div class="tag-image-uploader">
                                <div id="imagePreview" class="relative group" style="display: none;">
                                    <img id="previewImg" src="" alt="Tag image" class="w-full h-64 object-cover rounded-lg">
                                    <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center">
                                        <button type="button" class="btn btn-sm btn-light" onclick="removeImage()">
                                            <i class="ti ti-trash me-1"></i>Remove
                                        </button>
                                    </div>
                                </div>
                                <div id="imageUploader" class="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center hover:border-gray-400 transition-colors">
                                    <input type="file" 
                                           id="featureImage" 
                                           accept="image/*" 
                                           style="display: none;"
                                           onchange="handleImageUpload(this)">
                                    <i class="ti ti-photo text-4xl text-gray-400 mb-3"></i>
                                    <p class="text-gray-600 mb-3">Click to upload or drag and drop</p>
                                    <button type="button" 
                                            class="btn btn-outline-primary btn-sm"
                                            onclick="document.getElementById('featureImage').click()">
                                        <i class="ti ti-upload me-2"></i>Choose Image
                                    </button>
                                    <p class="text-xs text-gray-500 mt-2">PNG, JPG up to 10MB</p>
                                </div>
                                <input type="hidden" id="feature_image" name="feature_image" value="">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Expandable Sections -->
                <section class="gh-expandable">
                    <!-- Meta Data -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header">
                            <div>
                                <h4 class="gh-expandable-title">Meta data</h4>
                                <p class="gh-expandable-description">Extra content for search engines.</p>
                            </div>
                            <button type="button" class="gh-btn gh-btn-expand" onclick="toggleSection('metadata')">
                                <span id="metadata-toggle">Expand</span>
                            </button>
                        </div>

                        <div class="gh-expandable-content" id="metadata-content" style="display: none;">
                            <div class="gh-setting-content-extended">
                                <div class="gh-seo-settings">
                                    <div class="gh-seo-settings-left flex-basis-1-2-m flex-basis-2-3-l">
                                        <div class="form-group">
                                            <label for="meta-title">Meta title</label>
                                            <input type="text" 
                                                   id="meta-title" 
                                                   name="meta_title" 
                                                   class="gh-input-x form-control"
                                                   placeholder="Meta title"
                                                   value="<cfoutput>#tagData.meta_title#</cfoutput>"
                                                   maxlength="70"
                                                   oninput="updateCharCount('meta-title', 70)">
                                            <p>Recommended: <b>70</b> characters. You've used <span id="meta-title-count">0</span></p>
                                        </div>

                                        <div class="form-group">
                                            <label for="meta-description">Meta description</label>
                                            <textarea id="meta-description" 
                                                      name="meta_description" 
                                                      class="gh-input-x gh-tag-details-textarea form-control"
                                                      rows="3"
                                                      placeholder="Meta description"
                                                      maxlength="156"
                                                      oninput="updateCharCount('meta-description', 156)"><cfoutput>#tagData.meta_description#</cfoutput></textarea>
                                            <p>Recommended: <b>156</b> characters. You've used <span id="meta-description-count">0</span></p>
                                        </div>

                                        <div class="form-group">
                                            <label for="canonical-url">Canonical URL</label>
                                            <input type="text" 
                                                   id="canonical-url" 
                                                   name="canonical_url" 
                                                   class="gh-input-x form-control"
                                                   placeholder="https://example.com/tag/slug"
                                                   value="<cfoutput>#tagData.canonical_url#</cfoutput>">
                                        </div>
                                    </div>

                                    <div class="flex-basis-1-2-m flex-basis-1-3-l">
                                        <label>Search Engine Result Preview</label>
                                        <div class="gh-seo-container">
                                            <div class="gh-seo-preview">
                                                <div class="gh-seo-preview-link">example.com › tag › <span id="seo-slug">tag-slug</span></div>
                                                <div class="gh-seo-preview-title" id="seo-title">Tag Name</div>
                                                <div class="gh-seo-preview-desc" id="seo-description">Tag description will appear here</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- X Card -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header">
                            <div>
                                <h4 class="gh-expandable-title">X card</h4>
                                <p class="gh-expandable-description">Customized structured data for X.</p>
                            </div>
                            <button type="button" class="gh-btn gh-btn-expand" onclick="toggleSection('twitter')">
                                <span id="twitter-toggle">Expand</span>
                            </button>
                        </div>

                        <div class="gh-expandable-content" id="twitter-content" style="display: none;">
                            <div class="gh-setting-content-extended">
                                <!-- Twitter/X fields would go here -->
                            </div>
                        </div>
                    </div>

                    <!-- Facebook Card -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header">
                            <div>
                                <h4 class="gh-expandable-title">Facebook card</h4>
                                <p class="gh-expandable-description">Customize Open Graph data.</p>
                            </div>
                            <button type="button" class="gh-btn gh-btn-expand" onclick="toggleSection('facebook')">
                                <span id="facebook-toggle">Expand</span>
                            </button>
                        </div>

                        <div class="gh-expandable-content" id="facebook-content" style="display: none;">
                            <div class="gh-setting-content-extended">
                                <!-- Facebook/OG fields would go here -->
                            </div>
                        </div>
                    </div>

                    <!-- Code Injection -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header">
                            <div>
                                <h4 class="gh-expandable-title">Code injection</h4>
                                <p class="gh-expandable-description">Add styles/scripts to the header and footer.</p>
                            </div>
                            <button type="button" class="gh-btn gh-btn-expand" onclick="toggleSection('codeinjection')">
                                <span id="codeinjection-toggle">Expand</span>
                            </button>
                        </div>

                        <div class="gh-expandable-content" id="codeinjection-content" style="display: none;">
                            <div class="gh-main-section">
                                <div class="form-group gh-main-section-block settings-code">
                                    <label for="codeinjection-head">Tag header <code class="fw4 ml1">{{ghost_head}}</code></label>
                                    <textarea id="codeinjection-head" 
                                              name="codeinjection_head" 
                                              class="form-control code-editor"
                                              rows="5"
                                              placeholder="<!-- Enter code to inject into tag header -->"><cfoutput>#tagData.codeinjection_head#</cfoutput></textarea>
                                </div>

                                <div class="form-group gh-main-section-block settings-code">
                                    <label for="codeinjection-foot">Tag footer <code class="fw4 ml1">{{ghost_foot}}</code></label>
                                    <textarea id="codeinjection-foot" 
                                              name="codeinjection_foot" 
                                              class="form-control code-editor"
                                              rows="5"
                                              placeholder="<!-- Enter code to inject into tag footer -->"><cfoutput>#tagData.codeinjection_foot#</cfoutput></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </form>
        </div>
    </div>
</div>

<style>
/* Modern Tag Editor Styles */
.tag-image-uploader {
    min-height: 200px;
}

/* Grid Utilities */
.grid {
    display: grid;
}

.grid-cols-1 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
}

@media (min-width: 1024px) {
    .lg\\:grid-cols-2 {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

.gap-6 {
    gap: 1.5rem;
}

.gap-4 {
    gap: 1rem;
}

.gap-2 {
    gap: 0.5rem;
}

/* Flexbox Utilities */
.flex {
    display: flex;
}

.items-center {
    align-items: center;
}

.justify-between {
    justify-content: space-between;
}

.flex-1 {
    flex: 1 1 0%;
}

/* Spacing Utilities */
.mb-6 {
    margin-bottom: 1.5rem;
}

.mt-1 {
    margin-top: 0.25rem;
}

.mt-2 {
    margin-top: 0.5rem;
}

.mt-3 {
    margin-top: 0.75rem;
}

.mt-6 {
    margin-top: 1.5rem;
}

.space-y-4 > * + * {
    margin-top: 1rem;
}

.me-1 {
    margin-right: 0.25rem;
}

.me-2 {
    margin-right: 0.5rem;
}

.ms-1 {
    margin-left: 0.25rem;
}

.p-6 {
    padding: 1.5rem;
}

.p-12 {
    padding: 3rem;
}

.pr-3 {
    padding-right: 0.75rem;
}

/* Width/Height Utilities */
.w-36 {
    width: 9rem;
}

.w-7 {
    width: 1.75rem;
}

.h-7 {
    height: 1.75rem;
}

.w-full {
    width: 100%;
}

.h-64 {
    height: 16rem;
}

/* Text Utilities */
.text-xs {
    font-size: 0.75rem;
    line-height: 1rem;
}

.text-sm {
    font-size: 0.875rem;
    line-height: 1.25rem;
}

.text-lg {
    font-size: 1.125rem;
    line-height: 1.75rem;
}

.text-xl {
    font-size: 1.25rem;
    line-height: 1.75rem;
}

.text-4xl {
    font-size: 2.25rem;
    line-height: 2.5rem;
}

.font-medium {
    font-weight: 500;
}

.font-semibold {
    font-weight: 600;
}

/* Color Utilities */
.text-primary {
    color: #6366f1;
}

.text-gray-400 {
    color: #9ca3af;
}

.text-gray-500 {
    color: #6b7280;
}

.text-gray-600 {
    color: #4b5563;
}

.text-gray-700 {
    color: #374151;
}

.bg-black {
    background-color: #000000;
}

.bg-opacity-50 {
    --tw-bg-opacity: 0.5;
}

.border-gray-300 {
    border-color: #d1d5db;
}

.border-gray-400 {
    border-color: #9ca3af;
}

/* Border Utilities */
.border {
    border-width: 1px;
}

.border-2 {
    border-width: 2px;
}

.border-dashed {
    border-style: dashed;
}

.rounded {
    border-radius: 0.25rem;
}

.rounded-lg {
    border-radius: 0.5rem;
}

.rounded-full {
    border-radius: 9999px;
}

/* Position Utilities */
.relative {
    position: relative;
}

.absolute {
    position: absolute;
}

.inset-0 {
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
}

.inset-y-0 {
    top: 0;
    bottom: 0;
}

.right-0 {
    right: 0;
}

/* Display Utilities */
.block {
    display: block;
}

.group:hover .group-hover\\:opacity-100 {
    opacity: 1;
}

/* Other Utilities */
.overflow-hidden {
    overflow: hidden;
}

.object-cover {
    object-fit: cover;
}

.opacity-0 {
    opacity: 0;
}

.opacity-100 {
    opacity: 1;
}

.cursor-pointer {
    cursor: pointer;
}

.transition-colors {
    transition-property: background-color, border-color, color, fill, stroke;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
}

.transition-opacity {
    transition-property: opacity;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
}

/* Hover States */
.hover\\:underline:hover {
    text-decoration-line: underline;
}

.hover\\:border-gray-400:hover {
    border-color: #9ca3af;
}

/* Form Elements */
.form-label {
    display: block;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
}

/* Custom Styles */
.shadow-none {
    box-shadow: none;
}

.h-1 {
    height: 0.25rem;
}

.w-1 {
    width: 0.25rem;
}

.bg-bodytext {
    background-color: #9ca3af;
}

.mx-2\\.5 {
    margin-left: 0.625rem;
    margin-right: 0.625rem;
}

/* Expandable Sections */
.gh-expandable {
    padding: 0 2.4rem 2.4rem;
    margin-top: 2rem;
    min-height: 400px;
}

.gh-expandable-block {
    margin-bottom: 0;
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    margin-bottom: 1.6rem;
}

.gh-expandable-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 2.4rem;
    cursor: pointer;
}

.gh-expandable-title {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 0.4rem;
}

.gh-expandable-description {
    font-size: 1.3rem;
    color: #626d79;
    margin: 0;
}

.gh-expandable-content {
    padding: 0 2.4rem 2.4rem;
}

.gh-btn-expand {
    background: transparent;
    border: 1px solid #dde1e5;
    color: #30373d;
}

.gh-btn-expand:hover {
    border-color: #c5c9cd;
}

/* SEO Preview */
.gh-seo-container {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 3px;
    padding: 2rem;
}

.gh-seo-preview {
    font-family: Arial, sans-serif;
}

.gh-seo-preview-link {
    font-size: 1.4rem;
    color: #006621;
    margin-bottom: 0.4rem;
}

.gh-seo-preview-title {
    font-size: 1.8rem;
    color: #1a0dab;
    margin-bottom: 0.4rem;
}

.gh-seo-preview-desc {
    font-size: 1.3rem;
    color: #545454;
    line-height: 1.4;
}

/* Ghost Styles */
.gh-input-x {
    width: 100%;
    padding: 0.8rem 1.2rem;
    font-size: 1.4rem;
    line-height: 1.5;
    color: #15171a;
    background: #fff;
    border: 1px solid #dde1e5;
    border-radius: 3px;
    transition: border-color 0.15s;
}

.gh-input-x:focus {
    outline: none;
    border-color: #14b8ff;
}

.gh-tag-details-textarea {
    min-height: 80px;
    resize: vertical;
}

.gh-main-section-block {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 3.2rem;
    margin-bottom: 2.4rem;
}

/* Utilities from Ghost */
.flex-basis-1-2-m { flex-basis: 50%; }
.flex-basis-2-3-l { flex-basis: 66.66667%; }
.flex-basis-1-3-l { flex-basis: 33.33333%; }
.fw4 { font-weight: 400; }
.ml1 { margin-left: 0.4rem; }
.code-editor {
    font-family: monospace;
    font-size: 1.3rem;
}
</style>

<script>
// Generate slug from name
function updateSlug() {
    const nameInput = document.getElementById('tag-name');
    const slugInput = document.getElementById('tag-slug');
    const slugPreview = document.getElementById('slugPreview');
    const seoSlug = document.getElementById('seo-slug');
    const seoTitle = document.getElementById('seo-title');
    
    if (!slugInput.value || slugInput.value === generateSlug(nameInput.dataset.previousValue || '')) {
        const newSlug = generateSlug(nameInput.value);
        slugInput.value = newSlug;
        slugPreview.textContent = newSlug;
        seoSlug.textContent = newSlug;
    }
    
    seoTitle.textContent = nameInput.value || 'Tag Name';
    nameInput.dataset.previousValue = nameInput.value;
}

// Update slug preview when manually editing slug
function updateSlugPreview() {
    const slugInput = document.getElementById('tag-slug');
    const slugPreview = document.getElementById('slugPreview');
    const seoSlug = document.getElementById('seo-slug');
    
    slugPreview.textContent = slugInput.value;
    seoSlug.textContent = slugInput.value;
}

function generateSlug(text) {
    return text.toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
}

// Update accent color
function updateAccentColor() {
    const input = document.getElementById('accent-color');
    const preview = document.getElementById('colorPreview');
    const picker = document.getElementById('colorPicker');
    
    let color = input.value.replace('#', '');
    if (color.length === 6 && /^[0-9A-F]{6}$/i.test(color)) {
        preview.style.background = '#' + color;
        picker.value = '#' + color;
    }
}

function updateColorFromPicker() {
    const picker = document.getElementById('colorPicker');
    const input = document.getElementById('accent-color');
    const preview = document.getElementById('colorPreview');
    
    const color = picker.value.substring(1);
    input.value = color;
    preview.style.background = picker.value;
}

// Character count
function updateCharCount(fieldId, maxLength) {
    const field = document.getElementById(fieldId);
    const count = document.getElementById(fieldId + '-count');
    
    // Check if field exists before accessing its value
    if (field && count) {
        count.textContent = field.value.length;
    }
    
    // Update SEO preview
    if (fieldId === 'tag-description' && field) {
        const seoDesc = document.getElementById('seo-description');
        if (seoDesc) {
            seoDesc.textContent = field.value || 'Tag description will appear here';
        }
    }
}

// Toggle expandable sections
function toggleSection(section) {
    const content = document.getElementById(section + '-content');
    const toggle = document.getElementById(section + '-toggle');
    
    if (content.style.display === 'none') {
        content.style.display = 'block';
        toggle.textContent = 'Close';
    } else {
        content.style.display = 'none';
        toggle.textContent = 'Expand';
    }
}

// Image upload
function handleImageUpload(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        
        // Show loading
        showMessage('Uploading image...', 'info');
        
        // Create form data
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', 'tag');
        
        // Upload image
        fetch('/ghost/admin/ajax/upload-image.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success || data.SUCCESS) {
                const imageUrl = data.url || data.URL;
                
                // Show preview
                document.getElementById('previewImg').src = imageUrl;
                document.getElementById('imagePreview').style.display = 'block';
                document.getElementById('imageUploader').style.display = 'none';
                document.getElementById('feature_image').value = imageUrl;
                
                showMessage('Image uploaded successfully', 'success');
            } else {
                showMessage('Failed to upload image', 'error');
            }
        })
        .catch(error => {
            console.error('Upload error:', error);
            showMessage('Failed to upload image', 'error');
        });
    }
}

function removeImage() {
    document.getElementById('imagePreview').style.display = 'none';
    document.getElementById('imageUploader').style.display = 'block';
    document.getElementById('feature_image').value = '';
}

// Save tag
function saveTag() {
    const form = document.getElementById('tagForm');
    const formData = new FormData(form);
    
    // Show loading
    showMessage('Saving tag...', 'info');
    
    // Prepare data
    const tagData = {
        name: formData.get('name'),
        slug: formData.get('slug') || generateSlug(formData.get('name')),
        description: formData.get('description'),
        feature_image: formData.get('feature_image'),
        accent_color: formData.get('accent_color'),
        meta_title: formData.get('meta_title'),
        meta_description: formData.get('meta_description'),
        canonical_url: formData.get('canonical_url'),
        codeinjection_head: formData.get('codeinjection_head'),
        codeinjection_foot: formData.get('codeinjection_foot')
    };
    
    // Send AJAX request
    fetch('/ghost/admin/ajax/create-tag.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(tagData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success || data.SUCCESS) {
            showMessage('Tag created successfully', 'success');
            // Redirect to edit page
            setTimeout(() => {
                window.location.href = '/ghost/admin/tags/edit/' + (data.tagId || data.TAGID);
            }, 1000);
        } else {
            showMessage(data.message || 'Failed to create tag', 'error');
        }
    })
    .catch(error => {
        console.error('Save error:', error);
        showMessage('Failed to create tag', 'error');
    });
}

// Show message
function showMessage(message, type) {
    // Create toast notification
    const toast = document.createElement('div');
    toast.className = 'bg-white rounded-lg shadow-lg p-4 max-w-sm transform transition-all duration-300 translate-x-full border';
    
    if (type === 'success') {
        toast.className += ' border-green-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-check-circle text-green-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    } else if (type === 'error') {
        toast.className += ' border-red-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-alert-circle text-red-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    } else {
        toast.className += ' border-blue-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-info-circle text-blue-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    }
    
    // Get or create toast container
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column-reverse; gap: 0.5rem;';
        document.body.appendChild(container);
    }
    container.appendChild(toast);
    
    // Animate in
    setTimeout(() => {
        toast.classList.remove('translate-x-full');
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        toast.classList.add('translate-x-full');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3000);
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Update initial counts
    const fields = ['tag-description', 'meta-title', 'meta-description'];
    fields.forEach(field => {
        const el = document.getElementById(field);
        if (el) {
            updateCharCount(field, parseInt(el.getAttribute('maxlength')));
        }
    });
    
    // Initialize slug preview
    updateSlug();
    
    // Keyboard shortcut - Cmd/Ctrl + S to save
    document.addEventListener('keydown', function(e) {
        if ((e.metaKey || e.ctrlKey) && e.key === 's') {
            e.preventDefault();
            saveTag();
        }
    });
});
</script>

<cfinclude template="../includes/footer.cfm">