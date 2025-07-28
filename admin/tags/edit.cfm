<!--- Edit Tag Page --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.id" default="">

<!--- Validate tag ID --->
<cfif NOT len(trim(url.id))>
    <cflocation url="/ghost/admin/tags" addtoken="false">
</cfif>

<!--- Get existing tag data --->
<cfquery name="qTag" datasource="#request.dsn#">
    SELECT 
        id,
        name,
        slug,
        description,
        feature_image,
        visibility,
        meta_title,
        meta_description,
        canonical_url,
        accent_color,
        og_title,
        og_description,
        og_image,
        twitter_title,
        twitter_description,
        twitter_image,
        codeinjection_head,
        codeinjection_foot,
        created_at,
        updated_at,
        created_by,
        updated_by
    FROM tags
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- If tag not found, redirect --->
<cfif qTag.recordCount EQ 0>
    <cflocation url="/ghost/admin/tags" addtoken="false">
</cfif>

<cfset pageTitle = "Edit tag">
<cfinclude template="../includes/header.cfm">

<!--- Convert query to struct for easier access --->
<cfscript>
    tagData = {
        id: qTag.id,
        name: qTag.name,
        slug: qTag.slug,
        description: qTag.description,
        feature_image: qTag.feature_image,
        visibility: qTag.visibility,
        meta_title: qTag.meta_title,
        meta_description: qTag.meta_description,
        canonical_url: qTag.canonical_url,
        accent_color: qTag.accent_color,
        og_title: qTag.og_title,
        og_description: qTag.og_description,
        og_image: qTag.og_image,
        twitter_title: qTag.twitter_title,
        twitter_description: qTag.twitter_description,
        twitter_image: qTag.twitter_image,
        codeinjection_head: qTag.codeinjection_head,
        codeinjection_foot: qTag.codeinjection_foot,
        created_at: qTag.created_at,
        updated_at: qTag.updated_at,
        created_by: qTag.created_by,
        updated_by: qTag.updated_by
    };
    
    isNew = false;
</cfscript>

<!-- Modern Tag Editor -->
<div class="body-wrapper">
    <div class="container-fluid">
        <form id="tagForm">
            <input type="hidden" name="tagId" value="<cfoutput>#tagData.id#</cfoutput>">
            
            <!-- Modern Breadcrumb Card -->
            <div class="card mb-6 shadow-none">
                <div class="card-body p-6">
                    <div class="sm:flex items-center justify-between">
                        <div>
                            <h4 class="font-semibold text-xl text-dark dark:text-white">Edit Tag</h4>
                            <div class="flex items-center gap-2 mt-2">
                                <span class="text-sm text-gray-600">Editing:</span>
                                <span class="text-sm font-medium text-primary"><cfoutput>#tagData.name#</cfoutput></span>
                            </div>
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
                            <li class="flex items-center text-sm font-medium" aria-current="page">Edit</li>
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
                                <i class="ti ti-device-floppy me-2"></i>Save Changes
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
                                            <div class="w-7 h-7 rounded border border-gray-300 cursor-pointer overflow-hidden" id="colorPreview" style="background: <cfoutput>##<cfif len(tagData.accent_color)>#tagData.accent_color#<cfelse>15171A</cfif></cfoutput>">
                                                <input type="color" 
                                                       id="colorPicker"
                                                       class="opacity-0 w-full h-full cursor-pointer" 
                                                       value="<cfoutput>##<cfif len(tagData.accent_color)>#tagData.accent_color#<cfelse>15171A</cfif></cfoutput>"
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
                                    <cfoutput>https://example.com/tag/</cfoutput><span id="slugPreview" class="font-medium"><cfoutput>#tagData.slug#</cfoutput></span>
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
                                <div id="imagePreview" class="relative group" <cfif NOT len(tagData.feature_image)>style="display: none;"</cfif>>
                                    <img id="previewImg" src="<cfoutput>#tagData.feature_image#</cfoutput>" alt="Tag image" class="w-full h-64 object-cover rounded-lg">
                                    <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center">
                                        <button type="button" class="btn btn-sm btn-light" onclick="removeImage()">
                                            <i class="ti ti-trash me-1"></i>Remove
                                        </button>
                                    </div>
                                </div>
                                <div id="imageUploader" class="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center hover:border-gray-400 transition-colors" <cfif len(tagData.feature_image)>style="display: none;"</cfif>>
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
                                <input type="hidden" id="feature_image" name="feature_image" value="<cfoutput>#tagData.feature_image#</cfoutput>">
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
                                                <div class="gh-seo-preview-link">example.com › tag › <span id="seo-slug"><cfoutput>#tagData.slug#</cfoutput></span></div>
                                                <div class="gh-seo-preview-title" id="seo-title"><cfoutput>#tagData.name#</cfoutput></div>
                                                <div class="gh-seo-preview-desc" id="seo-description"><cfoutput><cfif len(tagData.description)>#tagData.description#<cfelse>Tag description will appear here</cfif></cfoutput></div>
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
                                <div class="gh-seo-settings">
                                    <div class="gh-seo-settings-left flex-basis-1-2-m flex-basis-2-3-l">
                                        <div class="form-group">
                                            <label for="twitter-title">X title</label>
                                            <input type="text" 
                                                   id="twitter-title" 
                                                   name="twitter_title" 
                                                   class="gh-input-x form-control"
                                                   placeholder="X title"
                                                   value="<cfoutput>#tagData.twitter_title#</cfoutput>">
                                        </div>

                                        <div class="form-group">
                                            <label for="twitter-description">X description</label>
                                            <textarea id="twitter-description" 
                                                      name="twitter_description" 
                                                      class="gh-input-x gh-tag-details-textarea form-control"
                                                      rows="3"
                                                      placeholder="X description"><cfoutput>#tagData.twitter_description#</cfoutput></textarea>
                                        </div>

                                        <div class="form-group">
                                            <label for="twitter-image">X image</label>
                                            <input type="text" 
                                                   id="twitter-image" 
                                                   name="twitter_image" 
                                                   class="gh-input-x form-control"
                                                   placeholder="X image URL"
                                                   value="<cfoutput>#tagData.twitter_image#</cfoutput>">
                                        </div>
                                    </div>
                                </div>
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
                                <div class="gh-seo-settings">
                                    <div class="gh-seo-settings-left flex-basis-1-2-m flex-basis-2-3-l">
                                        <div class="form-group">
                                            <label for="og-title">Facebook title</label>
                                            <input type="text" 
                                                   id="og-title" 
                                                   name="og_title" 
                                                   class="gh-input-x form-control"
                                                   placeholder="Facebook title"
                                                   value="<cfoutput>#tagData.og_title#</cfoutput>">
                                        </div>

                                        <div class="form-group">
                                            <label for="og-description">Facebook description</label>
                                            <textarea id="og-description" 
                                                      name="og_description" 
                                                      class="gh-input-x gh-tag-details-textarea form-control"
                                                      rows="3"
                                                      placeholder="Facebook description"><cfoutput>#tagData.og_description#</cfoutput></textarea>
                                        </div>

                                        <div class="form-group">
                                            <label for="og-image">Facebook image</label>
                                            <input type="text" 
                                                   id="og-image" 
                                                   name="og_image" 
                                                   class="gh-input-x form-control"
                                                   placeholder="Facebook image URL"
                                                   value="<cfoutput>#tagData.og_image#</cfoutput>">
                                        </div>
                                    </div>
                                </div>
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

                <!-- Delete Tag Section -->
                <div class="card border-red-200 bg-red-50">
                    <div class="card-body">
                        <h5 class="font-semibold text-red-700 mb-2">Danger Zone</h5>
                        <p class="text-sm text-red-600 mb-4">Permanently delete this tag. This will remove the tag from all posts. This action cannot be undone.</p>
                        <button type="button" class="btn btn-danger" onclick="showDeleteModal()">
                            <i class="ti ti-trash me-2"></i>Delete Tag
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<style>
/* Ghost Tag Form Styles */
.gh-canvas {
    display: flex;
    flex-direction: column;
    min-height: calc(100vh - 80px);
}

.gh-canvas-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 2rem 2.4rem;
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
}

.gh-canvas-breadcrumb {
    display: flex;
    align-items: center;
    font-size: 1.3rem;
    color: #626d79;
    margin-bottom: 0.4rem;
}

.gh-canvas-breadcrumb a {
    color: #626d79;
    text-decoration: none;
}

.gh-canvas-breadcrumb a:hover {
    color: #14b8ff;
}

.gh-canvas-title {
    font-size: 2.4rem;
    font-weight: 700;
    letter-spacing: -.018em;
    margin: 0;
}

.gh-main-section {
    padding: 0 2.4rem;
}

.gh-main-section-content {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 3.2rem;
    margin: 2.4rem 0;
}

.gh-main-section-content.bordered {
    border: 1px solid #e5e7eb;
}

.gh-main-section-content.columns-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 4rem;
}

/* Form Elements */
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

.gh-tag-settings-multiprop {
    display: flex;
    gap: 2rem;
    margin-bottom: 2.8rem;
}

.gh-tag-settings-colorcontainer {
    flex: 0 0 140px;
}

.input-color {
    position: relative;
    display: flex;
    align-items: center;
}

.input-color input[type="text"] {
    padding-right: 50px;
}

.color-box-container {
    position: absolute;
    right: 1px;
    top: 1px;
    bottom: 1px;
    width: 38px;
    background: #15171a;
    border-radius: 0 2px 2px 0;
    cursor: pointer;
}

.color-picker {
    width: 100%;
    height: 100%;
    border: none;
    background: transparent;
    cursor: pointer;
    opacity: 0;
}

.description {
    font-size: 1.3rem;
    color: #626d79;
    margin: 0.8rem 0 0;
}

/* Image Uploader */
.gh-tag-image-uploader {
    margin-top: 2.8rem;
}

.gh-image-uploader-with-preview {
    position: relative;
    min-height: 130px;
}

.image-preview {
    position: relative;
    display: inline-block;
}

.image-preview img {
    max-width: 100%;
    max-height: 300px;
    border-radius: 3px;
}

.image-delete {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    border: none;
    border-radius: 3px;
    padding: 5px 10px;
    cursor: pointer;
}

/* Expandable Sections */
.gh-expandable {
    padding: 0 2.4rem;
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

/* Delete Section */
.gh-main-section-block {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 3.2rem;
    margin-bottom: 2.4rem;
}

.gh-delete-tag {
    text-align: left;
}

.gh-btn-red {
    background: #dc2626;
    color: white;
    border: none;
}

.gh-btn-red:hover {
    background: #b91c1c;
}

/* Utilities */
.mr2 { margin-right: 2rem; }
.mb-2 { margin-bottom: 0.8rem; }
.mb-3 { margin-bottom: 1.2rem; }
.flex-auto { flex: 1 1 auto; }
.no-margin { margin: 0; }
.flex-basis-1-2-m { flex-basis: 50%; }
.flex-basis-2-3-l { flex-basis: 66.66667%; }
.flex-basis-1-3-l { flex-basis: 33.33333%; }
.fw4 { font-weight: 400; }
.ml1 { margin-left: 0.4rem; }
.code-editor {
    font-family: monospace;
    font-size: 1.3rem;
}

/* Message alerts */
.alert-message {
    animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}
</style>

<script>
// Store original slug for comparison
const originalSlug = '<cfoutput>#tagData.slug#</cfoutput>';
let manualSlugEdit = false;

// Generate slug from name
function updateSlug() {
    const nameInput = document.getElementById('tag-name');
    const slugInput = document.getElementById('tag-slug');
    const slugPreview = document.getElementById('slugPreview');
    const seoSlug = document.getElementById('seo-slug');
    const seoTitle = document.getElementById('seo-title');
    
    // Only update slug if it hasn't been manually edited
    if (!manualSlugEdit) {
        const newSlug = generateSlug(nameInput.value);
        slugInput.value = newSlug;
        slugPreview.textContent = newSlug;
        seoSlug.textContent = newSlug;
    }
    
    seoTitle.textContent = nameInput.value || 'Tag Name';
}

// Update slug preview when manually editing slug
function updateSlugPreview() {
    const slugInput = document.getElementById('tag-slug');
    const slugPreview = document.getElementById('slugPreview');
    const seoSlug = document.getElementById('seo-slug');
    
    manualSlugEdit = true;
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
    const icon = document.getElementById(section + '-icon');
    
    if (content.style.display === 'none') {
        content.style.display = 'block';
        toggle.textContent = 'Close';
        if (icon) icon.classList.add('rotate-180');
    } else {
        content.style.display = 'none';
        toggle.textContent = 'Expand';
        if (icon) icon.classList.remove('rotate-180');
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
        tagId: formData.get('tagId'),
        name: formData.get('name'),
        slug: formData.get('slug') || generateSlug(formData.get('name')),
        description: formData.get('description'),
        feature_image: formData.get('feature_image'),
        accent_color: formData.get('accent_color'),
        meta_title: formData.get('meta_title'),
        meta_description: formData.get('meta_description'),
        canonical_url: formData.get('canonical_url'),
        og_title: formData.get('og_title'),
        og_description: formData.get('og_description'),
        og_image: formData.get('og_image'),
        twitter_title: formData.get('twitter_title'),
        twitter_description: formData.get('twitter_description'),
        twitter_image: formData.get('twitter_image'),
        codeinjection_head: formData.get('codeinjection_head'),
        codeinjection_foot: formData.get('codeinjection_foot')
    };
    
    // Send AJAX request
    fetch('/ghost/admin/ajax/update-tag.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(tagData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success || data.SUCCESS) {
            showMessage('Tag updated successfully', 'success');
            // Update slug if it changed
            if (data.slug && data.slug !== originalSlug) {
                window.history.replaceState({}, '', '/ghost/admin/tags/edit/' + tagData.tagId);
            }
        } else {
            showMessage(data.message || 'Failed to update tag', 'error');
        }
    })
    .catch(error => {
        console.error('Save error:', error);
        showMessage('Failed to update tag', 'error');
    });
}

// Show delete confirmation modal
function showDeleteModal() {
    const tagName = document.getElementById('tag-name').value;
    
    // Create modal backdrop
    const backdrop = document.createElement('div');
    backdrop.className = 'modal-backdrop';
    backdrop.id = 'deleteModalBackdrop';
    
    // Create modal
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-header px-6 py-4 border-b">
            <h3 class="text-lg font-semibold">Delete Tag</h3>
            <button type="button" class="text-gray-400 hover:text-gray-600" onclick="closeDeleteModal()">
                <i class="ti ti-x text-xl"></i>
            </button>
        </div>
        <div class="modal-body px-6 py-4">
            <p class="text-gray-600">
                Are you sure you want to delete <strong>"${tagName}"</strong>? 
                This will remove the tag from all posts. This action cannot be undone.
            </p>
        </div>
        <div class="modal-footer px-6 py-4 border-t flex justify-end gap-3">
            <button type="button" class="btn btn-light" onclick="closeDeleteModal()">
                Cancel
            </button>
            <button type="button" class="btn btn-danger" onclick="executeDeleteTag()">
                <i class="ti ti-trash me-2"></i>Delete Tag
            </button>
        </div>
    `;
    
    backdrop.appendChild(modal);
    document.body.appendChild(backdrop);
    
    // Animate in
    setTimeout(() => {
        modal.classList.add('show');
    }, 10);
    
    // Close on backdrop click
    backdrop.addEventListener('click', function(e) {
        if (e.target === backdrop) {
            closeDeleteModal();
        }
    });
}

// Close delete modal
function closeDeleteModal() {
    const backdrop = document.getElementById('deleteModalBackdrop');
    if (backdrop) {
        backdrop.remove();
    }
}

// Execute delete
function executeDeleteTag() {
    const tagId = document.querySelector('input[name="tagId"]').value;
    
    closeDeleteModal();
    
    // Show loading
    showMessage('Deleting tag...', 'info');
    
    // Send delete request
    fetch('/ghost/admin/ajax/delete-tag.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ tagId: tagId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success || data.SUCCESS) {
            showMessage('Tag deleted successfully', 'success');
            // Redirect to tags list
            setTimeout(() => {
                window.location.href = '/ghost/admin/tags';
            }, 1000);
        } else {
            showMessage(data.message || 'Failed to delete tag', 'error');
        }
    })
    .catch(error => {
        console.error('Delete error:', error);
        showMessage('Failed to delete tag', 'error');
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
    
    // Initialize accent color if present
    if (document.getElementById('accent-color').value) {
        updateAccentColor();
    }
    
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