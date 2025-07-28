<!--- Shared Ghost Editor Template - Main editor UI structure --->
    <!-- Hidden form for saving posts -->
    <form id="postForm" style="display: none;">
        <input type="hidden" id="formPostId" name="postId" value="<cfoutput>#postId#</cfoutput>">
        <input type="hidden" id="formTitle" name="title">
        <input type="hidden" id="formContent" name="content">
        <input type="hidden" id="formPlaintext" name="plaintext">
        <input type="hidden" id="formFeatureImage" name="feature_image">
        <input type="hidden" id="formSlug" name="slug">
        <input type="hidden" id="formExcerpt" name="excerpt">
        <input type="hidden" id="formMetaTitle" name="meta_title">
        <input type="hidden" id="formMetaDescription" name="meta_description">
        <input type="hidden" id="formVisibility" name="visibility">
        <input type="hidden" id="formFeatured" name="featured">
        <input type="hidden" id="formPublishedAt" name="published_at">
        <input type="hidden" id="formTags" name="tags">
        <input type="hidden" id="formStatus" name="status">
        <input type="hidden" id="formAuthors" name="authors">
        <input type="hidden" id="formCustomTemplate" name="custom_template">
        <input type="hidden" id="formCodeinjectionHead" name="codeinjection_head">
        <input type="hidden" id="formCodeinjectionFoot" name="codeinjection_foot">
        <input type="hidden" id="formCanonicalUrl" name="canonical_url">
        <input type="hidden" id="formShowTitleAndFeatureImage" name="show_title_and_feature_image">
        <input type="hidden" id="formOgTitle" name="og_title">
        <input type="hidden" id="formOgDescription" name="og_description">
        <input type="hidden" id="formOgImage" name="og_image">
        <input type="hidden" id="formTwitterTitle" name="twitter_title">
        <input type="hidden" id="formTwitterDescription" name="twitter_description">
        <input type="hidden" id="formTwitterImage" name="twitter_image">
        <input type="hidden" id="formCardData" name="card_data">
    </form>
    
            <header class="ghost-editor-header">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <!-- Back button -->
                        <a href="/ghost/admin/posts" class="flex items-center gap-2 text-gray-600 hover:text-gray-900">
                            <i class="ti ti-arrow-left text-xl"></i>
                            <span>Posts</span>
                        </a>
                        
                        <!-- Post status -->
                        <cfif len(postData.status)>
                            <cfswitch expression="#postData.status#">
                                <cfcase value="published">
                                    <span class="badge bg-success text-white">Published</span>
                                </cfcase>
                                <cfcase value="draft">
                                    <span class="badge bg-gray-200 text-gray-700">Draft</span>
                                </cfcase>
                                <cfcase value="scheduled">
                                    <span class="badge bg-info text-white">Scheduled</span>
                                </cfcase>
                            </cfswitch>
                        </cfif>
                        
                        <!-- Autosave status -->
                        <span id="saveStatus" class="text-sm text-gray-500"><cfif postData.status neq "published">Saved</cfif></span>
                    </div>
                    
                    <div class="flex items-center gap-3">
                        <cfif postData.status eq "published">
                            <!-- Unpublish button for published posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="unpublishPost()">
                                <i class="ti ti-eye-off me-2"></i>
                                Unpublish
                            </button>
                            
                            <!-- Published status button -->
                            <button type="button" class="btn btn-success" disabled>
                                <i class="ti ti-check me-2"></i>
                                Published
                            </button>
                        <cfelseif postData.status eq "scheduled">
                            <!-- Unpublish button for scheduled posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="unpublishPost()">
                                <i class="ti ti-eye-off me-2"></i>
                                Unschedule
                            </button>
                            
                            <!-- Scheduled status button -->
                            <button type="button" class="btn btn-info" disabled>
                                <i class="ti ti-clock me-2"></i>
                                Scheduled
                            </button>
                        <cfelse>
                            <!-- Preview button for non-published posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="previewPost()">
                                <i class="ti ti-eye me-2"></i>
                                Preview
                            </button>
                            
                            <!-- Publish button -->
                            <button type="button" class="btn btn-primary" onclick="publishPost()">
                                <i class="ti ti-send me-2"></i>
                                Publish
                            </button>
                        </cfif>
                    </div>
                </div>
            </header>
            
            <!-- Editor Content -->
            <div class="ghost-editor-content">
                <!-- Feature Image -->
                <div class="feature-image-container" id="featureImageContainer" onclick="selectFeatureImage()">
                    <cfif len(postData.feature_image)>
                        <div class="feature-image-preview">
                            <cfset imageUrl = postData.feature_image>
                            <cfif findNoCase("__GHOST_URL__", imageUrl)>
                                <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "", "all")>
                            </cfif>
                            <cfif not findNoCase("/ghost/", imageUrl) and findNoCase("/content/", imageUrl)>
                                <cfset imageUrl = "/ghost" & imageUrl>
                            </cfif>
                            <img src="<cfoutput>#imageUrl#</cfoutput>" alt="Feature image" id="featureImagePreview" onerror="removeFeatureImage()">
                            <div class="feature-image-actions">
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); changeFeatureImage()">
                                    <i class="ti ti-refresh"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); removeFeatureImage()">
                                    <i class="ti ti-trash"></i>
                                </button>
                            </div>
                        </div>
                    <cfelse>
                        <div class="feature-image-placeholder">
                            <i class="ti ti-photo-plus text-4xl text-gray-400 mb-2"></i>
                            <p class="text-gray-600">Add feature image</p>
                            <p class="text-sm text-gray-500">Click to upload or drag and drop</p>
                        </div>
                    </cfif>
                </div>
                
                <!-- Hidden file input for feature image -->
                <input type="file" id="featureImageInput" accept="image/*" style="display: none;" onchange="uploadFeatureImage(this)">
                
                <!-- Title -->
                <textarea id="postTitle" 
                          class="ghost-editor-title" 
                          placeholder="Post title" 
                          autocomplete="off"
                          rows="1"
                          oninput="autoResizeTitle(this)"><cfoutput>#htmlEditFormat(postData.title)#</cfoutput></textarea>
                
                <!-- Editor Body -->
                <div id="editorContainer" class="ghost-editor-body">
                    <!-- Content cards will be dynamically inserted here -->
                </div>
                
                <!-- Add card button (initially hidden, shown on hover) -->
                <div class="add-card-button" onclick="showCardMenu(this)">
                    <div class="add-card-button-icon">
                        <i class="ti ti-plus"></i>
                    </div>
                </div>
            </div>
            
            <!-- Word count -->
            <div class="ghost-editor-wordcount">
                <span id="wordCount">0</span> words
            </div>
            
            <!-- Settings toggle button -->
            <button type="button" class="ghost-settings-toggle" onclick="toggleSettings()">
                <i class="ti ti-settings text-xl"></i>
            </button>
            
            <!-- Settings panel -->
            <div class="ghost-settings-panel" id="settingsPanel">
                <div class="ghost-settings-header">
                    <h3>Post Settings</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                
                <div class="ghost-settings-content">
                    <!-- Post Details Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Post Details</div>
                        
                        <!-- URL Slug -->
                        <div class="mb-4">
                            <label class="apple-form-label">Post URL</label>
                            <div class="flex items-center gap-2">
                                <span class="text-sm text-gray-500">/ghost/</span>
                                <input type="text" 
                                       id="postSlug" 
                                       class="apple-form-control" 
                                       value="<cfoutput>#htmlEditFormat(postData.slug)#</cfoutput>"
                                       placeholder="post-url">
                            </div>
                            <p class="apple-form-helper">The URL for this post</p>
                        </div>
                    
                        <!-- Publish Date -->
                        <div class="mb-4">
                            <label class="apple-form-label">Publish date</label>
                            <input type="datetime-local" 
                                   id="publishDate" 
                                   class="apple-form-control"
                                   value="<cfif isDate(postData.published_at)><cfoutput>#dateFormat(postData.published_at, 'yyyy-mm-dd')#T#timeFormat(postData.published_at, 'HH:mm')#</cfoutput></cfif>">
                            <p class="apple-form-helper">Set a future date to schedule this post</p>
                        </div>
                    </div>
                    
                    <!-- Tags & Metadata Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Tags & Metadata</div>
                        
                        <!-- Tags -->
                        <div class="mb-4">
                            <label class="apple-form-label">Tags</label>
                            <div class="mb-3">
                                <div id="selectedTags" class="flex flex-wrap gap-2 mb-3">
                                    <cfloop array="#postData.tags#" index="tag">
                                        <span class="apple-tag">
                                            <cfoutput>#tag.name#</cfoutput>
                                            <button type="button" class="apple-tag-remove" onclick="removeTag('<cfoutput>#tag.id#</cfoutput>')">
                                                <i class="ti ti-x text-sm"></i>
                                            </button>
                                        </span>
                                    </cfloop>
                                </div>
                                <select id="tagSelector" class="apple-form-control" onchange="addTag()">
                                    <option value="">Add a tag...</option>
                                    <cfloop array="#allTags#" index="tag">
                                        <option value="<cfoutput>#tag.id#</cfoutput>" data-name="<cfoutput>#tag.name#</cfoutput>">
                                            <cfoutput>#tag.name#</cfoutput>
                                        </option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                    
                        <!-- Post Access -->
                        <div class="mb-4">
                            <label class="apple-form-label">Post access</label>
                            <div class="apple-segmented-control">
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'public'>active</cfif>" onclick="setVisibility('public')">
                                    Public
                                </button>
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'members'>active</cfif>" onclick="setVisibility('members')">
                                    Members
                                </button>
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'paid'>active</cfif>" onclick="setVisibility('paid')">
                                    Paid only
                                </button>
                            </div>
                            <p class="apple-form-helper">Control who can see this post</p>
                        </div>
                    
                        <!-- Excerpt -->
                        <div>
                            <label class="apple-form-label">Excerpt</label>
                            <textarea id="postExcerpt" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="A short description of your post"><cfoutput>#htmlEditFormat(postData.custom_excerpt)#</cfoutput></textarea>
                            <p class="apple-form-helper">Excerpts are optional hand-crafted summaries of your content</p>
                        </div>
                    </div>
                    
                    <!-- Publishing Options Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Publishing Options</div>
                        
                        <!-- Authors -->
                        <div class="mb-4">
                            <label class="apple-form-label">Authors</label>
                            <div class="mb-3">
                                <div id="selectedAuthors" class="flex flex-wrap gap-2 mb-3">
                                    <!--- Show current author(s) from posts_authors table --->
                                    <cfquery name="postAuthors" datasource="#request.dsn#">
                                        SELECT u.id, u.name 
                                        FROM posts_authors pa
                                        INNER JOIN users u ON pa.author_id = u.id
                                        WHERE pa.post_id = <cfqueryparam value="#postData.id#" cfsqltype="cf_sql_varchar">
                                        ORDER BY pa.sort_order
                                    </cfquery>
                                    
                                    <cfif postAuthors.recordCount gt 0>
                                        <cfloop query="postAuthors">
                                            <span class="apple-tag" data-author-id="<cfoutput>#postAuthors.id#</cfoutput>">
                                                <cfoutput>#postAuthors.name#</cfoutput>
                                                <button type="button" class="apple-tag-remove" onclick="removeAuthor('<cfoutput>#postAuthors.id#</cfoutput>')">
                                                    <i class="ti ti-x text-sm"></i>
                                                </button>
                                            </span>
                                        </cfloop>
                                    <cfelse>
                                        <!--- If no authors, use the created_by user --->
                                        <cfquery name="defaultAuthor" datasource="#request.dsn#">
                                            SELECT id, name FROM users WHERE id = <cfqueryparam value="#postData.created_by#" cfsqltype="cf_sql_varchar">
                                        </cfquery>
                                        <cfif defaultAuthor.recordCount gt 0>
                                            <span class="apple-tag" data-author-id="<cfoutput>#defaultAuthor.id#</cfoutput>">
                                                <cfoutput>#defaultAuthor.name#</cfoutput>
                                                <button type="button" class="apple-tag-remove" onclick="removeAuthor('<cfoutput>#defaultAuthor.id#</cfoutput>')">
                                                    <i class="ti ti-x text-sm"></i>
                                                </button>
                                            </span>
                                        </cfif>
                                    </cfif>
                                </div>
                                <select id="authorSelector" class="apple-form-control" onchange="addAuthor()">
                                    <option value="">Add an author...</option>
                                    <cfquery name="allUsers" datasource="#request.dsn#">
                                        SELECT id, name FROM users WHERE status = 'active' ORDER BY name
                                    </cfquery>
                                    <cfloop query="allUsers">
                                        <option value="<cfoutput>#allUsers.id#</cfoutput>" 
                                                data-name="<cfoutput>#allUsers.name#</cfoutput>"
                                                class="author-option-<cfoutput>#allUsers.id#</cfoutput>"
                                                <cfif postAuthors.recordCount gt 0>
                                                    <cfloop query="postAuthors">
                                                        <cfif postAuthors.id eq allUsers.id>style="display: none;"</cfif>
                                                    </cfloop>
                                                <cfelseif defaultAuthor.recordCount gt 0 and defaultAuthor.id eq allUsers.id>
                                                    style="display: none;"
                                                </cfif>>
                                            <cfoutput>#allUsers.name#</cfoutput>
                                        </option>
                                    </cfloop>
                                </select>
                            </div>
                            <p class="apple-form-helper">Add multiple authors to this post</p>
                        </div>
                    
                        <!-- Post Template -->
                        <div class="mb-4">
                            <label class="apple-form-label">Template</label>
                            <select id="postTemplate" class="apple-form-control">
                                <option value="">Default</option>
                                <option value="custom" <cfif structKeyExists(postData, "custom_template") and postData.custom_template eq "custom">selected</cfif>>Custom</option>
                                <option value="page" <cfif structKeyExists(postData, "custom_template") and postData.custom_template eq "page">selected</cfif>>Page</option>
                            </select>
                            <p class="apple-form-helper">Select a custom template for this post</p>
                        </div>
                    
                        <!-- Feature Options -->
                        <cfif postData.type eq "page">
                        <div class="apple-list-item">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-eye"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Show title and feature image</h4>
                                </div>
                            </div>
                            <label class="apple-switch">
                                <input type="checkbox" 
                                       id="showTitleAndFeatureImage"
                                       <cfif not structKeyExists(postData, "show_title_and_feature_image") or postData.show_title_and_feature_image>checked</cfif>>
                                <span class="apple-switch-slider"></span>
                            </label>
                        </div>
                        </cfif>
                        
                        <div class="apple-list-item">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-star"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Feature this post</h4>
                                    <p>Display prominently on your site</p>
                                </div>
                            </div>
                            <label class="apple-switch">
                                <input type="checkbox" 
                                       id="featuredPost"
                                       <cfif postData.featured>checked</cfif>>
                                <span class="apple-switch-slider"></span>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Advanced Settings Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Advanced Settings</div>
                        
                        <div class="apple-list-item" onclick="showSubview('postHistory')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-history"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Post history</h4>
                                    <p>View and restore previous versions</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('codeInjection')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-code"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Code injection</h4>
                                    <p>Add custom code to this post</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('metaData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-search"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Meta data</h4>
                                    <p>SEO title, description and URL</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('twitterData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-brand-x"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>X card</h4>
                                    <p>Customize X/Twitter preview</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('facebookData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-brand-facebook"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Facebook card</h4>
                                    <p>Customize Facebook preview</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                    </div>
                    
                    <!-- Delete Post Button -->
                    <div class="settings-section">
                        <button type="button" class="apple-btn apple-btn-danger w-100" onclick="confirmDeletePost()">
                            <i class="ti ti-trash"></i>
                            Delete post
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Subview Panels -->
            <!-- Code Injection Subview -->
            <div class="subview-panel" id="codeInjectionSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('codeInjection')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Code injection</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="mb-4">
                            <label class="apple-form-label">Post header</label>
                            <textarea id="codeinjectionHead" 
                                      class="apple-form-control" 
                                      style="font-family: 'SF Mono', Monaco, monospace; font-size: 13px;"
                                      rows="10"
                                      placeholder="Code injected into the header of this post"><cfoutput>#htmlEditFormat(structKeyExists(postData, "codeinjection_head") ? postData.codeinjection_head : "")#</cfoutput></textarea>
                            <p class="apple-form-helper">Code here will be injected into the <code style="background: var(--apple-bg-tertiary); padding: 2px 6px; border-radius: 4px;">&lt;head&gt;</code> tag</p>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div>
                            <label class="apple-form-label">Post footer</label>
                            <textarea id="codeinjectionFoot" 
                                      class="apple-form-control" 
                                      style="font-family: 'SF Mono', Monaco, monospace; font-size: 13px;"
                                      rows="10"
                                      placeholder="Code injected into the footer of this post"><cfoutput>#htmlEditFormat(structKeyExists(postData, "codeinjection_foot") ? postData.codeinjection_foot : "")#</cfoutput></textarea>
                            <p class="apple-form-helper">Code here will be injected before the closing <code style="background: var(--apple-bg-tertiary); padding: 2px 6px; border-radius: 4px;">&lt;/body&gt;</code> tag</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Meta Data Subview -->
            <div class="subview-panel" id="metaDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('metaData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Meta data</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="settings-section-title">Search Engine Optimization</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Meta title</label>
                            <input type="text" 
                                   id="metaTitle" 
                                   class="apple-form-control" 
                                   value="<cfoutput>#htmlEditFormat(postData.meta_title)#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="metaTitleCounter">
                                <span class="text-gray-500">Recommended: 60 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="metaTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Meta description</label>
                            <textarea id="metaDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="A description of your post for search engines"><cfoutput>#htmlEditFormat(postData.meta_description)#</cfoutput></textarea>
                            <div class="char-counter" id="metaDescriptionCounter">
                                <span class="text-gray-500">Recommended: 160 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="metaDescriptionCount">0</strong></span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div>
                            <label class="apple-form-label">Canonical URL</label>
                            <input type="url" 
                                   id="canonicalUrl" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "canonical_url") ? postData.canonical_url : "")#</cfoutput>"
                                   placeholder="https://example.com/original-post">
                            <p class="apple-form-helper">Set a canonical URL if this post was first published elsewhere</p>
                            <div id="canonicalUrlPreview" class="mt-2 text-sm text-blue-600" style="display: none;">
                                <i class="ti ti-link"></i> <span id="canonicalUrlText"></span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Search Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Search Result Preview</div>
                        <div class="p-4 bg-white rounded-lg border">
                            <h4 class="text-blue-600 text-lg mb-1" id="searchPreviewTitle"><cfoutput>#postData.title#</cfoutput></h4>
                            <p class="text-green-700 text-sm mb-1">clitools.app/ghost/<span id="searchPreviewSlug"><cfoutput>#postData.slug#</cfoutput></span></p>
                            <p class="text-gray-600 text-sm" id="searchPreviewDesc"><cfoutput><cfscript>
                                // Search preview description fallback logic
                                searchDesc = "";
                                if (len(postData.meta_description)) {
                                    searchDesc = postData.meta_description;
                                } else if (len(postData.custom_excerpt)) {
                                    searchDesc = postData.custom_excerpt;
                                } else if (len(postData.html)) {
                                    // Extract first paragraph from HTML content
                                    firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                    if (arrayLen(firstP) gt 0) {
                                        // Strip HTML tags from first paragraph
                                        searchDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                        searchDesc = replace(searchDesc, "&nbsp;", " ", "all");
                                        searchDesc = replace(searchDesc, "&amp;", "&", "all");
                                        searchDesc = replace(searchDesc, "&lt;", "<", "all");
                                        searchDesc = replace(searchDesc, "&gt;", ">", "all");
                                        searchDesc = replace(searchDesc, "&quot;", '"', "all");
                                        searchDesc = trim(searchDesc);
                                    }
                                }
                                writeOutput(left(searchDesc, 160));
                            </cfscript></cfoutput></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Twitter/X Card Subview -->
            <div class="subview-panel" id="twitterDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('twitterData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>X card</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <!-- Twitter Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Preview</div>
                        <div class="social-preview">
                            <div id="twitterPreviewImage" class="social-preview-image"></div>
                            <div class="social-preview-content">
                                <p class="social-preview-domain">CLITOOLS.APP</p>
                                <h4 id="twitterPreviewTitle" class="social-preview-title"><cfoutput>#len(postData.twitter_title) ? postData.twitter_title : postData.title#</cfoutput></h4>
                                <p id="twitterPreviewDesc" class="social-preview-description"><cfoutput><cfscript>
                                    // Twitter/X description fallback logic
                                    twitterDesc = "";
                                    if (len(postData.twitter_description)) {
                                        twitterDesc = postData.twitter_description;
                                    } else if (len(postData.meta_description)) {
                                        twitterDesc = postData.meta_description;
                                    } else if (len(postData.custom_excerpt)) {
                                        twitterDesc = postData.custom_excerpt;
                                    } else if (len(postData.html)) {
                                        // Extract first paragraph from HTML content
                                        firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                        if (arrayLen(firstP) gt 0) {
                                            // Strip HTML tags from first paragraph
                                            twitterDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                            twitterDesc = replace(twitterDesc, "&nbsp;", " ", "all");
                                            twitterDesc = replace(twitterDesc, "&amp;", "&", "all");
                                            twitterDesc = replace(twitterDesc, "&lt;", "<", "all");
                                            twitterDesc = replace(twitterDesc, "&gt;", ">", "all");
                                            twitterDesc = replace(twitterDesc, "&quot;", '"', "all");
                                            twitterDesc = trim(twitterDesc);
                                        }
                                    }
                                    writeOutput(left(twitterDesc, 125));
                                </cfscript></cfoutput></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div class="settings-section-title">X/Twitter Settings</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">X title</label>
                            <input type="text" 
                                   id="twitterTitle" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_title") ? postData.twitter_title : "")#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="twitterTitleCounter">
                                <span class="text-gray-500">Recommended: 70 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="twitterTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">X description</label>
                            <textarea id="twitterDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="<cfoutput>#htmlEditFormat(len(postData.meta_description) ? postData.meta_description : (len(postData.custom_excerpt) ? postData.custom_excerpt : left(firstParagraphText, 125)))#</cfoutput>"><cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_description") ? postData.twitter_description : "")#</cfoutput></textarea>
                            <div class="char-counter" id="twitterDescriptionCounter">
                                <span class="text-gray-500">Recommended: 125 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="twitterDescriptionCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div>
                            <label class="apple-form-label">X image</label>
                            <div class="mb-2">
                                <input type="url" 
                                       id="twitterImage" 
                                       class="apple-form-control"
                                       value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_image") ? postData.twitter_image : "")#</cfoutput>"
                                       placeholder="URL of image for X/Twitter card">
                            </div>
                            <button type="button" class="apple-btn apple-btn-secondary">
                                <i class="ti ti-upload"></i>
                                Upload image
                            </button>
                    </div>
                </div>
            </div>
            
            <!-- Facebook Card Subview -->
            <div class="subview-panel" id="facebookDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('facebookData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Facebook card</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <!-- Facebook Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Preview</div>
                        <div class="social-preview">
                            <div id="fbPreviewImage" class="social-preview-image"></div>
                            <div class="social-preview-content">
                                <p class="social-preview-domain">CLITOOLS.APP</p>
                                <h4 id="fbPreviewTitle" class="social-preview-title"><cfoutput>#len(postData.og_title) ? postData.og_title : postData.title#</cfoutput></h4>
                                <p id="fbPreviewDesc" class="social-preview-description"><cfoutput><cfscript>
                                    // Facebook description fallback logic
                                    fbDesc = "";
                                    if (len(postData.og_description)) {
                                        fbDesc = postData.og_description;
                                    } else if (len(postData.meta_description)) {
                                        fbDesc = postData.meta_description;
                                    } else if (len(postData.custom_excerpt)) {
                                        fbDesc = postData.custom_excerpt;
                                    } else if (len(postData.html)) {
                                        // Extract first paragraph from HTML content
                                        firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                        if (arrayLen(firstP) gt 0) {
                                            // Strip HTML tags from first paragraph
                                            fbDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                            fbDesc = replace(fbDesc, "&nbsp;", " ", "all");
                                            fbDesc = replace(fbDesc, "&amp;", "&", "all");
                                            fbDesc = replace(fbDesc, "&lt;", "<", "all");
                                            fbDesc = replace(fbDesc, "&gt;", ">", "all");
                                            fbDesc = replace(fbDesc, "&quot;", '"', "all");
                                            fbDesc = trim(fbDesc);
                                        }
                                    }
                                    writeOutput(left(fbDesc, 160));
                                </cfscript></cfoutput></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div class="settings-section-title">Facebook Settings</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Facebook title</label>
                            <input type="text" 
                                   id="facebookTitle" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "og_title") ? postData.og_title : "")#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="facebookTitleCounter">
                                <span class="text-gray-500">Recommended: 60 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="facebookTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Facebook description</label>
                            <textarea id="facebookDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="<cfoutput>#htmlEditFormat(len(postData.meta_description) ? postData.meta_description : (len(postData.custom_excerpt) ? postData.custom_excerpt : left(firstParagraphText, 160)))#</cfoutput>"><cfoutput>#htmlEditFormat(structKeyExists(postData, "og_description") ? postData.og_description : "")#</cfoutput></textarea>
                            <div class="char-counter" id="facebookDescriptionCounter">
                                <span class="text-gray-500">Recommended: 160 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="facebookDescriptionCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div>
                            <label class="apple-form-label">Facebook image</label>
                            <div class="mb-2">
                                <input type="url" 
                                       id="facebookImage" 
                                       class="apple-form-control"
                                       value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "og_image") ? postData.og_image : "")#</cfoutput>"
                                       placeholder="URL of image for Facebook card">
                            </div>
                            <button type="button" class="apple-btn apple-btn-secondary">
                                <i class="ti ti-upload"></i>
                                Upload image
                            </button>
                            <p class="apple-form-helper mt-2">Recommended size: 1200x630px (1.91:1 ratio)</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Post History Subview -->
            <div class="subview-panel" id="postHistorySubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('postHistory')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Post history</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="text-center py-5">
                            <div class="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                                <i class="ti ti-history text-3xl text-gray-400"></i>
                            </div>
                            <h4 class="text-lg font-semibold text-gray-900 mb-2">Post history</h4>
                            <p class="text-gray-500 mb-1">Version history is coming soon</p>
                            <p class="text-sm text-gray-400">You'll be able to view and restore previous versions of this post</p>
                        </div>
                    </div>
                    
                    <!-- Placeholder for future history items -->
                    <div class="settings-section" style="display: none;">
                        <div class="settings-section-title">Recent Versions</div>
                        <div class="history-item">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h5 class="font-medium text-gray-900">Current version</h5>
                                    <p class="history-meta">Edited just now</p>
                                </div>
                                <span class="text-sm text-green-600">Current</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
        </div>
        
        <!-- Unsaved Changes Modal -->
        <div id="unsavedChangesModal" class="hidden ghost-modal-backdrop" style="display: none;">
            <div class="ghost-modal">
                <div class="ghost-modal-header">
                    <h3>Are you sure you want to leave this page?</h3>
                    <button type="button" class="ghost-modal-close" onclick="hideUnsavedChangesModal()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="ghost-modal-body">
                    <p class="text-gray-600 text-base">
                        You have unsaved changes. Do you want to save before leaving?
                    </p>
                </div>
                <div class="ghost-modal-footer">
                    <button type="button" class="ghost-btn ghost-btn-link" onclick="leaveWithoutSaving()">
                        <span>Leave without saving</span>
                    </button>
                    <button type="button" class="ghost-btn ghost-btn-link" onclick="saveAndStay()">
                        <span>Save & stay</span>
                    </button>
                    <button type="button" class="ghost-btn ghost-btn-black" onclick="saveAndLeave()">
                        <span>Save & leave</span>
                    </button>
                </div>
            </div>
        </div>
    </main>
