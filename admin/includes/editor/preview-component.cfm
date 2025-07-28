<!--- Shared Ghost Preview Component - Reusable preview modal functionality --->
<script>
// Ghost Preview Module
const GhostPreview = (function() {
    'use strict';
    
    // Private variables
    let currentPostId = null;
    let previewModal = null;
    let backdrop = null;
    
    // Initialize preview functionality
    function init(postId) {
        currentPostId = postId;
    }
    
    // Show preview modal
    function showModal() {
        if (!currentPostId) {
            showMessage('Post ID not found. Please save the post first.', 'error');
            return;
        }
        
        // Create modal backdrop
        backdrop = document.createElement('div');
        backdrop.className = 'preview-modal-backdrop';
        backdrop.style.cssText = `
            position: fixed;
            inset: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.6);
            z-index: 9998;
        `;
        
        // Create modal container
        previewModal = document.createElement('div');
        previewModal.id = 'previewModal';
        previewModal.className = 'ghost-preview-modal';
        previewModal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 9999;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
        `;
        
        // Create iframe for preview modal with loading state
        previewModal.innerHTML = `
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; z-index: 1;">
                <div style="width: 40px; height: 40px; border: 3px solid #f3f3f3; border-top: 3px solid #14b8ff; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
                <p style="margin-top: 10px; color: #666;">Loading preview...</p>
            </div>
            <iframe 
                src="/ghost/admin/preview-modal.cfm?id=${currentPostId}" 
                style="width: 100%; height: 100%; border: none; display: block; flex: 1; opacity: 0; transition: opacity 0.3s ease;"
                id="previewFrame"
                onload="GhostPreview.onIframeLoad(this);"
                onerror="GhostPreview.onIframeError();"
            ></iframe>
        `;
        
        // Add spinner animation
        if (!document.getElementById('previewSpinnerStyle')) {
            const style = document.createElement('style');
            style.id = 'previewSpinnerStyle';
            style.innerHTML = `
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            `;
            document.head.appendChild(style);
        }
        
        // Add to body
        document.body.appendChild(backdrop);
        document.body.appendChild(previewModal);
        
        // Prevent body scroll while modal is open
        document.body.style.overflow = 'hidden';
        
        // Listen for messages from iframe
        window.addEventListener('message', handlePreviewMessage);
    }
    
    // Handle iframe load
    function onIframeLoad(iframe) {
        iframe.style.opacity = '1';
        const loader = iframe.previousElementSibling;
        if (loader) {
            loader.style.display = 'none';
        }
    }
    
    // Handle iframe error
    function onIframeError() {
        console.error('Failed to load preview');
        showMessage('Failed to load preview', 'error');
        closeModal();
    }
    
    // Handle messages from preview iframe
    function handlePreviewMessage(event) {
        if (event.data.action === 'closePreview') {
            closeModal();
        } else if (event.data.action === 'openPublishModal') {
            closeModal();
            // Show publish modal if it exists
            const publishModal = document.getElementById('publishModal');
            if (publishModal) {
                publishModal.style.display = 'block';
            }
        }
    }
    
    // Close preview modal
    function closeModal() {
        if (previewModal) {
            previewModal.remove();
            previewModal = null;
        }
        if (backdrop) {
            backdrop.remove();
            backdrop = null;
        }
        
        // Restore body styles
        document.body.style.overflow = '';
        
        // Remove event listener
        window.removeEventListener('message', handlePreviewMessage);
    }
    
    // Public API
    return {
        init: init,
        show: showModal,
        close: closeModal,
        onIframeLoad: onIframeLoad,
        onIframeError: onIframeError
    };
})();

// Global function for backward compatibility
function showPreviewModal() {
    GhostPreview.show();
}

function closePreviewModal() {
    GhostPreview.close();
}
</script>