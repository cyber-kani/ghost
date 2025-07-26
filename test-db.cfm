<cfscript>
try {
    testQuery = queryExecute("SELECT COUNT(*) as total FROM posts WHERE status = 'published'", {}, {datasource: "blog"});
    writeOutput("Test query successful. Published posts count: " & testQuery.total);
} catch (any e) {
    writeOutput("Database error: " & e.message);
}
</cfscript>