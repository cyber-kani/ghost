<!--- Shared Ghost Editor Styles - Complete styles from edit-ghost-style.cfm --->
    <style>
        /* Ghost Editor Styles */
        .ghost-editor {
            min-height: 100vh;
            background: #ffffff;
        }
        
        .ghost-editor-header {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            padding: 1rem 2rem;
            position: sticky;
            top: 0;
            z-index: 40;
        }
        
        .ghost-editor-title {
            font-size: 2.5rem;
            font-weight: 700;
            border: none;
            outline: none;
            width: 100%;
            padding: 0;
            margin: 0;
            line-height: 1.2;
            color: #171717;
            background: transparent;
            resize: none;
            overflow: hidden;
            min-height: 3rem;
            max-height: 6rem;
            font-family: inherit;
        }
        
        .ghost-editor-title::placeholder {
            color: #9ca3af;
            font-weight: 300;
        }
        
        .ghost-editor-content {
            max-width: 740px;
            margin: 0 auto;
            padding: 4rem 2rem 4rem 5rem;
        }
        
        .ghost-editor-body {
            min-height: 300px;
            font-size: 1.125rem;
            line-height: 1.75;
            color: #374151;
        }
        
        .ghost-editor-wordcount {
            position: fixed;
            bottom: 2rem;
            left: 2rem;
            background: #f3f4f6;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            color: #6b7280;
            z-index: 30;
        }
        
        .ghost-settings-toggle {
            position: fixed;
            top: 50%;
            right: 0;
            transform: translateY(-50%);
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-right: none;
            border-radius: 0.375rem 0 0 0.375rem;
            padding: 0.75rem;
            cursor: pointer;
            z-index: 30;
            transition: all 0.2s ease;
        }
        
        .ghost-settings-toggle:hover {
            background: #f9fafb;
        }
        
        .ghost-settings-panel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100vh;
            background: #ffffff;
            border-left: 1px solid #e5e7eb;
            transition: right 0.3s ease;
            z-index: 50;
            overflow-y: auto;
        }
        
        .ghost-settings-panel.active {
            right: 0;
        }
        
        .ghost-settings-header {
            padding: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-settings-content {
            padding: 1.5rem;
        }
        
        /* Card Styles */
        .content-card {
            position: relative;
            margin: 1.5rem 0;
            padding: 1rem;
            border: 1px solid transparent;
            border-radius: 0.375rem;
            transition: all 0.2s ease;
        }
        
        .content-card:hover {
            border-color: #3b82f6;
            background: #f0f9ff;
        }
        
        .content-card-toolbar {
            position: absolute;
            top: 50%;
            left: -50px;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            opacity: 0;
            transition: opacity 0.2s;
        }
        
        .content-card:hover .content-card-toolbar {
            opacity: 1;
        }
        
        /* Placeholder text for empty contenteditable elements */
        .card-content[contenteditable]:empty:before {
            content: attr(placeholder);
            color: #9ca3af;
            pointer-events: none;
            position: absolute;
            opacity: 0.6;
        }
        
        /* Specific placeholder for paragraph cards */
        .card-content.prose[contenteditable]:empty:before {
            content: "Begin writing your post...";
            color: #9ca3af;
            pointer-events: none;
            position: absolute;
            opacity: 0.6;
        }
        
        .toolbar-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            border: 1px solid #e5e7eb;
            background: #ffffff;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.2s;
            margin: 0;
        }
        
        .toolbar-icon:hover {
            border-color: #d1d5db;
            background: #f9fafb;
            color: #374151;
        }
        
        .toolbar-icon-delete:hover {
            border-color: #fecaca;
            background: #fee2e2;
            color: #dc2626;
        }
        
        .toolbar-icon svg {
            width: 16px;
            height: 16px;
        }
        
        .add-card-button {
            position: relative;
            width: 100%;
            height: 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 1rem 0;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .add-card-button:hover {
            opacity: 1;
        }
        
        .add-card-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: #e5e7eb;
        }
        
        .add-card-button-icon {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 50%;
            width: 2rem;
            height: 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1;
        }
        
        /* Feature Image Styles */
        .feature-image-container {
            position: relative;
            margin-bottom: 3rem;
            cursor: pointer;
            border-radius: 0.5rem;
            overflow: hidden;
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            transition: all 0.2s ease;
        }
        
        .feature-image-container:hover {
            border-color: #3b82f6;
            background: #f0f9ff;
        }
        
        .feature-image-placeholder {
            padding: 4rem 2rem;
            text-align: center;
        }
        
        .feature-image-preview {
            position: relative;
            max-height: 400px;
            overflow: hidden;
        }
        
        .feature-image-preview img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        .feature-image-actions {
            position: absolute;
            top: 1rem;
            right: 1rem;
            display: flex;
            gap: 0.5rem;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .feature-image-container:hover .feature-image-actions {
            opacity: 1;
        }
        
        /* Autosave indicator */
        .autosave-indicator {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            background: #10b981;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            opacity: 0;
            transform: translateY(1rem);
            transition: all 0.2s ease;
        }
        
        .autosave-indicator.show {
            opacity: 1;
            transform: translateY(0);
        }
        
        /* Card menu */
        .card-menu {
            position: absolute;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            padding: 0.5rem 0;
            min-width: 200px;
            max-height: 400px;
            overflow-y: auto;
            z-index: 100;
        }
        
        .card-menu-item {
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        
        .card-menu-item:hover {
            background: #f3f4f6;
        }
        
        .card-menu-category {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: #6b7280;
            padding: 0.5rem 1rem;
            margin-top: 0.5rem;
        }
        
        .card-menu-category:first-child {
            margin-top: 0;
        }
        
        /* Formatting Popup Styles */
        .formatting-popup {
            position: fixed;
            background: #1e293b;
            border-radius: 6px;
            padding: 4px;
            display: flex;
            gap: 2px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10000;
            opacity: 0;
            visibility: hidden;
            transform: translateY(5px);
            transition: opacity 0.2s, transform 0.2s, visibility 0.2s;
        }
        
        .formatting-popup.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        .format-btn {
            width: 32px;
            height: 32px;
            border: none;
            background: transparent;
            color: white;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }
        
        .format-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .format-btn.active {
            background: rgba(255, 255, 255, 0.2);
        }
        
        .format-separator {
            width: 1px;
            height: 20px;
            background: rgba(255, 255, 255, 0.2);
            margin: 0 4px;
        }
        
        .format-select {
            padding: 4px 8px;
            border: none;
            background: transparent;
            color: white;
            font-size: 0.875rem;
            cursor: pointer;
            outline: none;
            min-width: 100px;
        }
        
        .format-select:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .format-select option {
            background: #374151;
            color: white;
        }
        
        .format-btn i {
            font-size: 18px;
        }
        
        /* Link Editor Popup Styles */
        .link-editor-popup {
            position: fixed;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            padding: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10001;
            opacity: 0;
            visibility: hidden;
            transform: translateY(5px);
            transition: opacity 0.2s, transform 0.2s, visibility 0.2s;
        }
        
        .link-editor-popup.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        .link-editor-input-wrapper {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .link-editor-input {
            width: 300px;
            padding: 6px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .link-editor-input:focus {
            border-color: #3b82f6;
        }
        
        .link-editor-btn {
            width: 32px;
            height: 32px;
            border: 1px solid #e5e7eb;
            background: white;
            color: #6b7280;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .link-editor-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .link-editor-btn i {
            font-size: 16px;
        }
        
        /* Link hover menu */
        .link-hover-menu {
            position: fixed;
            background: #1f2937;
            color: white;
            padding: 8px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10000;
            display: none;
            min-width: 200px;
            border: 1px solid #374151;
        }
        
        .link-hover-menu.show {
            display: block;
        }
        
        .link-hover-url {
            font-size: 12px;
            color: #9ca3af;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding: 0 4px;
        }
        
        .link-hover-actions {
            display: flex;
            gap: 4px;
        }
        
        .link-hover-btn {
            background: transparent;
            border: none;
            color: white;
            padding: 6px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .link-hover-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .link-hover-btn i {
            font-size: 16px;
        }
        
        /* Highlight links on hover */
        .card-content a {
            text-decoration: underline;
            color: inherit;
            position: relative;
            cursor: pointer;
        }
        
        .card-content a:hover {
            background: rgba(59, 130, 246, 0.1);
            border-radius: 2px;
        }
        
        /* Image card width styles */
        .image-card-content {
            position: relative;
        }
        
        .image-card-content .image-wrapper {
            position: relative;
            transition: all 0.3s ease;
        }
        
        /* Wide width */
        .image-card-content[data-card-width="wide"] .image-wrapper {
            margin-left: calc(-12.5vw + 50%);
            margin-right: calc(-12.5vw + 50%);
            max-width: none;
        }
        
        /* Full width */
        .image-card-content[data-card-width="full"] .image-wrapper {
            margin-left: calc(-50vw + 50%);
            margin-right: calc(-50vw + 50%);
            max-width: none;
        }
        
        /* Responsive adjustments */
        @media (max-width: 1024px) {
            .image-card-content[data-card-width="wide"] .image-wrapper,
            .image-card-content[data-card-width="full"] .image-wrapper {
                margin-left: -1rem;
                margin-right: -1rem;
            }
        }
        
        /* Ghost-style video settings */
        .ghost-video-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .ghost-video-width-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-video-separator {
            width: 1px;
            height: 20px;
            background: #e5e7eb;
        }
        
        .ghost-video-loop-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            cursor: pointer;
            color: #374151;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .ghost-video-loop-btn:hover {
            background: #f3f4f6;
        }
        
        .ghost-video-loop-btn.active {
            background: #10b981;
            color: white;
            border-color: #10b981;
        }
        
        .ghost-video-loop-btn svg {
            width: 16px;
            height: 16px;
        }
        
        .ghost-replace-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            cursor: pointer;
            color: #374151;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .ghost-replace-btn:hover {
            background: #f3f4f6;
        }
        
        .ghost-replace-btn svg {
            width: 16px;
            height: 16px;
        }
        
        /* Ghost-style audio settings */
        .ghost-audio-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .audio-wrapper {
            padding: 16px;
            background: #f9fafb;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .audio-wrapper audio {
            width: 100%;
            height: 40px;
        }
        
        .audio-duration {
            font-size: 12px;
            color: #6b7280;
            margin-top: 4px;
        }
        
        /* File card styles */
        .file-card-content {
            position: relative;
        }
        
        .file-wrapper {
            transition: all 0.2s ease;
            border: 1px solid #e5e7eb !important;
        }
        
        .file-wrapper:hover {
            border-color: #d1d5db !important;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .file-icon {
            flex-shrink: 0;
        }
        
        .file-info {
            min-width: 0;
        }
        
        .file-name a {
            color: #374151;
            font-weight: 500;
        }
        
        .file-name a:hover {
            color: #059669;
            text-decoration: underline !important;
        }
        
        .file-size {
            font-size: 0.875rem;
            color: #6b7280;
        }
        
        .ghost-file-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        /* Ghost Product Card Styles */
        .ghost-product-card {
            background: #fff;
            border: 1px solid #e6e9eb;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .ghost-product-card-inner {
            display: flex;
            min-height: 180px;
        }
        
        .ghost-product-image-container {
            width: 40%;
            background: #f7f8f9;
            position: relative;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .ghost-product-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .ghost-product-image-placeholder {
            color: #c5c7c9;
            text-align: center;
        }
        
        .ghost-product-image-placeholder svg {
            width: 48px;
            height: 48px;
        }
        
        .ghost-product-content {
            flex: 1;
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .ghost-product-title {
            font-size: 18px;
            font-weight: 600;
            line-height: 1.3;
            color: #15171a;
            border: none;
            background: transparent;
            padding: 0;
            margin: 0;
            width: 100%;
            outline: none;
        }
        
        .ghost-product-title:focus {
            outline: none;
        }
        
        .ghost-product-description {
            font-size: 14px;
            line-height: 1.5;
            color: #626d79;
            border: none;
            background: transparent;
            padding: 0;
            margin: 0;
            width: 100%;
            resize: none;
            outline: none;
        }
        
        .ghost-product-rating {
            display: flex;
            gap: 2px;
            color: #f97316;
        }
        
        .ghost-product-rating .ti {
            font-size: 16px;
        }
        
        .ghost-product-rating .ti:not(.ti-star-filled) {
            color: #e6e9eb;
        }
        
        .ghost-product-button {
            display: inline-block;
            padding: 8px 16px;
            font-size: 14px;
            font-weight: 500;
            border-radius: 4px;
            text-decoration: none !important;
            transition: all 0.2s ease;
            margin-top: auto;
            align-self: flex-start;
        }
        
        .ghost-product-button.primary {
            background: #14b8ff;
            color: white;
            border: 1px solid #14b8ff;
        }
        
        .ghost-product-button.primary:hover {
            background: #0ea5e9;
            border-color: #0ea5e9;
            text-decoration: none !important;
        }
        
        .ghost-product-button.secondary {
            background: #626d79;
            color: white;
            border: 1px solid #626d79;
        }
        
        .ghost-product-button.secondary:hover {
            background: #505863;
            border-color: #505863;
            text-decoration: none !important;
        }
        
        .ghost-product-button.outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #e6e9eb;
        }
        
        .ghost-product-button.outline:hover {
            border-color: #c5c7c9;
            text-decoration: none !important;
        }
        
        .ghost-product-button.link {
            background: transparent;
            color: #14b8ff;
            border: none;
            text-decoration: none !important;
            padding: 0;
        }
        
        .ghost-product-button.link:hover {
            color: #0ea5e9;
            text-decoration: none !important;
        }
        
        /* Ghost Product Settings */
        .ghost-product-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-product-settings-row {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
        }
        
        .ghost-product-settings-row:last-child {
            margin-bottom: 0;
        }
        
        /* General card settings panel styles */
        .ghost-card-settings {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            padding: 16px;
            margin-top: 10px;
            box-shadow: 0 1px 5px rgba(0,0,0,0.1);
            display: none;
        }
        
        /* Show settings panel when active */
        .ghost-card-settings.active {
            display: block;
        }
        
        /* Add margin to cards when settings are open */
        .content-card:has(.ghost-card-settings.active) {
            margin-bottom: 20px;
        }
        
        .toolbar-icon-settings {
            border-color: #14b8ff;
            color: #14b8ff;
        }
        
        .toolbar-icon-settings:hover {
            background: #f0feff;
            border-color: #0ea5e9;
            color: #0ea5e9;
        }
        
        .ghost-setting-group {
            flex: 1;
        }
        
        .ghost-setting-group.full-width {
            flex: 1 0 100%;
        }
        
        .ghost-setting-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #15171a;
            margin-bottom: 8px;
        }
        
        .ghost-input {
            width: 100%;
            padding: 8px 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            background: white;
            color: #15171a;
            outline: none;
        }
        
        .ghost-input:focus {
            border-color: #14b8ff;
        }
        
        .ghost-button-style-group {
            display: flex;
            gap: 8px;
        }
        
        .ghost-style-button {
            flex: 1;
            padding: 8px;
            background: white;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .ghost-style-button:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-style-button.active {
            border-color: #14b8ff;
            background: #f0feff;
        }
        
        .ghost-button-preview {
            display: block;
            padding: 4px 12px;
            font-size: 13px;
            font-weight: 500;
            border-radius: 3px;
            text-align: center;
        }
        
        .ghost-button-preview.primary {
            background: #14b8ff;
            color: white;
            border: none;
        }
        
        .ghost-button-preview.secondary {
            background: #626d79;
            color: white;
            border: none;
        }
        
        .ghost-button-preview.outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #15171a;
        }
        
        .ghost-button-preview.link {
            background: transparent;
            color: #14b8ff;
            text-decoration: none;
            border: none;
        }
        
        .ghost-rating-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-rating-toggle {
            padding: 6px 12px;
            background: white;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            color: #626d79;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .ghost-rating-toggle:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-rating-toggle.active {
            border-color: #14b8ff;
            background: #f0feff;
            color: #14b8ff;
        }
        
        /* Ghost Bookmark Card Styles */
        .kg-bookmark-card,
        .kg-bookmark-card * {
            box-sizing: border-box;
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
            min-height: 148px;
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
        
        .kg-bookmark-metadata > *:not(img) {
            opacity: 0.7;
        }
        
        .ghost-bookmark-publisher {
            font-weight: 500;
        }
        
        .ghost-bookmark-author::before {
            content: "•";
            margin-right: 8px;
        }
        
        .ghost-bookmark-thumbnail {
            width: 180px;
            background: #f7f8f9;
            flex-shrink: 0;
        }
        
        .ghost-bookmark-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
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
        
        .kg-bookmark-publisher {
            text-overflow: ellipsis;
            overflow: hidden;
            max-width: 240px;
            white-space: nowrap;
            display: block;
            line-height: 1.65em;
        }
        
        .kg-bookmark-metadata > span:nth-of-type(2) {
            font-weight: 400;
        }
        
        .kg-bookmark-metadata > span:nth-of-type(2):before {
            content: "•";
            margin: 0 6px;
        }
        
        .kg-bookmark-metadata > span:last-of-type {
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .kg-bookmark-thumbnail {
            position: relative;
            flex-basis: 24rem;
            flex-grow: 1;
            min-width: 33%;
        }
        
        .kg-bookmark-thumbnail::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            display: block;
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
        
        .bookmark-card-content {
            position: relative;
        }
        
        .ghost-bookmark-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-bookmark-loading {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            color: #626d79;
            font-size: 14px;
        }
        
        .ghost-bookmark-error {
            text-align: center;
            padding: 40px 20px;
            color: #f56565;
            font-size: 14px;
        }
        
        /* Spinner animation */
        .spin {
            animation: spin 1s linear infinite;
        }
        
        /* Ghost Embed Card Styles */
        .ghost-embed-wrapper {
            position: relative;
            width: 100%;
            margin: 0;
        }
        
        .ghost-embed-wrapper iframe,
        .ghost-embed-wrapper embed,
        .ghost-embed-wrapper object {
            width: 100%;
            height: auto;
            aspect-ratio: 16/9;
            border: 0;
            border-radius: 8px;
        }
        
        .ghost-embed-wrapper twitter-widget {
            margin: 0 auto !important;
        }
        
        .embed-card-content {
            position: relative;
        }
        
        .ghost-embed-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-embed-input {
            width: 100%;
            padding: 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 6px;
            background: white;
            color: #15171a;
            outline: none;
            font-family: inherit;
        }
        
        .ghost-embed-input:focus {
            border-color: #14b8ff;
        }
        
        .ghost-embed-input::placeholder {
            color: #626d79;
        }
        
        .ghost-embed-caption {
            width: 100%;
            padding: 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 6px;
            background: white;
            color: #15171a;
            outline: none;
            font-family: inherit;
            margin-top: 12px;
        }
        
        .ghost-embed-caption:focus {
            border-color: #14b8ff;
        }
        
        .ghost-embed-loading {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            color: #626d79;
            font-size: 14px;
        }
        
        .ghost-embed-error {
            text-align: center;
            padding: 40px 20px;
            color: #f56565;
            font-size: 14px;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* Post Selector Modal Styles */
        .post-selector-item {
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .post-selector-item:hover {
            background-color: #f8f9fa;
            border-color: #14b8ff !important;
        }
        
        /* Bootstrap modal fallback styles */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1050;
            display: none;
            width: 100%;
            height: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            outline: 0;
        }
        
        .modal.show {
            display: block;
        }
        
        .modal-dialog {
            position: relative;
            width: auto;
            margin: 1.75rem auto;
            max-width: 800px;
        }
        
        .modal-content {
            position: relative;
            display: flex;
            flex-direction: column;
            width: 100%;
            background-color: #fff;
            background-clip: padding-box;
            border: 1px solid rgba(0,0,0,.2);
            border-radius: .3rem;
            outline: 0;
            box-shadow: 0 0.5rem 1rem rgba(0,0,0,.5);
        }
        
        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem;
            border-bottom: 1px solid #dee2e6;
        }
        
        .modal-title {
            margin: 0;
            line-height: 1.5;
            font-size: 1.25rem;
            font-weight: 500;
        }
        
        .modal-body {
            position: relative;
            flex: 1 1 auto;
            padding: 1rem;
            max-height: 70vh;
            overflow-y: auto;
        }
        
        .btn-close {
            padding: .25rem .25rem;
            background: transparent;
            border: 0;
            font-size: 1.25rem;
            font-weight: 700;
            line-height: 1;
            color: #000;
            opacity: .5;
            cursor: pointer;
        }
        
        .btn-close:hover {
            opacity: .75;
        }
        
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1040;
            width: 100vw;
            height: 100vh;
            background-color: #000;
            opacity: .5;
        }
        
        /* Ghost Callout Card Styles */
        .callout-card-content {
            padding: 0;
        }
        
        .ghost-callout-card {
            padding: 1.2em 1.6em;
            border-radius: 8px;
            margin: 0;
            position: relative;
            display: flex;
            gap: 0.8em;
        }
        
        /* Callout card color styles - matching Ghost exactly */
        .ghost-callout-card.kg-callout-card-grey {
            background: rgba(124, 139, 154, 0.13);
        }
        
        .ghost-callout-card.kg-callout-card-white {
            background: transparent;
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.2);
        }
        
        .ghost-callout-card.kg-callout-card-blue {
            background: rgba(33, 172, 232, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-green {
            background: rgba(52, 183, 67, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-yellow {
            background: rgba(240, 165, 15, 0.13);
        }
        
        .ghost-callout-card.kg-callout-card-red {
            background: rgba(209, 46, 46, 0.11);
        }
        
        .ghost-callout-card.kg-callout-card-pink {
            background: rgba(225, 71, 174, 0.11);
        }
        
        .ghost-callout-card.kg-callout-card-purple {
            background: rgba(135, 85, 236, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-accent {
            background: #15171a;
            color: #fff;
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text {
            color: #fff;
        }
        
        
        .ghost-callout-emoji {
            font-size: 1.15em;
            line-height: 1.25em;
            padding-right: 0.8em;
            flex-shrink: 0;
            cursor: pointer;
            user-select: none;
        }
        
        .ghost-callout-text {
            flex: 1;
            font-size: 0.95em;
            line-height: 1.5em;
            outline: none;
            min-height: 24px;
        }
        
        .ghost-callout-text:empty:before {
            content: attr(data-placeholder);
            color: #aaa;
        }
        
        .callout-card-content {
            cursor: pointer;
        }
        
        .ghost-callout-colors {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .ghost-color-button {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .ghost-color-button:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-button.active {
            border-color: #15171a;
            box-shadow: 0 0 0 2px white, 0 0 0 4px #15171a;
        }
        
        .ghost-callout-card.kg-callout-card-white {
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.2);
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text {
            color: white;
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text:empty:before {
            color: rgba(255, 255, 255, 0.7);
        }
        
        /* Emoji picker styles */
        .ghost-emoji-picker {
            position: absolute;
            top: 100%;
            left: 0;
            z-index: 1000;
            background: white;
            border: 1px solid #e6e9eb;
            border-radius: 8px;
            padding: 12px;
            margin-top: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            display: none;
        }
        
        .ghost-emoji-picker.active {
            display: block;
        }
        
        .ghost-emoji-grid {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 4px;
        }
        
        .ghost-emoji-option {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            cursor: pointer;
            border-radius: 4px;
            transition: background-color 0.2s ease;
        }
        
        .ghost-emoji-option:hover {
            background-color: #f5f5f5;
        }
        
        .ghost-color-picker {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .ghost-color-button {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .ghost-color-button:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-button.active {
            box-shadow: 0 0 0 2px #fff, 0 0 0 4px #14b8ff;
        }
        
        .ghost-color-button:focus {
            outline: none;
            box-shadow: 0 0 0 2px #fff, 0 0 0 4px #14b8ff;
        }
        
        /* Ghost-style image settings */
        .ghost-image-settings {
            margin-top: 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .ghost-image-settings.hidden {
            display: none;
        }
        
        /* Button card styles */
        .button-card-content {
            cursor: pointer;
        }
        
        .kg-button-card {
            margin: 1.5em 0;
            text-align: center;
        }
        
        .kg-button-card.kg-align-left {
            text-align: left;
        }
        
        .kg-button-card.kg-align-center {
            text-align: center;
        }
        
        .kg-btn {
            display: inline-block;
            padding: 8px 16px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none !important;
            border-radius: 5px;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        
        /* Custom button class that doesn't inherit default styles */
        .kg-btn-custom {
            all: unset;
            cursor: pointer;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
        
        .kg-btn-primary {
            background: #14b8ff;
            color: #fff;
        }
        
        .kg-btn-primary:hover {
            background: #0ea5e9;
            color: #fff;
        }
        
        .kg-btn-secondary {
            background: #626d79;
            color: #fff;
        }
        
        .kg-btn-secondary:hover {
            background: #515961;
            color: #fff;
        }
        
        .kg-btn-outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #dde1e5;
        }
        
        .kg-btn-outline:hover {
            border-color: #c5c7c9;
            color: #15171a;
        }
        
        .kg-btn-link {
            background: transparent;
            color: #14b8ff;
            text-decoration: none;
        }
        
        .kg-btn-link:hover {
            color: #0ea5e9;
        }
        
        /* Ghost button settings panel */
        .ghost-button-settings {
            min-width: 300px;
        }
        
        /* Gallery card styles - matching Ghost exactly */
        .gallery-card-content {
            cursor: pointer;
        }
        
        .kg-gallery-card {
            margin: 0 0 1.5em;
        }
        
        .kg-gallery-card,
        .kg-gallery-card * {
            box-sizing: border-box;
        }
        
        .kg-gallery-card figcaption {
            margin: 1.0em 0 0;
            text-align: center;
            font-size: 0.85em;
            line-height: 1.4;
            color: rgba(0,0,0,0.5);
        }
        
        .kg-gallery-container {
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
        }
        
        .kg-gallery-row {
            display: flex;
            flex-direction: row;
            justify-content: center;
            gap: 1.2rem;
        }
        
        .kg-gallery-image {
            flex: 1 1 0;
            position: relative;
            overflow: hidden;
            border-radius: 3px;
            min-height: 100px;
            cursor: move;
        }
        
        .kg-gallery-image img {
            display: block;
            margin: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .kg-gallery-image:hover .kg-gallery-image-toolbar {
            opacity: 1;
        }
        
        .kg-gallery-image-toolbar {
            position: absolute;
            top: 8px;
            right: 8px;
            display: flex;
            gap: 4px;
            opacity: 0;
            transition: opacity 0.2s;
            background: rgba(0,0,0,0.3);
            border-radius: 3px;
            padding: 4px;
        }
        
        .kg-gallery-image-btn {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(0,0,0,0.5);
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            transition: background 0.2s;
        }
        
        .kg-gallery-image-btn:hover {
            background: rgba(0,0,0,0.7);
        }
        
        /* Ghost gallery settings */
        .ghost-gallery-settings {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 16px;
            margin-top: 12px;
            display: none;
        }
        
        .ghost-gallery-settings.active {
            display: block;
        }
        
        .ghost-gallery-toolbar {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        
        .ghost-gallery-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-gallery-btn:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .ghost-gallery-images-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            margin-top: 16px;
        }
        
        .ghost-gallery-image-item {
            position: relative;
            aspect-ratio: 1;
            border-radius: 6px;
            overflow: hidden;
            background: #f3f4f6;
        }
        
        .ghost-gallery-image-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .ghost-gallery-image-item:hover .ghost-gallery-image-actions {
            opacity: 1;
        }
        
        .ghost-gallery-image-actions {
            position: absolute;
            inset: 0;
            background: rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            opacity: 0;
            transition: opacity 0.2s;
        }
        
        .ghost-gallery-action-btn {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,255,255,0.9);
            border: none;
            border-radius: 6px;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-gallery-action-btn:hover {
            background: white;
            transform: scale(1.05);
        }
        
        .ghost-gallery-action-delete {
            color: #ef4444;
        }
        
        /* Empty gallery state */
        .kg-gallery-empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .kg-gallery-empty:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .kg-gallery-empty i {
            font-size: 48px;
            color: #9ca3af;
            margin-bottom: 12px;
        }
        
        .kg-gallery-empty p {
            color: #6b7280;
            font-size: 16px;
            margin: 0;
        }
        
        /* Ghost modal styles */
        .ghost-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }
        
        .ghost-modal {
            background: white;
            border-radius: 8px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
            max-width: 500px;
            width: 90%;
            max-height: 90vh;
            display: flex;
            flex-direction: column;
        }
        
        .ghost-modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-modal-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            color: #111827;
        }
        
        .ghost-modal-close {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            border-radius: 6px;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-modal-close:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-modal-body {
            padding: 24px;
            overflow-y: auto;
            flex: 1;
        }
        
        .ghost-modal-footer {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 24px;
            border-top: 1px solid #e5e7eb;
        }
        
        /* Ghost Button Styles */
        .ghost-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 16px;
            height: 36px;
            font-size: 14px;
            font-weight: 500;
            line-height: 1;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            outline: none;
            text-decoration: none;
            white-space: nowrap;
        }
        
        .ghost-btn-black {
            background: #15171a;
            color: #ffffff;
        }
        
        .ghost-btn-black:hover {
            background: #0a0b0d;
        }
        
        .ghost-btn-link {
            background: transparent;
            color: #6b7280;
            padding: 0 8px;
        }
        
        .ghost-btn-link:hover {
            color: #374151;
        }
        
        .ghost-btn-link.text-error {
            color: #dc2626;
        }
        
        .ghost-btn-link.text-error:hover {
            color: #b91c1c;
        }
        
        /* Header Card v2 Styles - Matching Ghost exactly */
        .header-card-content {
            position: relative;
            max-width: 100%;
            overflow: visible;
        }
        
        /* Settings button for header card */
        .ghost-card-settings-button {
            position: absolute;
            top: 8px;
            right: 8px;
            z-index: 10;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            opacity: 0;
            transition: all 0.2s;
        }
        
        .header-card-content:hover .ghost-card-settings-button {
            opacity: 1;
        }
        
        .ghost-card-settings-button:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .ghost-card-settings-button i {
            font-size: 16px;
            color: #374151;
        }
        
        .kg-header-card.kg-v2 {
            position: relative;
            padding: 0;
            min-height: initial;
            text-align: initial;
            margin: 0 0 1.5em;
            cursor: pointer;
            transition: box-shadow 0.2s ease;
        }
        
        .kg-header-card.kg-v2:hover {
            box-shadow: 0 0 0 2px var(--ghost-accent-color);
        }
        
        .kg-header-card.kg-v2,
        .kg-header-card.kg-v2 * {
            box-sizing: border-box;
        }
        
        .kg-header-card.kg-v2 a,
        .kg-header-card.kg-v2 a span {
            color: currentColor;
        }
        
        .kg-header-card.kg-style-accent.kg-v2 {
            background-color: var(--ghost-accent-color);
        }
        
        .kg-header-card-content {
            width: 100%;
        }
        
        .kg-layout-split .kg-header-card-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            max-width: 100%;
        }
        
        /* Ensure split layout doesn't overflow */
        .kg-header-card.kg-layout-split {
            max-width: 100%;
            margin-left: 0;
            margin-right: 0;
        }
        
        .kg-header-card.kg-layout-split.kg-width-full {
            width: 100%;
            max-width: 100%;
        }
        
        .kg-header-card-text {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: center;
            height: 100%;
            padding: min(6.4vmax, 120px) min(4vmax, 80px);
            background-size: cover;
            background-position: center;
            text-align: left;
        }
        
        .kg-width-wide .kg-header-card-text {
            padding: min(10vmax, 220px) min(6.4vmax, 140px);
        }
        
        .kg-width-full .kg-header-card-text {
            padding: min(12vmax, 260px) 0;
        }
        
        .kg-layout-split .kg-header-card-text {
            padding: min(12vmax, 260px) min(4vmax, 80px);
        }
        
        .kg-layout-split.kg-content-wide .kg-header-card-text {
            padding: min(10vmax, 220px) 0 min(10vmax, 220px) min(4vmax, 80px);
        }
        
        .kg-layout-split.kg-content-wide.kg-swapped .kg-header-card-text {
            padding: min(10vmax, 220px) min(4vmax, 80px) min(10vmax, 220px) 0;
        }
        
        .kg-swapped .kg-header-card-text {
            grid-row: 1;
        }
        
        .kg-header-card-text.kg-align-center {
            align-items: center;
            text-align: center;
        }
        
        .kg-header-card.kg-style-image h2.kg-header-card-heading,
        .kg-header-card.kg-style-image .kg-header-card-subheading,
        .kg-header-card.kg-style-image.kg-v2 .kg-header-card-button {
            z-index: 999;
        }
        
        /* Background image */
        .kg-header-card > picture > .kg-header-card-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
            background-color: #FFFFFF;
            pointer-events: none;
        }
        
        /* Split layout image */
        .kg-header-card-content .kg-header-card-image {
            width: 100%;
            height: 0;
            min-height: 100%;
            object-fit: cover;
            object-position: center;
        }
        
        .kg-layout-split .kg-header-card-image {
            max-width: 100%;
            overflow: hidden;
            cursor: pointer;
        }
        
        .kg-header-card-image-placeholder {
            background: #f3f4f6;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 400px;
        }
        
        .kg-header-image-upload-placeholder {
            text-align: center;
            color: #71717a;
        }
        
        .kg-header-image-upload-placeholder i {
            font-size: 48px;
            color: #a1a1aa;
            display: block;
            margin-bottom: 12px;
        }
        
        .kg-header-image-upload-placeholder p {
            margin: 0;
            font-size: 14px;
            font-weight: 500;
        }
        
        .kg-layout-split picture.kg-header-card-image {
            display: block;
            height: 100%;
            min-height: 400px;
        }
        
        .kg-layout-split picture.kg-header-card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .kg-content-wide .kg-header-card-content .kg-header-card-image {
            height: 100%;
            padding: 5.6em 0;
            object-fit: contain;
        }
        
        /* Heading */
        .kg-header-card h2.kg-header-card-heading {
            margin: 0;
            font-size: clamp(1.7em, 4vw, 2.5em);
            font-weight: 700;
            line-height: 1.05em;
            letter-spacing: -0.01em;
        }
        
        .kg-header-card h2.kg-header-card-heading[contenteditable]:empty:before {
            content: attr(data-placeholder);
            color: currentColor;
            opacity: 0.3;
        }
        
        .kg-header-card.kg-width-wide h2.kg-header-card-heading {
            font-size: clamp(1.7em, 5vw, 3.3em);
        }
        
        .kg-header-card.kg-width-full h2.kg-header-card-heading {
            font-size: clamp(1.9em, 5.6vw, 4.2em);
        }
        
        .kg-header-card.kg-width-full.kg-layout-split h2.kg-header-card-heading {
            font-size: clamp(1.9em, 4vw, 3.3em);
        }
        
        /* Subheading */
        .kg-header-card-subheading {
            margin: 0 0 2em;
        }
        
        .kg-header-card .kg-header-card-subheading {
            max-width: 40em;
            margin: 0;
            font-size: clamp(1.05em, 2vw, 1.4em);
            font-weight: 500;
            line-height: 1.2em;
        }
        
        .kg-header-card .kg-header-card-subheading[contenteditable]:empty:before {
            content: attr(data-placeholder);
            color: currentColor;
            opacity: 0.3;
        }
        
        .kg-header-card h2 + .kg-header-card-subheading {
            margin: 0.6em 0 0;
        }
        
        .kg-header-card .kg-header-card-subheading strong {
            font-weight: 600;
        }
        
        .kg-header-card.kg-width-wide .kg-header-card-subheading {
            font-size: clamp(1.05em, 2vw, 1.55em);
        }
        
        .kg-header-card.kg-width-full .kg-header-card-subheading:not(.kg-layout-split .kg-header-card-subheading) {
            max-width: min(65vmax, 1200px);
            font-size: clamp(1.05em, 2vw, 1.7em);
        }
        
        .kg-header-card.kg-width-full.kg-layout-split .kg-header-card-subheading {
            font-size: clamp(1.05em, 2vw, 1.55em);
        }
        
        /* Button */
        .kg-header-card.kg-v2 .kg-header-card-button {
            display: flex;
            position: relative;
            align-items: center;
            height: 2.9em;
            min-height: 46px;
            padding: 0 1.2em;
            outline: none;
            border: none;
            font-size: 1em;
            font-weight: 600;
            line-height: 1em;
            text-align: center;
            text-decoration: none;
            letter-spacing: .2px;
            white-space: nowrap;
            text-overflow: ellipsis;
            border-radius: 3px;
            transition: opacity .2s ease;
            cursor: pointer;
        }
        
        .kg-header-card.kg-v2 .kg-header-card-button.kg-style-accent {
            background-color: var(--ghost-accent-color);
        }
        
        .kg-header-card.kg-v2 h2 + .kg-header-card-button,
        .kg-header-card.kg-v2 p + .kg-header-card-button {
            margin: 1.5em 0 0;
        }
        
        .kg-header-card.kg-v2 .kg-header-card-button:hover {
            opacity: 0.85;
        }
        
        .kg-header-card.kg-v2.kg-width-wide .kg-header-card-button {
            font-size: 1.05em;
        }
        
        .kg-header-card.kg-v2.kg-width-wide h2 + .kg-header-card-button,
        .kg-header-card.kg-v2.kg-width-wide p + .kg-header-card-button {
            margin-top: 1.75em;
        }
        
        .kg-header-card.kg-v2.kg-width-full .kg-header-card-button {
            font-size: 1.1em;
        }
        
        .kg-header-card.kg-v2.kg-width-full h2 + .kg-header-card-button,
        .kg-header-card.kg-v2.kg-width-full p + .kg-header-card-button {
            margin-top: 2em;
        }
        
        /* Header settings panel */
        .ghost-header-settings {
            margin: 16px auto;
            display: none;
            width: 100%;
            max-width: 680px;
        }
        
        .ghost-header-settings:not(.hidden) {
            display: block !important;
        }
        
        .ghost-header-settings .ghost-settings-panel {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            width: 100%;
            max-height: 500px;
            overflow-y: auto;
            margin: 0 auto;
        }
        
        .ghost-settings-group {
            margin-bottom: 16px;
        }
        
        .ghost-settings-group:last-child {
            margin-bottom: 0;
        }
        
        .ghost-settings-label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }
        
        .ghost-button-group {
            display: flex;
            gap: 4px;
        }
        
        .ghost-button-small {
            padding: 6px 12px;
            font-size: 13px;
            border: 1px solid #e5e7eb;
            background: white;
            color: #374151;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .ghost-button-small:hover {
            background: #f3f4f6;
        }
        
        .ghost-button-small.active {
            background: #1f2937;
            color: white;
            border-color: #1f2937;
        }
        
        .ghost-color-picker-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .ghost-color-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 2px solid transparent;
            cursor: pointer;
            position: relative;
            transition: all 0.2s;
        }
        
        .ghost-color-btn:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-btn.active {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
        }
        
        .ghost-color-btn.ghost-color-custom {
            background: linear-gradient(45deg, #e5e7eb 25%, transparent 25%, transparent 75%, #e5e7eb 75%, #e5e7eb),
                        linear-gradient(45deg, #e5e7eb 25%, transparent 25%, transparent 75%, #e5e7eb 75%, #e5e7eb);
            background-size: 10px 10px;
            background-position: 0 0, 5px 5px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .ghost-input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        
        .ghost-input:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .kg-layout-split .kg-header-card-content {
                grid-template-columns: 1fr;
            }
            
            .kg-width-wide .kg-header-card-text {
                padding: min(6.4vmax, 120px) min(4vmax, 80px);
            }
            
            .kg-layout-split.kg-content-wide .kg-header-card-text,
            .kg-layout-split.kg-content-wide.kg-swapped .kg-header-card-text {
                padding: min(9.6vmax, 180px) 0;
            }
            
            .kg-header-card.kg-width-full .kg-header-card-subheading:not(.kg-layout-split .kg-header-card-subheading) {
                max-width: unset;
            }
            
            .kg-header-card-content .kg-header-card-image:not(.kg-content-wide .kg-header-card-content .kg-header-card-image) {
                height: auto;
                min-height: unset;
                aspect-ratio: 1 / 1;
            }
            
            .kg-content-wide .kg-header-card-content .kg-header-card-image {
                padding: 1.7em 0 0;
            }
            
            .kg-content-wide.kg-swapped .kg-header-card-content .kg-header-card-image {
                padding: 0 0 1.7em;
            }
            
            .kg-header-card.kg-v2 .kg-header-card-button {
                height: 2.9em;
            }
            
            .kg-header-card.kg-v2.kg-width-wide .kg-header-card-button,
            .kg-header-card.kg-v2.kg-width-full .kg-header-card-button {
                font-size: 1em;
            }
        }
        
        /* Ghost Settings Panel Styles (from koenig.css) */
        .kg-settings-panel {
            position: relative;
            margin: 1rem auto;
            padding: 1rem;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            max-width: 680px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .kg-settings-panel-header {
            border-color: #dde1e7;
        }
        
        .kg-settings-panel-content {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .kg-settings-panel-control {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        
        .kg-settings-panel-control-layout {
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 1.5rem;
        }
        
        .kg-settings-panel-control-label {
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }
        
        .kg-settings-panel-control-input .gh-input,
        .kg-settings-panel-control-input .gh-select {
            font-size: 1.0rem !important;
            padding: 5px 10px;
            font-weight: 500;
        }
        
        /* Ghost button groups */
        .gh-btn-group {
            display: inline-flex;
            border-radius: 4px;
            background: #f5f5f5;
        }
        
        .gh-btn-group.icons {
            background: transparent;
            gap: 0.5rem;
        }
        
        .gh-btn {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.5rem 1rem;
            border: none;
            background: transparent;
            color: #15171a;
            font-size: 1.3rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        
        .gh-btn-icon {
            width: 32px;
            height: 32px;
            padding: 0;
        }
        
        .gh-btn-group .gh-btn:first-child {
            border-radius: 4px 0 0 4px;
        }
        
        .gh-btn-group .gh-btn:last-child {
            border-radius: 0 4px 4px 0;
        }
        
        .gh-btn-group .gh-btn-group-selected {
            background: #ffffff;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        
        .gh-btn-outline {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
        }
        
        /* Header style buttons */
        .kg-settings-headerstyle-btn-group {
            background: none !important;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn {
            background: var(--white) !important;
            width: 26px;
            height: 26px;
            border: 1px solid var(--whitegrey);
            border-radius: 50%;
            margin-right: 5px;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-dark {
            background: #08090c !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-light {
            background: #F9F9F9 !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-accent {
            background: var(--accent-color, #FF1A75) !important;
        }
        
        /* Remove old custom button styles since we're using image button now */
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-image {
            background-image: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjYiIGhlaWdodD0iMjYiIHZpZXdCb3g9IjAgMCAyNiAyNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjI2IiBoZWlnaHQ9IjI2IiByeD0iMTMiIGZpbGw9IiNFNUU3RUIiLz4KPHBhdGggZD0iTTE4LjUgMTguNVY5LjVDMTguNSA4LjM5NTQzIDE3LjYwNDYgNy41IDE2LjUgNy41SDkuNUM4LjM5NTQzIDcuNSA3LjUgOC4zOTU0MyA3LjUgOS41VjE4LjUiIHN0cm9rZT0iIzZCNzI4MCIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8Y2lyY2xlIGN4PSIxMS41IiBjeT0iMTEuNSIgcj0iMS41IiBmaWxsPSIjNkI3MjgwIi8+CjxwYXRoIGQ9Ik03LjUgMTguNUwxMSAxNUwxNS41IDE5LjUiIHN0cm9rZT0iIzZCNzI4MCIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4=') !important;
            background-size: cover !important;
            background-position: center !important;
            margin-right: 0;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-image.has-image {
            background-size: cover !important;
            background-position: center !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom {
            background: conic-gradient(from 0deg, #FF1A75, #F59E0B, #10B981, #0EA5E9, #8B5CF6, #FF1A75) !important;
            border-radius: 50% !important;
            margin-right: 0;
            position: relative;
            overflow: hidden;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom::after {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            right: 3px;
            bottom: 3px;
            background: white;
            border-radius: 50%;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom:not(.gh-btn-group-selected):hover::after {
            opacity: 0.2;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn-group-selected {
            position: relative;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn-group-selected::before {
            position: absolute;
            content: "";
            display: block;
            top: -4px;
            right: -4px;
            bottom: -4px;
            left: -4px;
            border: 2px solid var(--green, #30cf43);
            border-radius: 50%;
        }
        
        /* Fix button alignment in settings panel */
        .kg-settings-panel-control-input .gh-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            max-width: 100%;
            width: 100%;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            padding: 8px 12px;
            font-size: 13px;
        }
        
        .kg-settings-panel-control-input .gh-btn span {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            flex: 1;
            min-width: 0;
        }
        
        .kg-settings-panel-control-input .gh-btn svg {
            flex-shrink: 0;
            width: 14px;
            height: 14px;
        }
        
        /* Color picker styles - matching Ghost exactly */
        .kg-color-picker-swatch-group {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        
        .kg-color-swatch {
            width: 26px;
            height: 26px;
            border-radius: 50%;
            cursor: pointer;
            border: 1px solid var(--whitegrey);
            transition: all 0.2s ease;
            position: relative;
            box-sizing: border-box;
            padding: 0;
            background: none;
        }
        
        .kg-color-swatch:hover {
            transform: scale(1.1);
        }
        
        .kg-color-swatch.active {
            position: relative;
        }
        
        .kg-color-swatch.active::before {
            position: absolute;
            content: "";
            display: block;
            top: -4px;
            right: -4px;
            bottom: -4px;
            left: -4px;
            border: 2px solid var(--green);
            border-radius: 50%;
        }
        
        .kg-color-swatch-custom {
            background: transparent !important;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        
        .kg-color-swatch-custom svg {
            width: 12px;
            height: 12px;
            pointer-events: none;
            color: #737373;
        }
        
        .kg-color-swatch-custom svg path {
            stroke-width: 1.5;
        }
        
        .kg-color-picker-input {
            position: absolute;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }
        
        .ghost-color-picker-row {
            display: flex;
            gap: 12px;
            margin-top: 8px;
        }
        
        .ghost-color-input-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        
        .ghost-color-label {
            font-size: 12px;
            color: #626d79;
            font-weight: 500;
        }
        
        .ghost-color-picker {
            width: 100%;
            height: 36px;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            cursor: pointer;
            padding: 2px;
        }
        
        .ghost-color-picker:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-color-picker:focus {
            outline: none;
            border-color: #14b8ff;
            box-shadow: 0 0 0 2px rgba(20, 184, 255, 0.2);
        }
        
        .ghost-image-toolbar {
            display: flex;
            align-items: center;
            padding: 8px;
            gap: 4px;
            background: #fafafa;
        }
        
        .ghost-image-width-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-width-btn, .ghost-video-toolbar .ghost-width-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            border: none;
            background: transparent;
            color: #6b7280;
            border-radius: 3px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .ghost-width-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-width-btn.active {
            background: #374151;
            color: white;
        }
        
        .ghost-width-btn svg {
            width: 24px;
            height: 18px;
        }
        
        .ghost-image-toolbar-divider {
            width: 1px;
            height: 24px;
            background: #e5e7eb;
            margin: 0 8px;
        }
        
        .ghost-image-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            border: none;
            background: transparent;
            color: #6b7280;
            border-radius: 3px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            font-size: 18px;
        }
        
        .ghost-image-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-image-btn.active {
            color: #10b981;
        }
        
        .ghost-alt-icon {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        
        .ghost-image-input-row {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-image-input-row.hidden {
            display: none;
        }
        
        .ghost-image-input-row:last-child {
            border-bottom: none;
        }
        
        .ghost-image-input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 3px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .ghost-image-input:focus {
            border-color: #10b981;
        }
        
        /* Image hover effect for settings */
        .image-card-content .image-wrapper img {
            transition: opacity 0.2s;
        }
        
        .image-card-content .image-wrapper:hover img {
            opacity: 0.9;
            cursor: pointer;
        }
        
        /* Video card width styles */
        .video-card-content {
            position: relative;
        }
        
        .video-card-content .video-wrapper {
            position: relative;
            transition: all 0.3s ease;
        }
        
        /* Wide width */
        .video-card-content[data-card-width="wide"] .video-wrapper {
            margin-left: calc(-12.5vw + 50%);
            margin-right: calc(-12.5vw + 50%);
            max-width: none;
        }
        
        /* Full width */
        .video-card-content[data-card-width="full"] .video-wrapper {
            margin-left: calc(-50vw + 50%);
            margin-right: calc(-50vw + 50%);
            max-width: none;
        }
        
        /* Responsive adjustments for video */
        @media (max-width: 1024px) {
            .video-card-content[data-card-width="wide"] .video-wrapper,
            .video-card-content[data-card-width="full"] .video-wrapper {
                margin-left: -1rem;
                margin-right: -1rem;
            }
        }
        
        /* Markdown card styles */
        .markdown-card-content {
            padding: 0;
        }
        
        .ghost-markdown-card {
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            overflow: hidden;
            background: #fafafa;
        }
        
        .ghost-markdown-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            background: #f5f5f5;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-markdown-label {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #666;
            font-size: 13px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        
        .ghost-markdown-label svg {
            color: #999;
        }
        
        .ghost-markdown-help-link {
            color: #999;
            text-decoration: none;
            font-size: 18px;
            transition: color 0.2s ease;
        }
        
        .ghost-markdown-help-link:hover {
            color: #666;
        }
        
        .ghost-markdown-editor {
            width: 100%;
            min-height: 200px;
            padding: 16px;
            border: none;
            background: transparent;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 14px;
            line-height: 1.6;
            color: #333;
            resize: none;
            outline: none;
        }
        
        .ghost-markdown-editor::placeholder {
            color: #999;
        }
        
        .editor-card.focused .ghost-markdown-card {
            border-color: #30a46c;
        }
        
        .editor-card.focused .ghost-markdown-header {
            background: #eef8f3;
            border-bottom-color: #30a46c;
        }
        
        /* Toggle card styles */
        .toggle-card-content {
            padding: 0;
        }
        
        .kg-toggle-card {
            background: transparent;
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.25);
            border-radius: 4px;
            padding: 1.2em;
        }
        
        .kg-toggle-card[data-kg-toggle-state="close"] .kg-toggle-content {
            display: none;
        }
        
        .kg-toggle-content {
            height: auto;
            opacity: 1;
            transition: opacity 0.3s ease;
            position: relative;
            display: block;
        }
        
        .kg-toggle-card[data-kg-toggle-state="close"] svg {
            transform: unset;
        }
        
        .kg-toggle-heading {
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        
        .kg-toggle-card h4.kg-toggle-heading-text {
            font-size: 1.15em;
            font-weight: 700;
            line-height: 1.3em;
            margin: 0;
            flex: 1;
            outline: none;
        }
        
        .kg-toggle-heading-text:empty::before {
            content: attr(data-placeholder);
            color: #999;
        }
        
        .kg-toggle-content p:first-of-type {
            margin-top: 0.5em;
        }
        
        .kg-toggle-content > div {
            font-size: 0.95em;
            line-height: 1.5em;
            margin-top: 0.95em;
            outline: none;
            min-height: 30px;
            cursor: text;
        }
        
        .kg-toggle-content > div:empty::before {
            content: attr(data-placeholder);
            color: #999;
        }
        
        .kg-toggle-card-icon {
            height: 24px;
            width: 24px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-left: 1em;
            padding: 0;
            background: none;
            border: 0;
            cursor: pointer;
        }
        
        .kg-toggle-heading svg {
            width: 14px;
            color: rgba(124, 139, 154, 0.5);
            transition: all 0.3s;
            transform: rotate(-180deg);
        }
        
        .kg-toggle-heading path {
            fill: none;
            stroke: currentcolor;
            stroke-linecap: round;
            stroke-linejoin: round;
            stroke-width: 1.5;
            fill-rule: evenodd;
        }
        
        .editor-card.focused .kg-toggle-card {
            box-shadow: inset 0 0 0 1px #30a46c;
        }
        
        /* Product card button styles */
        .kg-product-card-button {
            text-decoration: none !important;
            display: inline-block;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .kg-product-card-button:hover {
            text-decoration: none !important;
            opacity: 0.9;
        }
        
        .kg-product-button-primary {
            background: #30a46c;
            color: white !important;
        }
        
        .kg-product-button-secondary {
            background: #f0f2f5;
            color: #374151 !important;
        }
        
        .kg-product-button-outline {
            background: transparent;
            border: 1px solid #e5e7eb;
            color: #374151 !important;
        }
        
        .kg-product-button-link {
            background: transparent;
            color: #30a46c !important;
            padding: 0;
        }
    
    /* Apple HIG-inspired styles */
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
    
    :root {
        --apple-bg-primary: #ffffff;
        --apple-bg-secondary: #f5f5f7;
        --apple-bg-tertiary: #fafafa;
        --apple-text-primary: #1d1d1f;
        --apple-text-secondary: #86868b;
        --apple-text-tertiary: #515154;
        --apple-border: #d2d2d7;
        --apple-border-light: #e8e8ed;
        --apple-blue: #0071e3;
        --apple-blue-hover: #0077ed;
        --apple-green: #34c759;
        --apple-red: #ff3b30;
        --apple-yellow: #ffcc00;
        --apple-shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
        --apple-shadow-md: 0 4px 16px rgba(0,0,0,0.08);
        --apple-shadow-lg: 0 10px 40px rgba(0,0,0,0.12);
        --apple-radius-sm: 8px;
        --apple-radius-md: 12px;
        --apple-radius-lg: 16px;
        --apple-transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    /* Settings panel - Apple style */
    .ghost-settings-panel {
        position: fixed;
        top: 0;
        right: -420px;
        width: 420px;
        height: 100vh;
        background: var(--apple-bg-primary);
        border-left: 1px solid var(--apple-border-light);
        transition: var(--apple-transition);
        z-index: 1050;
        display: flex;
        flex-direction: column;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
    }
    
    .ghost-settings-panel.active {
        right: 0;
    }
    
    .ghost-settings-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20px 24px;
        background: var(--apple-bg-primary);
        border-bottom: 1px solid var(--apple-border-light);
        -webkit-backdrop-filter: blur(10px);
        backdrop-filter: blur(10px);
    }
    
    .ghost-settings-header h3 {
        font-size: 20px;
        font-weight: 600;
        color: var(--apple-text-primary);
        margin: 0;
        letter-spacing: -0.02em;
    }
    
    .ghost-settings-content {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background: var(--apple-bg-secondary);
    }
    
    .ghost-settings-content::-webkit-scrollbar {
        width: 0;
    }
    
    /* Form sections */
    .settings-section {
        background: var(--apple-bg-primary);
        border-radius: var(--apple-radius-md);
        padding: 20px;
        margin-bottom: 16px;
        box-shadow: var(--apple-shadow-sm);
    }
    
    .settings-section-title {
        font-size: 13px;
        font-weight: 600;
        color: var(--apple-text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.02em;
        margin-bottom: 16px;
        padding: 0 4px;
    }
    
    /* Form controls */
    .apple-form-label {
        display: block;
        font-size: 15px;
        font-weight: 500;
        color: var(--apple-text-primary);
        margin-bottom: 8px;
        letter-spacing: -0.01em;
    }
    
    .apple-form-control {
        width: 100%;
        padding: 10px 12px;
        font-size: 15px;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
        background: var(--apple-bg-tertiary);
        border: 1px solid var(--apple-border);
        border-radius: var(--apple-radius-sm);
        color: var(--apple-text-primary);
        transition: var(--apple-transition);
        -webkit-appearance: none;
    }
    
    .apple-form-control:focus {
        outline: none;
        border-color: var(--apple-blue);
        box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
        background: var(--apple-bg-primary);
    }
    
    .apple-form-control::placeholder {
        color: var(--apple-text-tertiary);
    }
    
    .apple-form-helper {
        font-size: 13px;
        color: var(--apple-text-secondary);
        margin-top: 6px;
        line-height: 1.4;
    }
    
    /* Toggle switches - iOS style */
    .apple-switch {
        position: relative;
        display: inline-block;
        width: 51px;
        height: 31px;
    }
    
    .apple-switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    
    .apple-switch-slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #e9e9eb;
        transition: var(--apple-transition);
        border-radius: 31px;
    }
    
    .apple-switch-slider:before {
        position: absolute;
        content: "";
        height: 27px;
        width: 27px;
        left: 2px;
        bottom: 2px;
        background-color: white;
        transition: var(--apple-transition);
        border-radius: 50%;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    
    .apple-switch input:checked + .apple-switch-slider {
        background-color: var(--apple-green);
    }
    
    .apple-switch input:checked + .apple-switch-slider:before {
        transform: translateX(20px);
    }
    
    /* Segmented control */
    .apple-segmented-control {
        display: flex;
        background: var(--apple-bg-tertiary);
        border-radius: var(--apple-radius-sm);
        padding: 2px;
        gap: 2px;
    }
    
    .apple-segment {
        flex: 1;
        padding: 8px 16px;
        font-size: 14px;
        font-weight: 500;
        text-align: center;
        background: transparent;
        border: none;
        border-radius: 6px;
        color: var(--apple-text-primary);
        cursor: pointer;
        transition: var(--apple-transition);
    }
    
    .apple-segment.active {
        background: var(--apple-bg-primary);
        box-shadow: var(--apple-shadow-sm);
    }
    
    /* List items */
    .apple-list-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 0;
        border-bottom: 1px solid var(--apple-border-light);
    }
    
    .apple-list-item:last-child {
        border-bottom: none;
    }
    
    .apple-list-item-content {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .apple-list-item-icon {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: var(--apple-bg-tertiary);
        border-radius: var(--apple-radius-sm);
        color: var(--apple-text-secondary);
    }
    
    .apple-list-item-text h4 {
        font-size: 15px;
        font-weight: 500;
        color: var(--apple-text-primary);
        margin: 0 0 2px 0;
    }
    
    .apple-list-item-text p {
        font-size: 13px;
        color: var(--apple-text-secondary);
        margin: 0;
    }
    
    /* Buttons */
    .apple-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 10px 20px;
        font-size: 15px;
        font-weight: 500;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
        border-radius: var(--apple-radius-sm);
        border: none;
        cursor: pointer;
        transition: var(--apple-transition);
        gap: 6px;
    }
    
    .apple-btn-primary {
        background: var(--apple-blue);
        color: white;
    }
    
    .apple-btn-primary:hover {
        background: var(--apple-blue-hover);
        transform: translateY(-1px);
    }
    
    .apple-btn-secondary {
        background: var(--apple-bg-tertiary);
        color: var(--apple-text-primary);
        border: 1px solid var(--apple-border);
    }
    
    .apple-btn-secondary:hover {
        background: var(--apple-bg-secondary);
    }
    
    .apple-btn-danger {
        background: transparent;
        color: var(--apple-red);
        border: 1px solid var(--apple-red);
    }
    
    .apple-btn-danger:hover {
        background: var(--apple-red);
        color: white;
    }
    
    /* Icon buttons */
    .apple-icon-btn {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        border: none;
        border-radius: 50%;
        color: var(--apple-text-secondary);
        cursor: pointer;
        transition: var(--apple-transition);
    }
    
    .apple-icon-btn:hover {
        background: var(--apple-bg-tertiary);
        color: var(--apple-text-primary);
    }
    
    /* Subview panel styles */
    .subview-panel {
        position: fixed;
        top: 0;
        right: -420px;
        width: 420px;
        height: 100vh;
        background: var(--apple-bg-primary);
        border-left: 1px solid var(--apple-border-light);
        transition: var(--apple-transition);
        z-index: 1060;
        display: flex;
        flex-direction: column;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
    }
    
    .subview-panel.active {
        right: 0;
    }
    
    .subview-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20px 24px;
        background: var(--apple-bg-primary);
        border-bottom: 1px solid var(--apple-border-light);
        -webkit-backdrop-filter: blur(10px);
        backdrop-filter: blur(10px);
    }
    
    .subview-content {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background: var(--apple-bg-secondary);
    }
    
    /* Character counter */
    .char-counter {
        font-size: 13px;
        font-weight: 500;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    
    .char-counter-good {
        color: var(--apple-green);
    }
    
    .char-counter-warning {
        color: var(--apple-yellow);
    }
    
    .char-counter-danger {
        color: var(--apple-red);
    }
    
    /* Social preview cards */
    .social-preview {
        border: 1px solid var(--apple-border);
        border-radius: var(--apple-radius-md);
        overflow: hidden;
        margin-top: 16px;
        background: var(--apple-bg-primary);
        box-shadow: var(--apple-shadow-sm);
    }
    
    .social-preview-image {
        height: 200px;
        background: var(--apple-bg-tertiary);
        background-size: cover;
        background-position: center;
    }
    
    .social-preview-content {
        padding: 16px;
    }
    
    .social-preview-domain {
        font-size: 12px;
        color: var(--apple-text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.02em;
        margin-bottom: 4px;
    }
    
    .social-preview-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--apple-text-primary);
        margin-bottom: 4px;
        line-height: 1.3;
    }
    
    .social-preview-description {
        font-size: 14px;
        color: var(--apple-text-secondary);
        line-height: 1.4;
    }
    
    /* Tags */
    .apple-tag {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: var(--apple-blue);
        color: white;
        border-radius: 20px;
        font-size: 14px;
        font-weight: 500;
    }
    
    .apple-tag-remove {
        background: none;
        border: none;
        color: white;
        opacity: 0.7;
        cursor: pointer;
        padding: 0;
        transition: opacity 0.2s;
    }
    
    .apple-tag-remove:hover {
        opacity: 1;
    }
    
    /* Animations */
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    
    .animate-slide-in {
        animation: slideIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .animate-fade-in {
        animation: fadeIn 0.3s ease-in-out;
    }
    
    /* Publish modal styles */
    .ghost-modal input[type="radio"] {
        flex-shrink: 0;
        width: 1rem;
        height: 1rem;
        margin-top: 0.125rem;
        cursor: pointer;
    }
    
    .ghost-modal input[type="date"],
    .ghost-modal input[type="time"] {
        padding: 0.5rem 0.75rem;
        border: 1px solid #e5e7eb;
        border-radius: 0.375rem;
        font-size: 0.875rem;
        transition: border-color 0.15s ease-in-out;
    }
    
    .ghost-modal input[type="date"]:focus,
    .ghost-modal input[type="time"]:focus {
        outline: none;
        border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }
    
    .ghost-modal label {
        display: flex;
        cursor: pointer;
    }
    
    .ghost-modal .form-control {
        display: block;
        width: 100%;
        padding: 0.5rem 0.75rem;
        font-size: 0.875rem;
        line-height: 1.25rem;
        color: #374151;
        background-color: #ffffff;
        background-clip: padding-box;
        border: 1px solid #d1d5db;
        border-radius: 0.375rem;
        transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
    }
    </style>
