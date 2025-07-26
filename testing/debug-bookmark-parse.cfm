<!DOCTYPE html>
<html>
<head>
    <title>Debug Bookmark Parse</title>
</head>
<body>
    <h1>Debug Bookmark Card Parsing</h1>
    
    <cfparam name="url.postId" default="">
    
    <cfif len(url.postId)>
        <cftry>
            <cfquery name="qPost" datasource="blog">
                SELECT id, title, html, plaintext FROM posts WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qPost.recordCount>
                <h2>Post: <cfoutput>#qPost.title#</cfoutput></h2>
                
                <h3>Raw HTML from Database:</h3>
                <pre style="background: #f5f5f5; padding: 10px; overflow: auto; max-height: 300px;"><cfoutput>#htmlEditFormat(qPost.html)#</cfoutput></pre>
                
                <h3>Look for Bookmark Cards:</h3>
                <cfset bookmarkPattern = '<figure class="kg-card kg-bookmark-card">'>
                <cfif qPost.html contains bookmarkPattern>
                    <p style="color: green;">✓ Found bookmark card in HTML</p>
                    
                    <!--- Extract bookmark cards --->
                    <cfset startPos = 1>
                    <cfset cardNum = 0>
                    <cfloop condition="true">
                        <cfset startTag = find('<figure class="kg-card kg-bookmark-card">', qPost.html, startPos)>
                        <cfif startTag eq 0>
                            <cfbreak>
                        </cfif>
                        <cfset endTag = find('</figure>', qPost.html, startTag)>
                        <cfif endTag gt 0>
                            <cfset cardNum++>
                            <cfset bookmarkHtml = mid(qPost.html, startTag, endTag - startTag + 9)>
                            <h4>Bookmark Card #<cfoutput>#cardNum#</cfoutput>:</h4>
                            <pre style="background: #e8f5e9; padding: 10px; overflow: auto;"><cfoutput>#htmlEditFormat(bookmarkHtml)#</cfoutput></pre>
                            
                            <!--- Extract data --->
                            <cfset linkMatch = reFind('href="([^"]+)"', bookmarkHtml, 1, true)>
                            <cfset titleMatch = reFind('<div class="kg-bookmark-title">([^<]+)</div>', bookmarkHtml, 1, true)>
                            <cfset descMatch = reFind('<div class="kg-bookmark-description">([^<]+)</div>', bookmarkHtml, 1, true)>
                            
                            <h5>Extracted Data:</h5>
                            <ul>
                                <cfif linkMatch.len[1] gt 0>
                                    <li>URL: <cfoutput>#mid(bookmarkHtml, linkMatch.pos[2], linkMatch.len[2])#</cfoutput></li>
                                </cfif>
                                <cfif titleMatch.len[1] gt 0>
                                    <li>Title: <cfoutput>#mid(bookmarkHtml, titleMatch.pos[2], titleMatch.len[2])#</cfoutput></li>
                                </cfif>
                                <cfif descMatch.len[1] gt 0>
                                    <li>Description: <cfoutput>#mid(bookmarkHtml, descMatch.pos[2], descMatch.len[2])#</cfoutput></li>
                                </cfif>
                            </ul>
                            
                            <cfset startPos = endTag + 1>
                        <cfelse>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                <cfelse>
                    <p style="color: red;">✗ No bookmark card found in HTML</p>
                </cfif>
                
                <h3>Test JavaScript Parsing:</h3>
                <div id="testContainer" style="display: none;"><cfoutput>#qPost.html#</cfoutput></div>
                
                <script>
                    // Test how the parser would see it
                    const container = document.getElementById('testContainer');
                    const figures = container.querySelectorAll('figure');
                    console.log('Total figures found:', figures.length);
                    
                    figures.forEach((fig, index) => {
                        console.log(`Figure ${index + 1} classes:`, fig.className);
                        if (fig.classList.contains('kg-bookmark-card')) {
                            console.log('Found bookmark card!');
                            const link = fig.querySelector('.kg-bookmark-container');
                            const title = fig.querySelector('.kg-bookmark-title');
                            const desc = fig.querySelector('.kg-bookmark-description');
                            console.log('Bookmark data:', {
                                url: link?.href,
                                title: title?.textContent,
                                description: desc?.textContent
                            });
                        }
                    });
                </script>
                
                <p>Check browser console for JavaScript parsing results</p>
                
            <cfelse>
                <p>No post found with ID: <cfoutput>#url.postId#</cfoutput></p>
            </cfif>
            
            <cfcatch>
                <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
                <pre><cfoutput>#cfcatch.detail#</cfoutput></pre>
            </cfcatch>
        </cftry>
    <cfelse>
        <p>Usage: Add ?postId=YOUR_POST_ID to the URL</p>
    </cfif>
    
    <hr>
    
    <h2>Test Creating and Parsing a Bookmark:</h2>
    <button onclick="testBookmarkCreation()">Test Bookmark Creation</button>
    <div id="testResult"></div>
    
    <script>
    function testBookmarkCreation() {
        // Simulate what happens when saving
        const bookmarkHtml = `<figure class="kg-card kg-bookmark-card"><a class="kg-bookmark-container" href="https://clitools.app/ghost/test-post"><div class="kg-bookmark-content"><div class="kg-bookmark-title">Test Post Title</div><div class="kg-bookmark-description">Test description</div><div class="kg-bookmark-metadata"><span class="kg-bookmark-author">clitools.app</span></div></div></a></figure>`;
        
        console.log('Original HTML:', bookmarkHtml);
        
        // Parse it back
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = bookmarkHtml;
        
        const bookmarkCard = tempDiv.querySelector('.kg-bookmark-card');
        console.log('Parsed bookmark card:', bookmarkCard);
        
        if (bookmarkCard) {
            const data = {
                found: true,
                url: bookmarkCard.querySelector('.kg-bookmark-container')?.href,
                title: bookmarkCard.querySelector('.kg-bookmark-title')?.textContent,
                description: bookmarkCard.querySelector('.kg-bookmark-description')?.textContent,
                author: bookmarkCard.querySelector('.kg-bookmark-author')?.textContent,
                publisher: bookmarkCard.querySelector('.kg-bookmark-publisher')?.textContent
            };
            
            document.getElementById('testResult').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
    }
    </script>
</body>
</html>