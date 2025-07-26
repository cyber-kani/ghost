<!DOCTYPE html>
<html>
<head>
    <title>Test Bookmark Display</title>
    <style>
        .test-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
        }
        
        /* Ghost Bookmark Card Styles */
        .kg-bookmark-card,
        .kg-bookmark-card * {
            box-sizing: border-box;
        }
        
        .kg-bookmark-card {
            width: 100%;
            position: relative;
        }
        
        .kg-bookmark-card a.kg-bookmark-container,
        .kg-bookmark-card a.kg-bookmark-container:hover {
            display: flex;
            background: #fff;
            text-decoration: none;
            border-radius: 6px;
            border: 1px solid rgb(124 139 154 / 25%);
            overflow: hidden;
            color: #222;
        }
        
        .kg-bookmark-content {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            flex-basis: 100%;
            align-items: flex-start;
            justify-content: flex-start;
            padding: 20px;
            overflow: hidden;
        }
        
        .kg-bookmark-title {
            font-size: 15px;
            line-height: 1.4em;
            font-weight: 600;
            color: #15171a;
        }
        
        .kg-bookmark-description {
            display: -webkit-box;
            font-size: 14px;
            line-height: 1.5em;
            margin-top: 3px;
            font-weight: 400;
            max-height: 44px;
            overflow-y: hidden;
            opacity: 0.7;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        
        .kg-bookmark-metadata {
            display: flex;
            align-items: center;
            margin-top: 22px;
            width: 100%;
            font-size: 14px;
            font-weight: 500;
            white-space: nowrap;
        }
        
        .kg-bookmark-icon {
            width: 20px;
            height: 20px;
            margin-right: 6px;
        }
        
        .kg-bookmark-author,
        .kg-bookmark-publisher {
            display: inline;
        }
        
        .kg-bookmark-author {
            font-weight: 500;
        }
        
        .kg-bookmark-publisher::before {
            content: "•";
            margin: 0 6px;
        }
        
        .kg-bookmark-thumbnail {
            position: relative;
            flex-grow: 1;
            min-width: 33%;
        }
        
        .kg-bookmark-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            border-radius: 0 4px 4px 0;
        }
    </style>
</head>
<body>
    <div class="test-container">
        <h1>Testing Bookmark Card Display</h1>
        
        <h2>1. Test Bookmark Card (with all data)</h2>
        <figure class="kg-card kg-bookmark-card">
            <a class="kg-bookmark-container" href="https://example.com/test-post">
                <div class="kg-bookmark-content">
                    <div class="kg-bookmark-title">Test Post Title</div>
                    <div class="kg-bookmark-description">This is a test description for the bookmark card to see how it displays.</div>
                    <div class="kg-bookmark-metadata">
                        <img class="kg-bookmark-icon" src="/ghost/admin/assets/images/ghost-orb.png" alt="">
                        <span class="kg-bookmark-author">Test Publisher</span>
                        <span class="kg-bookmark-publisher">Test Author</span>
                    </div>
                </div>
                <div class="kg-bookmark-thumbnail">
                    <img src="/ghost/admin/assets/images/dashboard-header.png" alt="">
                </div>
            </a>
        </figure>
        
        <h2>2. Test Saved HTML from Database</h2>
        <cfparam name="url.postId" default="">
        
        <cfif len(url.postId)>
            <cftry>
                <cfquery name="qPost" datasource="blog">
                    SELECT html FROM posts WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif qPost.recordCount>
                    <h3>Raw HTML:</h3>
                    <pre style="background: #f5f5f5; padding: 10px; overflow: auto;"><cfoutput>#htmlEditFormat(qPost.html)#</cfoutput></pre>
                    
                    <h3>Rendered HTML:</h3>
                    <div style="border: 1px solid #ddd; padding: 20px;">
                        <cfoutput>#qPost.html#</cfoutput>
                    </div>
                <cfelse>
                    <p>No post found with ID: <cfoutput>#url.postId#</cfoutput></p>
                </cfif>
                
                <cfcatch>
                    <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
                </cfcatch>
            </cftry>
        <cfelse>
            <p>Add ?postId=YOUR_POST_ID to the URL to test a specific post</p>
        </cfif>
    </div>
</body>
</html>