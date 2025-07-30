<!--- Debug post search --->
<cfoutput>
<h1>Debug: Finding Post 688a02858edd034b578322f0</h1>

<h2>1. Check if it's a MongoDB-style ObjectId that needs conversion</h2>
<cfset searchId = "688a02858edd034b578322f0">
<p>Searching for: <code>#searchId#</code></p>

<h2>2. List ALL posts with their exact IDs</h2>
<cfquery name="qAll" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        type,
        status,
        created_at,
        CHAR_LENGTH(id) as id_len,
        HEX(id) as id_hex
    FROM posts
    ORDER BY created_at DESC
</cfquery>

<p>Total posts in database: #qAll.recordCount#</p>

<h3>All Post IDs:</h3>
<table border="1" cellpadding="5" style="width: 100%;">
    <tr style="background: ##333; color: white;">
        <th>Row</th>
        <th>ID (exact)</th>
        <th>ID Length</th>
        <th>Title</th>
        <th>Type</th>
        <th>Status</th>
        <th>Created</th>
    </tr>
    <cfloop query="qAll">
        <tr <cfif id EQ searchId OR id CONTAINS "688a02858edd034b578322f0">style="background: yellow; font-weight: bold;"</cfif>>
            <td>#currentRow#</td>
            <td style="font-family: monospace; font-size: 12px;">#id#</td>
            <td>#id_len#</td>
            <td>#title#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td>#dateFormat(created_at, "mm/dd/yyyy")#</td>
        </tr>
    </cfloop>
</table>

<h2>3. Search with different methods</h2>
<cfquery name="qSearch1" datasource="blog">
    SELECT id, title FROM posts WHERE LOWER(id) = LOWER('688a02858edd034b578322f0')
</cfquery>
<p>Case-insensitive search: #qSearch1.recordCount# found</p>

<cfquery name="qSearch2" datasource="blog">
    SELECT id, title FROM posts WHERE id LIKE '%688a02858edd034b578322f0%'
</cfquery>
<p>LIKE search: #qSearch2.recordCount# found</p>

<cfquery name="qSearch3" datasource="blog">
    SELECT id, title FROM posts WHERE TRIM(id) = '688a02858edd034b578322f0'
</cfquery>
<p>TRIM search: #qSearch3.recordCount# found</p>

<h2>4. Check for similar IDs</h2>
<cfquery name="qSimilar" datasource="blog">
    SELECT id, title 
    FROM posts 
    WHERE id LIKE '688a%' 
    OR id LIKE '%688a%'
    OR id LIKE '%578322f0%'
</cfquery>
<p>Similar IDs found: #qSimilar.recordCount#</p>
<cfif qSimilar.recordCount GT 0>
    <ul>
    <cfloop query="qSimilar">
        <li>ID: <code>#id#</code> - #title#</li>
    </cfloop>
    </ul>
</cfif>

</cfoutput>