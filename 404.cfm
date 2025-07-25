<!--- 404 Error Page --->
<cfparam name="pageTitle" default="Page Not Found">

<cfinclude template="admin/includes/header.cfm">

<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- 404 Error Card -->
        <div class="card shadow-none">
            <div class="card-body p-6">
                <div class="text-center py-16">
                    
                    <!-- Error Icon -->
                    <div class="d-flex justify-content-center mb-4">
                        <i class="ti ti-error-404 display-1 text-bodytext"></i>
                    </div>
                    
                    <!-- Error Message -->
                    <h1 class="font-semibold text-4xl text-dark dark:text-white mb-3">404</h1>
                    <h4 class="font-semibold text-xl text-dark dark:text-white mb-3">Page Not Found</h4>
                    
                    <p class="text-bodytext mb-6 max-w-md mx-auto">
                        The page you're looking for doesn't exist or has been moved.
                    </p>
                    
                    <!-- Action Buttons -->
                    <div class="flex gap-3 justify-center">
                        <a href="/ghost/admin/" class="btn btn-primary">
                            <i class="ti ti-home me-2"></i>Go to Dashboard
                        </a>
                        <button onclick="history.back()" class="btn btn-outline-secondary">
                            <i class="ti ti-arrow-left me-2"></i>Go Back
                        </button>
                    </div>
                    
                </div>
            </div>
        </div>
        
    </div>
</div>

<cfinclude template="admin/includes/footer.cfm">