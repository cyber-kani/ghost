<!DOCTYPE html>
<html>
<head>
    <title>Test Content Extraction</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .test-case { margin: 20px 0; padding: 15px; background: #f5f5f5; border-radius: 5px; }
        .result { margin: 10px 0; padding: 10px; background: white; border: 1px solid #ddd; }
        .pass { color: green; }
        .fail { color: red; }
    </style>
</head>
<body>
    <h1>Test Content Extraction</h1>
    
    <cfscript>
    // Test cases
    testCases = [
        {
            name: "Simple paragraph",
            html: "<p>This is a simple paragraph with more than two words that should be extracted correctly.</p>",
            expected: "This is a simple paragraph with more than two words that should be extracted correctly."
        },
        {
            name: "Multiple paragraphs",
            html: "<p>First paragraph content.</p><p>Second paragraph content.</p>",
            expected: "First paragraph content."
        },
        {
            name: "Paragraph with formatting",
            html: "<p>This is <strong>bold</strong> and <em>italic</em> text.</p>",
            expected: "This is bold and italic text."
        },
        {
            name: "Paragraph with HTML entities",
            html: "<p>This has &amp; special &lt;characters&gt; and &quot;quotes&quot;.</p>",
            expected: "This has & special <characters> and ""quotes""."
        },
        {
            name: "Empty paragraph",
            html: "<p></p><p>Second paragraph with content.</p>",
            expected: "Second paragraph with content."
        },
        {
            name: "No paragraphs",
            html: "<h1>Just a heading</h1>",
            expected: ""
        },
        {
            name: "Nested HTML",
            html: "<p>This has a <a href='#'>link</a> in it.</p>",
            expected: "This has a link in it."
        }
    ];
    
    // Test extraction function
    function extractFirstParagraph(html) {
        var firstP = reMatch("<p[^>]*>(.*?)</p>", html);
        if (arrayLen(firstP) gt 0) {
            var text = reReplace(firstP[1], "<[^>]*>", "", "all");
            text = replace(text, "&nbsp;", " ", "all");
            text = replace(text, "&amp;", "&", "all");
            text = replace(text, "&lt;", "<", "all");
            text = replace(text, "&gt;", ">", "all");
            text = replace(text, "&quot;", '"', "all");
            return trim(text);
        }
        return "";
    }
    </cfscript>
    
    <cfloop array="#testCases#" index="test">
        <div class="test-case">
            <h3>#test.name#</h3>
            <p><strong>HTML:</strong> <code>#htmlEditFormat(test.html)#</code></p>
            <cfset result = extractFirstParagraph(test.html)>
            <p><strong>Expected:</strong> "#test.expected#"</p>
            <p><strong>Result:</strong> "#result#"</p>
            <p class="#result eq test.expected ? 'pass' : 'fail'#">
                <cfif result eq test.expected>
                    ✓ PASS
                <cfelse>
                    ✗ FAIL
                </cfif>
            </p>
        </div>
    </cfloop>
    
    <h2>Test with actual post content</h2>
    <cfset postId = "37b324a31d94b8b96b62d2de">
    <cftry>
        <cfquery name="getPost" datasource="#request.dsn#">
            SELECT html FROM posts WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif getPost.recordCount>
            <div class="test-case">
                <h3>Post: #postId#</h3>
                <cfset firstPara = extractFirstParagraph(getPost.html)>
                <p><strong>First paragraph extracted:</strong></p>
                <div class="result">"#firstPara#"</div>
                <p><strong>Length:</strong> #len(firstPara)# characters</p>
                <p><strong>Facebook preview (160 chars):</strong> "#left(firstPara, 160)#"</p>
                <p><strong>Twitter preview (125 chars):</strong> "#left(firstPara, 125)#"</p>
            </div>
        <cfelse>
            <p>Post not found</p>
        </cfif>
        
        <cfcatch>
            <p>Error accessing database: #cfcatch.message#</p>
        </cfcatch>
    </cftry>
</body>
</html>