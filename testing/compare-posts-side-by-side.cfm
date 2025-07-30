<!--- Side-by-side post comparison tool --->
<cfparam name="url.ccprod_id" default="">
<cfparam name="url.ghostprod_id" default="">

<cfoutput>
<!DOCTYPE html>
<html>
<head>
    <title>Side-by-Side Post Comparison</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .form-section { background: ##f5f5f5; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
        .comparison-container { display: flex; gap: 20px; margin-top: 20px; }
        .post-column { 
            flex: 1; 
            border: 2px solid ##ddd; 
            padding: 20px; 
            border-radius: 5px;
            overflow: hidden;
        }
        .cc-prod-column { border-color: ##0066cc; background: ##f0f8ff; }
        .ghost-prod-column { border-color: ##28a745; background: ##f0fff4; }
        .post-header { 
            padding: 10px; 
            margin: -20px -20px 20px -20px; 
            color: white; 
            font-weight: bold;
        }
        .cc-prod-column .post-header { background: ##0066cc; }
        .ghost-prod-column .post-header { background: ##28a745; }
        .metadata { 
            background: white; 
            padding: 15px; 
            margin-bottom: 20px; 
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .html-content { 
            background: white; 
            padding: 20px; 
            border-radius: 5px;
            max-height: 600px;
            overflow-y: auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        pre { 
            white-space: pre-wrap; 
            word-wrap: break-word; 
            margin: 0;
            font-size: 13px;
            line-height: 1.5;
        }
        .error { color: ##d32f2f; background: ##ffebee; padding: 15px; border-radius: 5px; }
        .form-row { margin-bottom: 15px; }
        label { display: inline-block; width: 150px; font-weight: bold; }
        input[type="text"] { width: 300px; padding: 8px; border: 1px solid ##ddd; border-radius: 4px; }
        button { 
            padding: 10px 30px; 
            background: ##007bff; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 16px;
        }
        button:hover { background: ##0056b3; }
        .highlight { background: ##ffeb3b; padding: 2px 4px; }
    </style>
</head>
<body>
    <h1>Side-by-Side Post Comparison</h1>
    
    <div class="form-section">
        <form method="get">
            <div class="form-row">
                <label for="ccprod_id">CC_PROD Post ID:</label>
                <input type="text" id="ccprod_id" name="ccprod_id" value="#url.ccprod_id#" placeholder="Enter post ID from cc_prod">
            </div>
            <div class="form-row">
                <label for="ghostprod_id">GHOST_PROD Post ID:</label>
                <input type="text" id="ghostprod_id" name="ghostprod_id" value="#url.ghostprod_id#" placeholder="Enter post ID from ghost_prod">
            </div>
            <button type="submit">Compare Posts</button>
        </form>
    </div>
    
    <cfif len(url.ccprod_id) OR len(url.ghostprod_id)>
        <div class="comparison-container">
            <!--- CC_PROD Column --->
            <div class="post-column cc-prod-column">
                <div class="post-header">CC_PROD Database</div>
                
                <cfif len(url.ccprod_id)>
                    <cftry>
                        <cfquery name="qCCProd" datasource="blog">
                            SELECT * FROM posts 
                            WHERE id = <cfqueryparam value="#url.ccprod_id#" cfsqltype="cf_sql_varchar">
                        </cfquery>
                        
                        <cfif qCCProd.recordCount GT 0>
                            <div class="metadata">
                                <h3>#qCCProd.title#</h3>
                                <p><strong>ID:</strong> <span class="highlight">#qCCProd.id#</span></p>
                                <p><strong>Slug:</strong> #qCCProd.slug#</p>
                                <p><strong>Status:</strong> #qCCProd.status#</p>
                                <p><strong>Type:</strong> #qCCProd.type#</p>
                                <p><strong>Visibility:</strong> #structKeyExists(qCCProd, "visibility") ? qCCProd.visibility : "N/A"#</p>
                                <p><strong>Featured:</strong> #structKeyExists(qCCProd, "featured") ? (qCCProd.featured ? "Yes" : "No") : "N/A"#</p>
                                <p><strong>Created:</strong> #dateFormat(qCCProd.created_at, "yyyy-mm-dd HH:nn:ss")#</p>
                                <p><strong>Updated:</strong> #dateFormat(qCCProd.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                                <p><strong>Published:</strong> #structKeyExists(qCCProd, "published_at") AND len(qCCProd.published_at) ? dateFormat(qCCProd.published_at, "yyyy-mm-dd HH:nn:ss") : "Not published"#</p>
                                <p><strong>Created By:</strong> #structKeyExists(qCCProd, "created_by") ? qCCProd.created_by : "N/A"#</p>
                                <p><strong>Updated By:</strong> #structKeyExists(qCCProd, "updated_by") ? qCCProd.updated_by : "N/A"#</p>
                                <p><strong>HTML Length:</strong> #len(qCCProd.html)# characters</p>
                                <!--- Feature Image Details --->
                                <cfif structKeyExists(qCCProd, "feature_image") AND len(qCCProd.feature_image)>
                                    <div style="margin-top: 10px; padding: 10px; background: ##f0f8ff; border-radius: 5px;">
                                        <p><strong>Feature Image:</strong></p>
                                        <p style="font-size: 12px; word-break: break-all;">#qCCProd.feature_image#</p>
                                        <cfset imageUrl = qCCProd.feature_image>
                                        <cfif findNoCase("__GHOST_URL__", imageUrl)>
                                            <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "", "all")>
                                        </cfif>
                                        <cfif not findNoCase("/ghost/", imageUrl) and findNoCase("/content/", imageUrl)>
                                            <cfset imageUrl = "/ghost" & imageUrl>
                                        </cfif>
                                        <img src="#imageUrl#" style="max-width: 100%; height: auto; margin-top: 10px; border: 1px solid ##ddd;" 
                                             onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                        <p style="display: none; color: ##999; font-style: italic;">Image could not be loaded</p>
                                        <cfif structKeyExists(qCCProd, "feature_image_alt") AND len(qCCProd.feature_image_alt)>
                                            <p style="margin-top: 5px;"><strong>Alt Text:</strong> #qCCProd.feature_image_alt#</p>
                                        </cfif>
                                        <cfif structKeyExists(qCCProd, "feature_image_caption") AND len(qCCProd.feature_image_caption)>
                                            <p style="margin-top: 5px;"><strong>Caption:</strong> #qCCProd.feature_image_caption#</p>
                                        </cfif>
                                    </div>
                                <cfelse>
                                    <p><strong>Feature Image:</strong> None</p>
                                </cfif>
                                <p><strong>Custom Excerpt:</strong> #structKeyExists(qCCProd, "custom_excerpt") AND len(qCCProd.custom_excerpt) ? left(qCCProd.custom_excerpt, 100) & "..." : "None"#</p>
                                <p><strong>Meta Title:</strong> #structKeyExists(qCCProd, "meta_title") AND len(qCCProd.meta_title) ? qCCProd.meta_title : "None"#</p>
                                <p><strong>Meta Description:</strong> #structKeyExists(qCCProd, "meta_description") AND len(qCCProd.meta_description) ? left(qCCProd.meta_description, 100) & "..." : "None"#</p>
                                <p><strong>Canonical URL:</strong> #structKeyExists(qCCProd, "canonical_url") AND len(qCCProd.canonical_url) ? qCCProd.canonical_url : "None"#</p>
                            </div>
                            
                            <h4>HTML Content:</h4>
                            <div class="html-content">
                                <pre><code>#htmlEditFormat(qCCProd.html)#</code></pre>
                            </div>
                            
                            <!--- Save to file --->
                            <cfset fileName1 = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ccprod_#qCCProd.id#.html">
                            <cffile action="write" file="#fileName1#" output="#qCCProd.html#" charset="utf-8">
                            <p style="margin-top: 10px;"><small>Saved to: <a href="/ghost/testing/ccprod_#qCCProd.id#.html" target="_blank">ccprod_#qCCProd.id#.html</a></small></p>
                        <cfelse>
                            <div class="error">Post not found with ID: #url.ccprod_id#</div>
                        </cfif>
                    <cfcatch>
                        <div class="error">Error: #cfcatch.message#</div>
                    </cfcatch>
                    </cftry>
                <cfelse>
                    <p style="color: ##666;">No CC_PROD post ID provided</p>
                </cfif>
            </div>
            
            <!--- GHOST_PROD Column --->
            <div class="post-column ghost-prod-column">
                <div class="post-header">GHOST_PROD Database</div>
                
                <cfif len(url.ghostprod_id)>
                    <cftry>
                        <cfquery name="qGhostProd" datasource="ghost_prod">
                            SELECT * FROM posts 
                            WHERE id = <cfqueryparam value="#url.ghostprod_id#" cfsqltype="cf_sql_varchar">
                        </cfquery>
                        
                        <cfif qGhostProd.recordCount GT 0>
                            <div class="metadata">
                                <h3>#qGhostProd.title#</h3>
                                <p><strong>ID:</strong> <span class="highlight">#qGhostProd.id#</span></p>
                                <p><strong>Slug:</strong> #qGhostProd.slug#</p>
                                <p><strong>Status:</strong> #qGhostProd.status#</p>
                                <p><strong>Type:</strong> #qGhostProd.type#</p>
                                <p><strong>Visibility:</strong> #structKeyExists(qGhostProd, "visibility") ? qGhostProd.visibility : "N/A"#</p>
                                <p><strong>Featured:</strong> #structKeyExists(qGhostProd, "featured") ? (qGhostProd.featured ? "Yes" : "No") : "N/A"#</p>
                                <p><strong>Created:</strong> #dateFormat(qGhostProd.created_at, "yyyy-mm-dd HH:nn:ss")#</p>
                                <p><strong>Updated:</strong> #dateFormat(qGhostProd.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                                <p><strong>Published:</strong> #structKeyExists(qGhostProd, "published_at") AND len(qGhostProd.published_at) ? dateFormat(qGhostProd.published_at, "yyyy-mm-dd HH:nn:ss") : "Not published"#</p>
                                <p><strong>Created By:</strong> #structKeyExists(qGhostProd, "created_by") ? qGhostProd.created_by : "N/A"#</p>
                                <p><strong>Updated By:</strong> #structKeyExists(qGhostProd, "updated_by") ? qGhostProd.updated_by : "N/A"#</p>
                                <p><strong>HTML Length:</strong> #len(qGhostProd.html)# characters</p>
                                <!--- Feature Image Details --->
                                <cfif structKeyExists(qGhostProd, "feature_image") AND len(qGhostProd.feature_image)>
                                    <div style="margin-top: 10px; padding: 10px; background: ##f0fff4; border-radius: 5px;">
                                        <p><strong>Feature Image:</strong></p>
                                        <p style="font-size: 12px; word-break: break-all;">#qGhostProd.feature_image#</p>
                                        <cfset imageUrl = qGhostProd.feature_image>
                                        <cfif findNoCase("__GHOST_URL__", imageUrl)>
                                            <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "", "all")>
                                        </cfif>
                                        <cfif not findNoCase("/ghost/", imageUrl) and findNoCase("/content/", imageUrl)>
                                            <cfset imageUrl = "/ghost" & imageUrl>
                                        </cfif>
                                        <img src="#imageUrl#" style="max-width: 100%; height: auto; margin-top: 10px; border: 1px solid ##ddd;" 
                                             onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                        <p style="display: none; color: ##999; font-style: italic;">Image could not be loaded</p>
                                        <cfif structKeyExists(qGhostProd, "feature_image_alt") AND len(qGhostProd.feature_image_alt)>
                                            <p style="margin-top: 5px;"><strong>Alt Text:</strong> #qGhostProd.feature_image_alt#</p>
                                        </cfif>
                                        <cfif structKeyExists(qGhostProd, "feature_image_caption") AND len(qGhostProd.feature_image_caption)>
                                            <p style="margin-top: 5px;"><strong>Caption:</strong> #qGhostProd.feature_image_caption#</p>
                                        </cfif>
                                    </div>
                                <cfelse>
                                    <p><strong>Feature Image:</strong> None</p>
                                </cfif>
                                <p><strong>Custom Excerpt:</strong> #structKeyExists(qGhostProd, "custom_excerpt") AND len(qGhostProd.custom_excerpt) ? left(qGhostProd.custom_excerpt, 100) & "..." : "None"#</p>
                                <p><strong>Meta Title:</strong> #structKeyExists(qGhostProd, "meta_title") AND len(qGhostProd.meta_title) ? qGhostProd.meta_title : "None"#</p>
                                <p><strong>Meta Description:</strong> #structKeyExists(qGhostProd, "meta_description") AND len(qGhostProd.meta_description) ? left(qGhostProd.meta_description, 100) & "..." : "None"#</p>
                                <p><strong>Canonical URL:</strong> #structKeyExists(qGhostProd, "canonical_url") AND len(qGhostProd.canonical_url) ? qGhostProd.canonical_url : "None"#</p>
                            </div>
                            
                            <h4>HTML Content:</h4>
                            <div class="html-content">
                                <pre><code>#htmlEditFormat(qGhostProd.html)#</code></pre>
                            </div>
                            
                            <!--- Save to file --->
                            <cfset fileName2 = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghostprod_#qGhostProd.id#.html">
                            <cffile action="write" file="#fileName2#" output="#qGhostProd.html#" charset="utf-8">
                            <p style="margin-top: 10px;"><small>Saved to: <a href="/ghost/testing/ghostprod_#qGhostProd.id#.html" target="_blank">ghostprod_#qGhostProd.id#.html</a></small></p>
                        <cfelse>
                            <div class="error">Post not found with ID: #url.ghostprod_id#</div>
                        </cfif>
                    <cfcatch>
                        <div class="error">Error: #cfcatch.message#</div>
                    </cfcatch>
                    </cftry>
                <cfelse>
                    <p style="color: ##666;">No GHOST_PROD post ID provided</p>
                </cfif>
            </div>
        </div>
        
        <!--- Database Fields Comparison Table --->
        <cfif (len(url.ccprod_id) AND isDefined("qCCProd") AND qCCProd.recordCount GT 0) OR (len(url.ghostprod_id) AND isDefined("qGhostProd") AND qGhostProd.recordCount GT 0)>
            <div style="margin-top: 40px; padding: 20px; background: ##f5f5f5; border-radius: 5px;">
                <h3>All Database Fields Comparison</h3>
                <div style="overflow-x: auto;">
                    <table border="1" cellpadding="5" cellspacing="0" style="width: 100%; background: white;">
                        <tr style="background: ##333; color: white;">
                            <th style="position: sticky; left: 0; background: ##333;">Field Name</th>
                            <cfif len(url.ccprod_id) AND isDefined("qCCProd") AND qCCProd.recordCount GT 0>
                                <th style="background: ##0066cc;">CC_PROD Value</th>
                            </cfif>
                            <cfif len(url.ghostprod_id) AND isDefined("qGhostProd") AND qGhostProd.recordCount GT 0>
                                <th style="background: ##28a745;">GHOST_PROD Value</th>
                            </cfif>
                        </tr>
                        
                        <!--- Get all unique field names from both queries --->
                        <cfset allFields = {}>
                        <cfif isDefined("qCCProd") AND qCCProd.recordCount GT 0>
                            <cfloop list="#qCCProd.columnList#" index="field">
                                <cfset allFields[field] = true>
                            </cfloop>
                        </cfif>
                        <cfif isDefined("qGhostProd") AND qGhostProd.recordCount GT 0>
                            <cfloop list="#qGhostProd.columnList#" index="field">
                                <cfset allFields[field] = true>
                            </cfloop>
                        </cfif>
                        
                        <!--- Sort fields alphabetically --->
                        <cfset fieldList = structKeyList(allFields)>
                        <cfset fieldArray = listToArray(fieldList)>
                        <cfset arraySort(fieldArray, "textnocase")>
                        
                        <!--- Display each field --->
                        <cfloop array="#fieldArray#" index="fieldName">
                            <tr>
                                <td style="font-weight: bold; background: ##f5f5f5; position: sticky; left: 0;">#fieldName#</td>
                                <cfif len(url.ccprod_id) AND isDefined("qCCProd") AND qCCProd.recordCount GT 0>
                                    <td>
                                        <cfif structKeyExists(qCCProd, fieldName)>
                                            <cfset fieldValue = qCCProd[fieldName][1]>
                                            <cfif isNull(fieldValue)>
                                                <em style="color: ##999;">NULL</em>
                                            <cfelseif NOT len(fieldValue)>
                                                <em style="color: ##999;">empty</em>
                                            <cfelseif fieldName EQ "html" OR fieldName EQ "plaintext">
                                                <em style="color: ##666;">#len(fieldValue)# characters</em>
                                            <cfelseif len(fieldValue) GT 100>
                                                #left(htmlEditFormat(fieldValue), 100)#...
                                            <cfelse>
                                                #htmlEditFormat(fieldValue)#
                                            </cfif>
                                        <cfelse>
                                            <em style="color: ##ccc;">N/A</em>
                                        </cfif>
                                    </td>
                                </cfif>
                                <cfif len(url.ghostprod_id) AND isDefined("qGhostProd") AND qGhostProd.recordCount GT 0>
                                    <td>
                                        <cfif structKeyExists(qGhostProd, fieldName)>
                                            <cfset fieldValue = qGhostProd[fieldName][1]>
                                            <cfif isNull(fieldValue)>
                                                <em style="color: ##999;">NULL</em>
                                            <cfelseif NOT len(fieldValue)>
                                                <em style="color: ##999;">empty</em>
                                            <cfelseif fieldName EQ "html" OR fieldName EQ "plaintext">
                                                <em style="color: ##666;">#len(fieldValue)# characters</em>
                                            <cfelseif len(fieldValue) GT 100>
                                                #left(htmlEditFormat(fieldValue), 100)#...
                                            <cfelse>
                                                #htmlEditFormat(fieldValue)#
                                            </cfif>
                                        <cfelse>
                                            <em style="color: ##ccc;">N/A</em>
                                        </cfif>
                                    </td>
                                </cfif>
                            </tr>
                        </cfloop>
                    </table>
                </div>
            </div>
        </cfif>
        
        <!--- Quick links to common comparisons --->
        <div style="margin-top: 40px; padding: 20px; background: ##f5f5f5; border-radius: 5px;">
            <h3>Quick Comparisons:</h3>
            <p>Test 12 post: <a href="?ccprod_id=&ghostprod_id=688a02858edd034b578322f0">View Ghost_prod Test 12</a></p>
            <p>Compare same slug: <a href="compare-by-slug.cfm">Compare by Slug</a></p>
        </div>
    </cfif>
</body>
</html>
</cfoutput>