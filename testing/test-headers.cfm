<!--- Test page to set COOP headers from CFML --->
<cfheader name="Cross-Origin-Opener-Policy" value="same-origin-allow-popups">
<cfheader name="Cross-Origin-Embedder-Policy" value="unsafe-none">

<!DOCTYPE html>
<html>
<head>
    <title>COOP Headers Test</title>
</head>
<body>
    <h1>COOP Headers Test Page</h1>
    <p>This page sets COOP headers via CFML.</p>
    <p>Check browser developer tools Network tab to see headers.</p>
    
    <script>
        // Test if we can open a popup
        function testPopup() {
            try {
                const popup = window.open('https://www.google.com', 'test', 'width=500,height=500');
                setTimeout(() => {
                    if (popup && !popup.closed) {
                        popup.close();
                        alert('Popup test successful!');
                    }
                }, 2000);
            } catch (e) {
                alert('Popup error: ' + e.message);
            }
        }
    </script>
    
    <button onclick="testPopup()">Test Popup</button>
    
    <p><a href="/ghost/admin/login">Back to Login</a></p>
</body>
</html>