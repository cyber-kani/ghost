<!--- Check if Ghost fields were saved --->
<cfparam name="url.postId" default="">
<cfparam name="request.dsn" default="blog">

<cfif NOT len(url.postId)>
    <p class="missing">No post ID provided</p>
    <cfabort>
</cfif>

<cftry>
    <cfquery name="qPost" datasource="#request.dsn#">
        SELECT 
            id,
            title,
            show_title_and_feature_image,
            lexical,
            comment_id,
            created_at,
            updated_at
        FROM posts
        WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qPost.recordCount>
        <div style="background: #e8f5e9; padding: 10px; margin: 10px 0;">
            <h4>Post Found!</h4>
            <ul>
                <li><strong>Title:</strong> <cfoutput>#qPost.title#</cfoutput></li>
                <li><strong>show_title_and_feature_image:</strong> 
                    <cfif structKeyExists(qPost, "show_title_and_feature_image")>
                        <cfif isNull(qPost.show_title_and_feature_image)>
                            <span style="color: #ff9800;">NULL</span>
                        <cfelse>
                            <span style="color: #4caf50;"><cfoutput>#qPost.show_title_and_feature_image#</cfoutput></span>
                        </cfif>
                    <cfelse>
                        <span style="color: #f44336;">FIELD DOESN'T EXIST</span>
                    </cfif>
                </li>
                <li><strong>lexical:</strong> 
                    <cfif structKeyExists(qPost, "lexical")>
                        <cfif isNull(qPost.lexical)>
                            <span style="color: #ff9800;">NULL</span>
                        <cfelseif len(qPost.lexical)>
                            <span style="color: #4caf50;">Has content (length: <cfoutput>#len(qPost.lexical)#</cfoutput>)</span>
                        <cfelse>
                            <span style="color: #ff9800;">EMPTY</span>
                        </cfif>
                    <cfelse>
                        <span style="color: #f44336;">FIELD DOESN'T EXIST</span>
                    </cfif>
                </li>
                <li><strong>comment_id:</strong> 
                    <cfif structKeyExists(qPost, "comment_id")>
                        <cfif isNull(qPost.comment_id)>
                            <span style="color: #ff9800;">NULL</span>
                        <cfelseif len(qPost.comment_id)>
                            <span style="color: #4caf50;"><cfoutput>#qPost.comment_id#</cfoutput></span>
                        <cfelse>
                            <span style="color: #ff9800;">EMPTY</span>
                        </cfif>
                    <cfelse>
                        <span style="color: #f44336;">FIELD DOESN'T EXIST</span>
                    </cfif>
                </li>
            </ul>
        </div>
    <cfelse>
        <p class="missing">Post not found with ID: <cfoutput>#url.postId#</cfoutput></p>
    </cfif>
    
<cfcatch>
    <p class="missing">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
</cfcatch>
</cftry>