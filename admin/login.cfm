<!--- Set permissive COOP headers for OAuth support --->
<cfheader name="Cross-Origin-Opener-Policy" value="unsafe-none">
<cfheader name="Cross-Origin-Embedder-Policy" value="unsafe-none">

<!--- Check if already logged in (use uppercase session variables) --->
<cfif structKeyExists(session, "ISLOGGEDIN") and session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/dashboard" addtoken="false">
</cfif>

<!--- Handle login form submission --->
<cfset loginError = "">
<cfif structKeyExists(form, "email") and structKeyExists(form, "password")>
    <cftry>
        <!--- Query database for user --->
        <cfquery name="userLogin" datasource="#request.dsn#">
            SELECT u.id, u.name, u.email, u.password, u.status, 
                   r.name as role_name
            FROM users u
            LEFT JOIN roles_users ru ON u.id = ru.user_id
            LEFT JOIN roles r ON ru.role_id = r.id
            WHERE u.email = <cfqueryparam value="#trim(form.email)#" cfsqltype="cf_sql_varchar">
            AND u.status = 'active'
            LIMIT 1
        </cfquery>
        
        <cfif userLogin.recordCount gt 0>
            <!--- For now, simple password check (should use hashing in production) --->
            <cfif userLogin.password eq hash(form.password, "SHA-256")>
                <!--- Set session variables (use uppercase for CFML compatibility) --->
                <cfset session.ISLOGGEDIN = true>
                <cfset session.USERID = userLogin.id>
                <cfset session.USERNAME = userLogin.name>
                <cfset session.USEREMAIL = userLogin.email>
                <cfset session.USERROLE = userLogin.role_name ?: "Author">
                
                <!--- Redirect to dashboard --->
                <cflocation url="/ghost/admin/dashboard" addtoken="false">
            <cfelse>
                <cfset loginError = "Invalid email or password">
            </cfif>
        <cfelse>
            <cfset loginError = "Invalid email or password">
        </cfif>
        
        <cfcatch>
            <cfset loginError = "An error occurred during login. Please try again.">
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html lang="en" dir="ltr" data-color-theme="Blue_Theme" class="light">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CFGhost Admin - Login</title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/ghost/admin/assets/images/logos/favicon.ico">
    <link rel="icon" type="image/svg+xml" href="/ghost/admin/assets/images/logos/favicon.svg">
    
    <!-- Core CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
    
    <!-- Tabler Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    
    <!-- Firebase -->
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
    
    <!-- Ghost Favicon -->
    <link rel="icon" type="image/svg+xml" href="/ghost/favicon.svg">
    <link rel="alternate icon" href="/ghost/favicon.ico">
</head>
<body class="DEFAULT_THEME">
    <main>
        <div class="min-h-screen bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center relative overflow-hidden">
            <!-- Multiple CFGhost Icons as Background Pattern -->
            <div class="absolute inset-0">
                <!-- Large central ghost -->
                <i class="ti ti-ghost absolute text-primary" style="top: 50%; left: 50%; transform: translate(-50%, -50%); font-size: 400px; opacity: 0.02;"></i>
                
                <!-- Top row - evenly distributed -->
                <i class="ti ti-ghost absolute text-primary" style="top: 5%; left: 10%; font-size: 80px; opacity: 0.03; transform: rotate(-20deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 10%; left: 30%; font-size: 100px; opacity: 0.02; transform: rotate(15deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 8%; left: 50%; font-size: 90px; opacity: 0.03; transform: rotate(-10deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 12%; left: 70%; font-size: 85px; opacity: 0.02; transform: rotate(25deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 6%; left: 85%; font-size: 95px; opacity: 0.03; transform: rotate(-15deg);"></i>
                
                <!-- Middle-top row -->
                <i class="ti ti-ghost absolute text-primary" style="top: 25%; left: 5%; font-size: 110px; opacity: 0.02; transform: rotate(30deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 30%; left: 25%; font-size: 75px; opacity: 0.03; transform: rotate(-25deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 28%; left: 75%; font-size: 95px; opacity: 0.02; transform: rotate(20deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 35%; left: 90%; font-size: 85px; opacity: 0.03; transform: rotate(-30deg);"></i>
                
                <!-- Middle-bottom row -->
                <i class="ti ti-ghost absolute text-primary" style="top: 65%; left: 8%; font-size: 100px; opacity: 0.03; transform: rotate(10deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 70%; left: 35%; font-size: 80px; opacity: 0.02; transform: rotate(-20deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 68%; left: 65%; font-size: 90px; opacity: 0.03; transform: rotate(15deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 72%; left: 88%; font-size: 85px; opacity: 0.02; transform: rotate(-10deg);"></i>
                
                <!-- Bottom row -->
                <i class="ti ti-ghost absolute text-primary" style="top: 85%; left: 15%; font-size: 95px; opacity: 0.02; transform: rotate(5deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 88%; left: 40%; font-size: 75px; opacity: 0.03; transform: rotate(-15deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 90%; left: 60%; font-size: 85px; opacity: 0.02; transform: rotate(25deg);"></i>
                <i class="ti ti-ghost absolute text-primary" style="top: 87%; left: 80%; font-size: 100px; opacity: 0.03; transform: rotate(-5deg);"></i>
            </div>
            
            <!-- Login Form Container -->
            <div class="relative z-10 w-full px-5" style="max-width: 500px;">
                <!-- Logo -->
                <div class="mb-8 text-center">
                    <a href="/ghost" class="flex items-center justify-center gap-2">
                        <i class="ti ti-ghost text-4xl text-primary"></i>
                        <span class="text-2xl font-bold text-dark">CFGhost Admin</span>
                    </a>
                </div>
                
                <!-- Login Card -->
                <div class="card shadow-xl bg-white/95 backdrop-blur-sm">
                    <div class="card-body p-8">
                        <h2 class="text-2xl font-bold text-center mb-2">Sign In</h2>
                        <p class="text-center text-gray-600 mb-8">Welcome back! Please login to your account.</p>
                        
                        
                        <!-- Login Form -->
                        <form method="post" action="" id="loginForm" novalidate>
                            <div class="mb-4">
                                <label for="email" class="form-label font-semibold">Email Address</label>
                                <input type="email" 
                                       id="email" 
                                       name="email" 
                                       class="form-control" 
                                       placeholder="admin@ghost.com"
                                       value="<cfif structKeyExists(form, "email")><cfoutput>#htmlEditFormat(form.email)#</cfoutput></cfif>"
                                       autofocus>
                            </div>
                            
                            <div class="mb-4">
                                <label for="password" class="form-label font-semibold">Password</label>
                                <input type="password" 
                                       id="password" 
                                       name="password" 
                                       class="form-control" 
                                       placeholder="Enter your password">
                            </div>
                            
                            <div class="flex items-center justify-between mb-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" value="" id="rememberMe">
                                    <label class="form-check-label text-sm" for="rememberMe">
                                        Remember me
                                    </label>
                                </div>
                                <a href="#" class="text-sm text-primary hover:text-primaryhover">Forgot Password?</a>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-full py-3 mb-4">
                                <i class="ti ti-login me-2"></i>
                                Sign In
                            </button>
                            
                            <!-- Divider -->
                            <div class="relative my-6">
                                <div class="absolute inset-0 flex items-center">
                                    <div class="w-full border-t border-gray-300"></div>
                                </div>
                                <div class="relative flex justify-center text-sm">
                                    <span class="bg-white px-4 text-gray-500">Or continue with</span>
                                </div>
                            </div>
                            
                            <!-- Firebase Authentication -->
                            <button type="button" id="googleSignInBtn" class="btn btn-outline-secondary w-full py-3 flex items-center justify-center gap-2">
                                <svg class="w-5 h-5" viewBox="0 0 24 24">
                                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                                </svg>
                                <span>Sign in with Google</span>
                            </button>
                            
                            <div class="text-center mt-4">
                                <p class="text-sm text-gray-600">
                                    Don't have an account? 
                                    <a href="#" class="text-primary hover:text-primaryhover font-medium">Sign Up</a>
                                </p>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Footer -->
                <div class="mt-8 text-center text-gray-600">
                    <p class="text-sm font-medium mb-2">A powerful, modern content management system built with CFML.</p>
                    <p class="text-xs text-gray-500 mb-3">Create, manage, and publish your content with ease.</p>
                    <p class="text-xs">&copy; <cfoutput>#year(now())#</cfoutput> CFGhost CMS. All rights reserved.</p>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Core JS -->
    <script>
    // Show message function for consistent notifications
    function showMessage(message, type) {
        // Remove any existing messages
        const existingMessage = document.querySelector('.alert-message');
        if (existingMessage) {
            existingMessage.remove();
        }
        
        // Create message element
        const messageEl = document.createElement('div');
        messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
        messageEl.style.animation = 'slideInRight 0.3s ease-out';
        
        if (type === 'success') {
            messageEl.className += ' bg-success text-white';
            messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
        } else if (type === 'error') {
            messageEl.className += ' bg-lighterror text-error';
            messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
        } else if (type === 'warning') {
            messageEl.className += ' bg-warning text-white';
            messageEl.innerHTML = `<i class="ti ti-alert-triangle me-2"></i>${message}`;
        } else {
            messageEl.className += ' bg-primary text-white';
            messageEl.innerHTML = `<i class="ti ti-info-circle me-2"></i>${message}`;
        }
        
        // Add to page
        document.body.appendChild(messageEl);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            messageEl.style.animation = 'slideOutRight 0.3s ease-in';
            setTimeout(() => {
                messageEl.remove();
            }, 300);
        }, 5000);
    }
    
    // CSS for animations and form styling
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
        
        /* Form field focus styles */
        #loginForm .form-control {
            transition: all 0.3s ease;
            border: 1px solid #e5e7eb;
        }
        
        #loginForm .form-control:focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
            outline: none;
            background-color: #fafbff;
        }
        
        #loginForm .form-control:hover:not(:focus) {
            border-color: #d1d5db;
        }
        
        /* Error state */
        #loginForm .form-control.border-red-500 {
            border-color: #ef4444;
        }
        
        #loginForm .form-control.border-red-500:focus {
            border-color: #ef4444;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
        }
        
        /* Red placeholder for errors */
        #loginForm .form-control.placeholder-red-500::placeholder {
            color: #ef4444;
            opacity: 1;
        }
    `;
    document.head.appendChild(style);
    
    // Show login error if exists
    <cfif len(loginError) gt 0>
        showMessage('<cfoutput>#jsStringFormat(loginError)#</cfoutput>', 'error');
    </cfif>
    
    // Store original placeholders
    const emailField = document.getElementById('email');
    const passwordField = document.getElementById('password');
    const originalEmailPlaceholder = emailField.placeholder;
    const originalPasswordPlaceholder = passwordField.placeholder;
    
    // Custom form validation
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        let isValid = true;
        
        // Reset validation states
        emailField.classList.remove('border-red-500', 'placeholder-red-500');
        passwordField.classList.remove('border-red-500', 'placeholder-red-500');
        emailField.placeholder = originalEmailPlaceholder;
        passwordField.placeholder = originalPasswordPlaceholder;
        
        // Validate email
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailField.value.trim()) {
            emailField.value = '';
            emailField.classList.add('border-red-500', 'placeholder-red-500');
            emailField.placeholder = 'Email address is required';
            isValid = false;
        } else if (!emailPattern.test(emailField.value)) {
            emailField.classList.add('border-red-500', 'placeholder-red-500');
            isValid = false;
            showMessage('Please enter a valid email address', 'error');
        }
        
        // Validate password
        if (!passwordField.value) {
            passwordField.classList.add('border-red-500', 'placeholder-red-500');
            passwordField.placeholder = 'Password is required';
            isValid = false;
        }
        
        // Submit if valid
        if (isValid) {
            this.submit();
        }
    });
    
    // Remove error styling on input and restore placeholder
    emailField.addEventListener('input', function() {
        this.classList.remove('border-red-500', 'placeholder-red-500');
        if (this.placeholder === 'Email address is required') {
            this.placeholder = originalEmailPlaceholder;
        }
    });
    
    passwordField.addEventListener('input', function() {
        this.classList.remove('border-red-500', 'placeholder-red-500');
        if (this.placeholder === 'Password is required') {
            this.placeholder = originalPasswordPlaceholder;
        }
    });
    
    // Initialize Firebase
    const firebaseConfig = {
        apiKey: "AIzaSyABV0iFplCmRA4_b5Q99uZlQaSy3Kj2qhM",
        authDomain: "cloudcoder-a6b46.firebaseapp.com",
        projectId: "cloudcoder-a6b46",
        storageBucket: "cloudcoder-a6b46.firebasestorage.app",
        messagingSenderId: "87318352378",
        appId: "1:87318352378:web:91f4f99b5a191f091a1443",
        measurementId: "G-N79DL8VZTN"
    };
    
    // Initialize Firebase only if config is set
    if (firebaseConfig.apiKey !== "YOUR_FIREBASE_API_KEY") {
        firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        
        // Check for redirect result on page load
        auth.getRedirectResult()
            .then((result) => {
                if (result.user) {
                    // Get user info
                    const user = result.user;
                    showMessage('Processing sign-in...', 'info');
                    
                    // Log user data for debugging
                    console.log('Firebase user data:', {
                        email: user.email,
                        name: user.displayName,
                        uid: user.uid,
                        photoURL: user.photoURL
                    });
                    
                    // Send to server for verification
                    fetch('/ghost/admin/ajax/firebase-login.cfm', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'email=' + encodeURIComponent(user.email) + 
                              '&name=' + encodeURIComponent(user.displayName || '') +
                              '&uid=' + encodeURIComponent(user.uid) +
                              '&photoURL=' + encodeURIComponent(user.photoURL || '')
                    })
                    .then(response => {
                        console.log('Server response status:', response.status);
                        if (!response.ok) {
                            throw new Error(`HTTP error! status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log('Server response data:', data);
                        if (data.success) {
                            showMessage('Login successful! Redirecting...', 'success');
                            setTimeout(() => {
                                window.location.href = '/ghost/admin/dashboard';
                            }, 1000);
                        } else {
                            showMessage(data.message || 'Google sign-in failed', 'error');
                            // Sign out from Firebase
                            auth.signOut();
                        }
                    })
                    .catch(error => {
                        showMessage('An error occurred during sign-in', 'error');
                        console.error('Server error details:', error);
                        auth.signOut();
                    });
                }
            })
            .catch((error) => {
                if (error.code) {
                    // Log full error for debugging
                    console.error('Firebase redirect error:', {
                        code: error.code,
                        message: error.message
                    });
                    
                    // Show user-friendly error messages
                    let errorMessage = 'Google sign-in failed';
                    switch(error.code) {
                        case 'auth/unauthorized-domain':
                            errorMessage = 'This domain is not authorized. Please contact administrator.';
                            break;
                        case 'auth/network-request-failed':
                            errorMessage = 'Network error. Please check your connection.';
                            break;
                        case 'auth/invalid-api-key':
                            errorMessage = 'Invalid configuration. Please contact administrator.';
                            break;
                        default:
                            if (error.message) {
                                errorMessage = error.message;
                            }
                    }
                    
                    showMessage(errorMessage, 'error');
                }
            });
        
        // Google Sign-In Handler
        document.getElementById('googleSignInBtn').addEventListener('click', function() {
            const provider = new firebase.auth.GoogleAuthProvider();
            
            // Use popup - COOP warnings can be ignored
            auth.signInWithPopup(provider)
                .then((result) => {
                    // Get user info
                    const user = result.user;
                    showMessage('Processing sign-in...', 'info');
                    
                    // Log user data for debugging
                    console.log('Firebase user authenticated:', {
                        email: user.email,
                        name: user.displayName,
                        uid: user.uid,
                        photoURL: user.photoURL
                    });
                    
                    // Send to server for verification
                    fetch('/ghost/admin/ajax/firebase-login.cfm', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'email=' + encodeURIComponent(user.email) + 
                              '&name=' + encodeURIComponent(user.displayName || '') +
                              '&uid=' + encodeURIComponent(user.uid) +
                              '&photoURL=' + encodeURIComponent(user.photoURL || '')
                    })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log('Server response:', data);
                        // Check both lowercase and uppercase keys (CFML returns uppercase)
                        if (data.success || data.SUCCESS) {
                            showMessage('Login successful! Redirecting...', 'success');
                            window.location.href = '/ghost/admin/dashboard';
                        } else {
                            showMessage(data.message || data.MESSAGE || 'Google sign-in failed', 'error');
                            auth.signOut();
                        }
                    })
                    .catch(error => {
                        showMessage('Server error during sign-in', 'error');
                        console.error('Server error:', error);
                        auth.signOut();
                    });
                })
                .catch((error) => {
                    // Handle popup errors
                    if (error.code === 'auth/popup-closed-by-user') {
                        // User closed the popup - no error message needed
                        return;
                    }
                    
                    console.error('Firebase Auth Error:', error);
                    
                    // Show user-friendly error messages
                    let errorMessage = 'Sign-in failed';
                    switch(error.code) {
                        case 'auth/popup-blocked':
                            errorMessage = 'Popup was blocked. Please allow popups for this site.';
                            break;
                        case 'auth/unauthorized-domain':
                            errorMessage = 'This domain is not authorized. Please contact administrator.';
                            break;
                        case 'auth/network-request-failed':
                            errorMessage = 'Network error. Please check your connection.';
                            break;
                        default:
                            errorMessage = error.message || 'An error occurred during sign-in';
                    }
                    
                    showMessage(errorMessage, 'error');
                });
        });
    } else {
        // Firebase not configured, disable button
        document.getElementById('googleSignInBtn').disabled = true;
        document.getElementById('googleSignInBtn').innerHTML = `
            <svg class="w-5 h-5" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            <span class="text-gray-500">Firebase Not Configured</span>
        `;
    }
    </script>
</body>
</html>