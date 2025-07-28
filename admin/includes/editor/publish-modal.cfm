<!--- Ghost Publish Modal Functions - Extracted from editor-scripts.cfm --->
<script>
(function() {
    // Show publish modal
    function showPublishModal() {
        console.log('showPublishModal called');
        const backdrop = document.createElement('div');
        backdrop.className = 'gh-publish-modal';
        backdrop.id = 'publishModalBackdrop';
        
        const modalInner = document.createElement('div');
        modalInner.className = 'gh-publish-modal-inner';
        
        const modalContainer = document.createElement('div');
        modalContainer.className = 'flex flex-column h-100';
        
        modalContainer.innerHTML = `
            <header class="gh-publish-header">
                <h2>Publish</h2>
                <div class="gh-btn-group-right">
                    <button type="button" class="btn btn-outline-secondary" onclick="closePublishModal()">
                        <i class="ti ti-x me-2"></i>
                        Close
                    </button>
                    <button type="button" class="btn btn-outline-secondary" onclick="previewPost()">
                        <i class="ti ti-eye me-2"></i>
                        Preview
                    </button>
                </div>
            </header>
            
            <div class="gh-publish-settings-container fade-in">
                <div class="gh-publish-title">
                    <div class="green">Ready, set, publish.</div>
                    <div>Share it with the world.</div>
                </div>
                <div class="gh-publish-settings">
                    <!-- Publish Type Setting -->
                    <div class="gh-publish-setting">
                        <button class="gh-publish-setting-title" onclick="togglePublishType()">
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M14.4 1.6H1.6C0.72 1.6 0 2.32 0 3.2V12C0 12.88 0.72 13.6 1.6 13.6H14.4C15.28 13.6 16 12.88 16 12V3.2C16 2.32 15.28 1.6 14.4 1.6ZM14.4 3.2L8 7.2L1.6 3.2H14.4ZM14.4 12H1.6V4.8L8 8.8L14.4 4.8V12Z" fill="currentColor"/>
                            </svg>
                            <div class="gh-publish-setting-trigger">
                                <span id="publishTypeDisplay">Publish and email</span>
                            </div>
                            <span id="publishTypeArrow">
                                <svg width="12" height="8" viewBox="0 0 12 8" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-expand">
                                    <path d="M1.41 0L6 4.58L10.59 0L12 1.41L6 7.41L0 1.41L1.41 0Z" fill="currentColor"/>
                                </svg>
                            </span>
                        </button>
                        <div id="publishTypeOptions" class="gh-publish-setting-form hidden">
                            <fieldset class="gh-publish-types">
                                <span>
                                    <input type="radio" name="publishType" id="publish-type-publish+send" class="gh-radio-button" value="publish+send" checked onchange="updatePublishOptions()">
                                    <label for="publish-type-publish+send">Publish and email</label>
                                </span>
                                <span>
                                    <input type="radio" name="publishType" id="publish-type-publish" class="gh-radio-button" value="publish" onchange="updatePublishOptions()">
                                    <label for="publish-type-publish">Publish only</label>
                                </span>
                                <span>
                                    <input type="radio" name="publishType" id="publish-type-send" class="gh-radio-button" value="send" onchange="updatePublishOptions()">
                                    <label for="publish-type-send">Email only</label>
                                </span>
                            </fieldset>
                        </div>
                    </div>
                    
                    <!-- Email Recipients Setting -->
                    <div class="gh-publish-setting" id="emailRecipientsSection">
                        <button class="gh-publish-setting-title" onclick="toggleEmailRecipients()">
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M8 0C3.6 0 0 3.6 0 8C0 12.4 3.6 16 8 16C12.4 16 16 12.4 16 8C16 3.6 12.4 0 8 0ZM8 2.4C9.76 2.4 11.2 3.84 11.2 5.6C11.2 7.36 9.76 8.8 8 8.8C6.24 8.8 4.8 7.36 4.8 5.6C4.8 3.84 6.24 2.4 8 2.4ZM8 13.76C6 13.76 4.24 12.72 3.2 11.12C3.2 9.6 6.4 8.72 8 8.72C9.6 8.72 12.8 9.6 12.8 11.12C11.76 12.72 10 13.76 8 13.76Z" fill="currentColor"/>
                            </svg>
                            <div class="gh-publish-setting-trigger">
                                <span id="emailRecipientsDisplay">All subscribers</span>
                            </div>
                            <span id="emailRecipientsArrow">
                                <svg width="12" height="8" viewBox="0 0 12 8" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-expand">
                                    <path d="M1.41 0L6 4.58L10.59 0L12 1.41L6 7.41L0 1.41L1.41 0Z" fill="currentColor"/>
                                </svg>
                            </span>
                        </button>
                        <div id="emailRecipientsOptions" class="gh-publish-setting-form hidden">
                            <fieldset class="gh-publish-send-to">
                                <div class="gh-publish-send-to-option">
                                    <label class="for-checkbox">
                                        <input type="checkbox" id="send-to-free" checked onchange="updatePublishOptions()">
                                        <div class="flex">
                                            <span class="input-toggle-component"></span>
                                            <p>Free subscribers</p>
                                        </div>
                                    </label>
                                </div>
                                <div class="gh-publish-send-to-option">
                                    <label class="for-checkbox">
                                        <input type="checkbox" id="send-to-paid" checked onchange="updatePublishOptions()">
                                        <div class="flex">
                                            <span class="input-toggle-component"></span>
                                            <p>Paid subscribers</p>
                                        </div>
                                    </label>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                    
                    <!-- Schedule Setting -->
                    <div class="gh-publish-setting last">
                        <button class="gh-publish-setting-title" onclick="toggleScheduleOptions()">
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M8 0C3.584 0 0 3.584 0 8C0 12.416 3.584 16 8 16C12.416 16 16 12.416 16 8C16 3.584 12.416 0 8 0ZM8 14.4C4.472 14.4 1.6 11.528 1.6 8C1.6 4.472 4.472 1.6 8 1.6C11.528 1.6 14.4 4.472 14.4 8C14.4 11.528 11.528 14.4 8 14.4ZM8.4 4H7.2V8.8L11.2 11.12L11.8 10.08L8.4 8.2V4Z" fill="currentColor"/>
                            </svg>
                            <div class="gh-publish-setting-trigger">
                                <span id="scheduleDisplay">Right now</span>
                            </div>
                            <span id="scheduleArrow">
                                <svg width="12" height="8" viewBox="0 0 12 8" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-expand">
                                    <path d="M1.41 0L6 4.58L10.59 0L12 1.41L6 7.41L0 1.41L1.41 0Z" fill="currentColor"/>
                                </svg>
                            </span>
                        </button>
                        <div id="scheduleOptions" class="gh-publish-setting-form hidden">
                            <fieldset class="gh-publish-schedule">
                                <span class="gh-radio">
                                    <input type="radio" name="schedule" id="schedule-now" class="gh-radio-button" value="now" checked onchange="updatePublishOptions()">
                                    <label for="schedule-now">Right now</label>
                                </span>
                                <span class="gh-radio">
                                    <input type="radio" name="schedule" id="schedule-later" class="gh-radio-button" value="later" onchange="updatePublishOptions()">
                                    <label for="schedule-later">Schedule for later</label>
                                </span>
                            </fieldset>
                            <div id="scheduleDateTimeSection" class="gh-date-time-picker hidden">
                                <input type="date" id="scheduleDate" class="gh-date-time-picker-date" onchange="updatePublishButtonText()">
                                <input type="time" id="scheduleTime" class="gh-date-time-picker-time" onchange="updatePublishButtonText()">
                                <div id="scheduleError" class="gh-date-time-picker-error hidden"></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="gh-publish-cta">
                    <button type="button" class="btn btn-success btn-lg" onclick="continueToConfirm()">
                        <i class="ti ti-send me-2"></i>
                        <span>Publish post, right now</span>
                    </button>
                </div>
            </div>
        `;
        
        modalInner.appendChild(modalContainer);
        backdrop.appendChild(modalInner);
        document.body.appendChild(backdrop);
        console.log('Publish modal added to DOM');
        console.log('Modal classes:', backdrop.className, modalInner.className);
        
        // Click outside to close
        backdrop.addEventListener('click', function(e) {
            if (e.target === backdrop) {
                closePublishModal();
            }
        });
        
        // Update button text based on publish type and schedule
        updatePublishButtonText();
    }
    
    // Close publish modal
    function closePublishModal() {
        const backdrop = document.getElementById('publishModalBackdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    
    // Toggle publish type dropdown
    function togglePublishType() {
        console.log('togglePublishType called');
        const options = document.getElementById('publishTypeOptions');
        const button = options.previousElementSibling;
        options.classList.toggle('hidden');
        button.classList.toggle('expanded');
        console.log('Options hidden:', options.classList.contains('hidden'));
    }
    
    // Toggle email recipients dropdown
    function toggleEmailRecipients() {
        const options = document.getElementById('emailRecipientsOptions');
        const button = options.previousElementSibling;
        options.classList.toggle('hidden');
        button.classList.toggle('expanded');
    }
    
    // Toggle schedule options dropdown
    function toggleScheduleOptions() {
        const options = document.getElementById('scheduleOptions');
        const button = options.previousElementSibling;
        options.classList.toggle('hidden');
        button.classList.toggle('expanded');
    }
    
    // Update publish options based on selections
    function updatePublishOptions() {
        const publishType = document.querySelector('input[name="publishType"]:checked').value;
        const schedule = document.querySelector('input[name="schedule"]:checked').value;
        
        // Show/hide email recipients based on publish type
        const emailSection = document.getElementById('emailRecipientsSection');
        if (publishType === 'publish') {
            emailSection.style.display = 'none';
        } else {
            emailSection.style.display = 'block';
        }
        
        // Show/hide date time picker based on schedule
        const dateTimeSection = document.getElementById('scheduleDateTimeSection');
        if (schedule === 'later') {
            dateTimeSection.classList.remove('hidden');
            // Set default time to 5 minutes from now
            const now = new Date();
            now.setMinutes(now.getMinutes() + 5);
            
            // Set min date to today
            const dateInput = document.getElementById('scheduleDate');
            dateInput.min = new Date().toISOString().split('T')[0];
            dateInput.value = now.toISOString().split('T')[0];
            
            document.getElementById('scheduleTime').value = now.toTimeString().slice(0,5);
            
            // Trigger button text update
            updatePublishButtonText();
        } else {
            dateTimeSection.classList.add('hidden');
        }
        
        // Update display text
        const publishTypeDisplay = document.getElementById('publishTypeDisplay');
        switch(publishType) {
            case 'publish+send':
                publishTypeDisplay.textContent = 'Publish and email';
                break;
            case 'publish':
                publishTypeDisplay.textContent = 'Publish only';
                break;
            case 'send':
                publishTypeDisplay.textContent = 'Email only';
                break;
        }
        
        const scheduleDisplay = document.getElementById('scheduleDisplay');
        if (schedule === 'later') {
            scheduleDisplay.textContent = 'Schedule for later';
        } else {
            scheduleDisplay.textContent = 'Right now';
        }
        
        // Update button text based on publish type and schedule
        updatePublishButtonText();
    }
    
    // Update publish button text
    function updatePublishButtonText() {
        const publishType = document.querySelector('input[name="publishType"]:checked')?.value || 'publish+send';
        const schedule = document.querySelector('input[name="schedule"]:checked')?.value || 'now';
        
        const continueBtn = document.querySelector('.gh-publish-cta button');
        if (!continueBtn) return;
        
        let buttonText = 'Publish post, right now';
        let iconClass = 'ti-send';
        
        if (schedule === 'later') {
            iconClass = 'ti-clock';
            const scheduleDate = document.getElementById('scheduleDate')?.value;
            const scheduleTime = document.getElementById('scheduleTime')?.value;
            
            if (scheduleDate && scheduleTime) {
                const scheduledDateTime = new Date(`${scheduleDate}T${scheduleTime}`);
                const formattedDate = scheduledDateTime.toLocaleDateString('en-US', { 
                    month: 'short', 
                    day: 'numeric',
                    year: scheduledDateTime.getFullYear() !== new Date().getFullYear() ? 'numeric' : undefined
                });
                const formattedTime = scheduledDateTime.toLocaleTimeString('en-US', { 
                    hour: 'numeric', 
                    minute: '2-digit',
                    hour12: true 
                });
                buttonText = `Schedule for ${formattedDate} at ${formattedTime}`;
            } else {
                buttonText = 'Schedule post';
            }
        }
        
        // Update button text
        const buttonSpan = continueBtn.querySelector('span');
        if (buttonSpan) {
            buttonSpan.textContent = buttonText;
        }
        
        // Update button icon
        const buttonIcon = continueBtn.querySelector('i');
        if (buttonIcon) {
            buttonIcon.className = `ti ${iconClass} me-2`;
        }
    }
    
    // Continue to confirmation
    function continueToConfirm() {
        const publishType = document.querySelector('input[name="publishType"]:checked').value;
        const schedule = document.querySelector('input[name="schedule"]:checked').value;
        
        // Validate schedule if needed
        if (schedule === 'later') {
            const scheduleDate = document.getElementById('scheduleDate').value;
            const scheduleTime = document.getElementById('scheduleTime').value;
            
            if (!scheduleDate || !scheduleTime) {
                const errorDiv = document.getElementById('scheduleError');
                errorDiv.textContent = 'Please select both date and time';
                errorDiv.classList.remove('hidden');
                return;
            }
            
            const scheduledDateTime = new Date(`${scheduleDate}T${scheduleTime}`);
            const now = new Date();
            
            if (scheduledDateTime <= now) {
                const errorDiv = document.getElementById('scheduleError');
                errorDiv.textContent = 'Schedule time must be in the future';
                errorDiv.classList.remove('hidden');
                return;
            }
        }
        
        // For now, just execute the publish
        executePublishWithOptions();
    }
    
    // Execute publish with options
    function executePublishWithOptions() {
        const publishType = document.querySelector('input[name="publishType"]:checked').value;
        const schedule = document.querySelector('input[name="schedule"]:checked').value;
        
        let publishData = {
            publishType: publishType,
            sendEmail: publishType !== 'publish',
            emailRecipients: 'all'
        };
        
        if (publishType !== 'publish') {
            const sendToFree = document.getElementById('send-to-free').checked;
            const sendToPaid = document.getElementById('send-to-paid').checked;
            
            if (sendToFree && sendToPaid) {
                publishData.emailRecipients = 'all';
            } else if (sendToFree) {
                publishData.emailRecipients = 'free';
            } else if (sendToPaid) {
                publishData.emailRecipients = 'paid';
            } else {
                publishData.emailRecipients = 'none';
            }
        }
        
        if (schedule === 'later') {
            const scheduleDate = document.getElementById('scheduleDate').value;
            const scheduleTime = document.getElementById('scheduleTime').value;
            publishData.scheduledAt = new Date(`${scheduleDate}T${scheduleTime}`).toISOString();
        }
        
        closePublishModal();
        
        // Call the savePost function if it exists
        if (typeof savePost === 'function') {
            const status = schedule === 'later' ? 'scheduled' : 'published';
            savePost(status, false, publishData);
        } else {
            console.error('savePost function not found');
        }
    }
    
    // Preview post
    function previewPost() {
        closePublishModal();
        if (typeof showPreviewModal === 'function') {
            showPreviewModal();
        } else {
            console.error('showPreviewModal function not found');
        }
    }
    
    // Export functions to global scope
    window.showPublishModal = showPublishModal;
    window.closePublishModal = closePublishModal;
    window.togglePublishType = togglePublishType;
    window.toggleEmailRecipients = toggleEmailRecipients;
    window.toggleScheduleOptions = toggleScheduleOptions;
    window.updatePublishOptions = updatePublishOptions;
    window.updatePublishButtonText = updatePublishButtonText;
    window.continueToConfirm = continueToConfirm;
    window.executePublishWithOptions = executePublishWithOptions;
    window.previewPost = previewPost;
})();
</script>