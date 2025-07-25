<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Post - Ghost Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tabler-icons/1.35.0/tabler-icons.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f4f5f6;
            line-height: 1.6;
            color: #15171a;
            overflow-x: hidden;
        }

        .navbar {
            background: #fff;
            border-bottom: 1px solid #e3e8ee;
            padding: 0 20px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .navbar-brand {
            font-weight: 600;
            font-size: 18px;
            color: #15171a;
            text-decoration: none;
        }

        .navbar-nav {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background: #15171a;
            color: #fff;
        }

        .btn-primary:hover {
            background: #343a40;
        }

        .btn-secondary {
            background: #f1f3f4;
            color: #5d7079;
        }

        .btn-secondary:hover {
            background: #e3e8ee;
        }

        .container {
            max-width: 740px;
            margin: 0 auto;
            padding: 40px 20px;
            min-height: calc(100vh - 60px);
        }

        .post-header {
            margin-bottom: 40px;
            background: #fff;
            border-radius: 8px;
            padding: 40px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .post-title {
            width: 100%;
            border: none;
            font-size: 42px;
            font-weight: 700;
            color: #15171a;
            background: transparent;
            resize: none;
            overflow: hidden;
            min-height: 80px;
            line-height: 1.15;
            margin-bottom: 20px;
        }

        .post-title:focus {
            outline: none;
        }

        .post-title::placeholder {
            color: #626d79;
        }

        .post-meta {
            display: flex;
            gap: 16px;
            align-items: center;
            font-size: 14px;
            color: #626d79;
            padding: 12px 0;
            border-top: 1px solid #e3e8ee;
        }

        .editor-container {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            min-height: 500px;
            padding: 40px;
        }

        .gh-block {
            margin: 20px 0;
            position: relative;
            padding: 20px;
            border: 2px dashed transparent;
            border-radius: 8px;
            transition: all 0.2s ease;
        }

        .gh-block:hover {
            border-color: #e3e8ee;
        }

        .gh-block.selected {
            border-color: #30cf43;
            background: rgba(48, 207, 67, 0.05);
        }

        .gh-block-controls {
            position: absolute;
            left: -50px;
            top: 20px;
            opacity: 0;
            transition: opacity 0.2s ease;
            z-index: 10;
        }

        .gh-block:hover .gh-block-controls,
        .gh-block.selected .gh-block-controls {
            opacity: 1;
        }

        .gh-block-menu {
            width: 32px;
            height: 32px;
            border: none;
            background: #f1f3f4;
            border-radius: 6px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #626d79;
            font-size: 16px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .gh-block-menu:hover {
            background: #30cf43;
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        .text-block {
            border: none;
            background: transparent;
            font-size: 18px;
            line-height: 1.6;
            color: #15171a;
            width: 100%;
            min-height: 50px;
            resize: none;
            overflow: hidden;
        }

        .text-block:focus {
            outline: none;
        }

        .text-block::placeholder {
            color: #a8a8a8;
        }

        .image-block-container {
            margin: 30px 0;
            position: relative;
            text-align: center;
            background: #fff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 2px dashed transparent;
            transition: all 0.2s ease;
        }

        .image-block-container:hover {
            border-color: #e3e8ee;
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }

        .image-block-container.selected {
            border-color: #30cf43;
            box-shadow: 0 4px 16px rgba(48, 207, 67, 0.2);
        }

        .image-preview {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 0 auto;
        }

        .image-toolbar {
            position: absolute;
            top: 16px;
            right: 16px;
            background: rgba(21, 23, 26, 0.9);
            border-radius: 8px;
            padding: 8px;
            display: flex;
            gap: 4px;
            opacity: 0;
            transition: opacity 0.2s ease;
            backdrop-filter: blur(4px);
        }

        .image-block-container:hover .image-toolbar {
            opacity: 1;
        }

        .image-toolbar .toolbar-btn {
            width: 32px;
            height: 32px;
            background: transparent;
            border: none;
            color: #fff;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s ease;
        }

        .image-toolbar .toolbar-btn:hover {
            background: rgba(255,255,255,0.2);
        }

        .image-caption {
            padding: 20px;
            text-align: center;
            font-size: 16px;
            color: #626d79;
            font-style: italic;
            border: none;
            background: transparent;
            width: 100%;
            outline: none;
            min-height: 60px;
        }

        .image-caption:empty:before {
            content: "Type caption for image (optional)";
            color: #a8a8a8;
        }

        .image-caption.editing {
            border-top: 1px solid #e3e8ee;
            background: #f9f9f9;
        }

        .plus-menu {
            position: absolute;
            left: -50px;
            top: 60px;
            background: #fff;
            border: 1px solid #e3e8ee;
            border-radius: 8px;
            padding: 8px;
            display: none;
            flex-direction: column;
            gap: 4px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            z-index: 100;
            min-width: 160px;
        }

        .plus-menu .menu-item {
            padding: 12px 16px;
            border: none;
            background: transparent;
            text-align: left;
            cursor: pointer;
            border-radius: 6px;
            font-size: 14px;
            color: #15171a;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: background 0.2s ease;
        }

        .plus-menu .menu-item:hover {
            background: #f1f3f4;
        }

        .plus-menu .menu-item i {
            width: 20px;
            text-align: center;
        }

        .floating-toolbar {
            position: fixed;
            background: #15171a;
            border-radius: 8px;
            padding: 8px;
            display: none;
            gap: 4px;
            z-index: 1000;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }

        .floating-toolbar .toolbar-btn {
            width: 32px;
            height: 32px;
            background: transparent;
            border: none;
            color: #fff;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s ease;
        }

        .floating-toolbar .toolbar-btn:hover {
            background: rgba(255,255,255,0.2);
        }

        .notification {
            position: fixed;
            top: 80px;
            right: 20px;
            background: #15171a;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            z-index: 1000;
            animation: slideIn 0.3s ease;
        }

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

        .image-url-panel {
            background: #f9f9f9;
            border-top: 1px solid #e3e8ee;
            padding: 20px;
        }

        .image-url-input {
            width: 100%;
            padding: 12px;
            border: 1px solid #e3e8ee;
            border-radius: 6px;
            font-size: 14px;
            margin-bottom: 12px;
        }

        .image-url-actions {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
        }

        .add-block-btn {
            width: 100%;
            padding: 20px;
            border: 2px dashed #e3e8ee;
            background: transparent;
            border-radius: 8px;
            cursor: pointer;
            color: #626d79;
            font-size: 14px;
            margin: 20px 0;
            transition: all 0.2s ease;
        }

        .add-block-btn:hover {
            border-color: #30cf43;
            color: #30cf43;
            background: rgba(48, 207, 67, 0.05);
        }

        @media (max-width: 768px) {
            .container {
                padding: 20px 16px;
            }
            
            .post-header {
                padding: 20px;
            }
            
            .editor-container {
                padding: 20px;
            }
            
            .post-title {
                font-size: 32px;
            }
            
            .gh-block-controls {
                left: -40px;
            }
            
            .gh-block-menu {
                width: 28px;
                height: 28px;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="/ghost/admin" class="navbar-brand">Ghost</a>
        <div class="navbar-nav">
            <button class="btn btn-secondary" onclick="savePost('draft')">
                Save draft
            </button>
            <button class="btn btn-primary" onclick="savePost('published')">
                Publish
            </button>
        </div>
    </nav>

    <div class="container">
        <div class="post-header">
            <textarea id="postTitle" class="post-title" placeholder="Post title" 
                oninput="autoResizeTextarea(this)"></textarea>
            
            <div class="post-meta">
                <span>Draft • </span>
                <span id="wordCount">1 word</span>
            </div>
        </div>

        <div class="editor-container" id="editorContainer">
            <div class="gh-block" onclick="selectBlock(this); event.stopPropagation();">
                <div class="gh-block-controls">
                    <button class="gh-block-menu" onclick="showPlusMenu(this, event)">
                        <i class="ti ti-plus"></i>
                    </button>
                </div>
                <textarea class="text-block" placeholder="Begin writing your story..." 
                    oninput="autoResizeTextarea(this); updateWordCount(); autoSave();"></textarea>
            </div>
            
            <button class="add-block-btn" onclick="addNewBlock()">
                <i class="ti ti-plus"></i> Add block
            </button>
        </div>
    </div>

    <div class="floating-toolbar" id="floatingToolbar">
        <button class="toolbar-btn" onclick="formatText('bold')" title="Bold">
            <i class="ti ti-bold"></i>
        </button>
        <button class="toolbar-btn" onclick="formatText('italic')" title="Italic">
            <i class="ti ti-italic"></i>
        </button>
        <button class="toolbar-btn" onclick="insertLink()" title="Link">
            <i class="ti ti-link"></i>
        </button>
    </div>

    <script>
        let saveTimeout;
        let selectedBlock = null;
        
        document.addEventListener('DOMContentLoaded', function() {
            initializeEditor();
        });

        function initializeEditor() {
            setupClickHandlers();
            setupKeyboardShortcuts();
            setupSelectionToolbar();
            updateWordCount();
            
            // Auto-resize existing textareas
            document.querySelectorAll('.text-block').forEach(textarea => {
                autoResizeTextarea(textarea);
            });
        }

        function setupClickHandlers() {
            // Global click handler for deselecting blocks
            document.addEventListener('click', function(e) {
                if (!e.target.closest('.gh-block') && 
                    !e.target.closest('.image-block-container') &&
                    !e.target.closest('.plus-menu') &&
                    !e.target.closest('.image-url-panel')) {
                    
                    deselectAllBlocks();
                    
                    // Hide plus menus
                    document.querySelectorAll('.plus-menu').forEach(menu => {
                        menu.style.display = 'none';
                    });
                }
            });

            // Image block click handler
            document.addEventListener('click', function(e) {
                if (e.target.closest('.image-block-container')) {
                    e.stopPropagation();
                    selectBlock(e.target.closest('.image-block-container'));
                }
            });
        }

        function setupKeyboardShortcuts() {
            document.addEventListener('keydown', function(e) {
                // Delete selected blocks
                if (e.key === 'Delete' || e.key === 'Backspace') {
                    if (selectedBlock && !isEditingText()) {
                        e.preventDefault();
                        removeBlock(selectedBlock);
                    }
                }
                
                // Format shortcuts
                if (e.ctrlKey || e.metaKey) {
                    if (e.key === 'b') {
                        e.preventDefault();
                        formatText('bold');
                    } else if (e.key === 'i') {
                        e.preventDefault();
                        formatText('italic');
                    } else if (e.key === 'k') {
                        e.preventDefault();
                        insertLink();
                    }
                }
            });
        }

        function selectBlock(block) {
            deselectAllBlocks();
            block.classList.add('selected');
            selectedBlock = block;
        }

        function deselectAllBlocks() {
            document.querySelectorAll('.selected').forEach(block => {
                block.classList.remove('selected');
            });
            selectedBlock = null;
        }

        function showPlusMenu(button, event) {
            event.stopPropagation();
            
            // Hide other menus
            document.querySelectorAll('.plus-menu').forEach(menu => {
                menu.style.display = 'none';
            });
            
            const existingMenu = button.parentNode.querySelector('.plus-menu');
            if (existingMenu) {
                existingMenu.remove();
            }
            
            const menu = document.createElement('div');
            menu.className = 'plus-menu';
            menu.innerHTML = `
                <button class="menu-item" onclick="insertHeading(this)">
                    <i class="ti ti-h-1"></i>
                    Heading
                </button>
                <button class="menu-item" onclick="addImageBlock(this)">
                    <i class="ti ti-photo"></i>
                    Image
                </button>
                <button class="menu-item" onclick="insertQuote(this)">
                    <i class="ti ti-blockquote"></i>
                    Quote
                </button>
                <button class="menu-item" onclick="insertList(this)">
                    <i class="ti ti-list"></i>
                    List
                </button>
            `;
            
            button.parentNode.appendChild(menu);
            menu.style.display = 'flex';
        }

        function addNewBlock() {
            const container = document.getElementById('editorContainer');
            const addBtn = container.querySelector('.add-block-btn');
            
            const newBlock = document.createElement('div');
            newBlock.className = 'gh-block';
            newBlock.onclick = function(e) { selectBlock(this); e.stopPropagation(); };
            newBlock.innerHTML = `
                <div class="gh-block-controls">
                    <button class="gh-block-menu" onclick="showPlusMenu(this, event)">
                        <i class="ti ti-plus"></i>
                    </button>
                </div>
                <textarea class="text-block" placeholder="Continue writing..." 
                    oninput="autoResizeTextarea(this); updateWordCount(); autoSave();"></textarea>
            `;
            
            container.insertBefore(newBlock, addBtn);
            
            // Focus the new textarea
            const textarea = newBlock.querySelector('.text-block');
            textarea.focus();
            selectBlock(newBlock);
        }

        function addImageBlock(button) {
            const block = button.closest('.gh-block');
            const container = document.createElement('div');
            container.className = 'image-block-container';
            container.onclick = function(e) { selectBlock(this); e.stopPropagation(); };
            container.innerHTML = `
                <div class="image-url-panel">
                    <input type="text" class="image-url-input" placeholder="Paste or type an image URL..." autofocus>
                    <div class="image-url-actions">
                        <button class="btn btn-secondary" onclick="cancelImageUpload(this)">Cancel</button>
                        <button class="btn btn-primary" onclick="confirmImageUpload(this)">Add image</button>
                    </div>
                </div>
            `;
            
            block.parentNode.insertBefore(container, block.nextSibling);
            
            // Hide plus menu
            const menu = button.closest('.plus-menu');
            if (menu) menu.style.display = 'none';
            
            // Focus input
            container.querySelector('.image-url-input').focus();
        }

        function confirmImageUpload(button) {
            const panel = button.closest('.image-url-panel');
            const container = panel.parentNode;
            const url = panel.querySelector('.image-url-input').value.trim();
            
            if (!url) {
                showNotification('Please enter an image URL');
                return;
            }
            
            container.innerHTML = `
                <img src="${url}" alt="" class="image-preview" onerror="handleImageError(this)">
                <div class="image-toolbar">
                    <button class="toolbar-btn" onclick="removeBlock(this.closest('.image-block-container'))" title="Delete">
                        <i class="ti ti-trash"></i>
                    </button>
                </div>
                <div class="image-caption" contenteditable="true" onclick="editCaption(this)"></div>
            `;
            
            selectBlock(container);
            showNotification('Image added');
        }

        function cancelImageUpload(button) {
            const container = button.closest('.image-block-container');
            container.remove();
        }

        function handleImageError(img) {
            showNotification('Failed to load image');
            img.closest('.image-block-container').remove();
        }

        function removeBlock(block) {
            if (block === selectedBlock) {
                selectedBlock = null;
            }
            showNotification('Block deleted');
            block.remove();
            updateWordCount();
        }

        function insertHeading(button) {
            const block = button.closest('.gh-block');
            const textarea = block.querySelector('.text-block');
            textarea.value = '# Heading';
            textarea.style.fontSize = '28px';
            textarea.style.fontWeight = '600';
            autoResizeTextarea(textarea);
            
            // Hide menu
            const menu = button.closest('.plus-menu');
            if (menu) menu.style.display = 'none';
            
            textarea.focus();
        }

        function insertQuote(button) {
            const block = button.closest('.gh-block');
            const textarea = block.querySelector('.text-block');
            textarea.value = '> Quote text';
            textarea.style.fontStyle = 'italic';
            textarea.style.borderLeft = '4px solid #e3e8ee';
            textarea.style.paddingLeft = '20px';
            autoResizeTextarea(textarea);
            
            // Hide menu
            const menu = button.closest('.plus-menu');
            if (menu) menu.style.display = 'none';
            
            textarea.focus();
        }

        function insertList(button) {
            const block = button.closest('.gh-block');
            const textarea = block.querySelector('.text-block');
            textarea.value = '• List item\n• List item\n• List item';
            autoResizeTextarea(textarea);
            
            // Hide menu
            const menu = button.closest('.plus-menu');
            if (menu) menu.style.display = 'none';
            
            textarea.focus();
        }

        function editCaption(caption) {
            caption.classList.add('editing');
            caption.focus();
        }

        function setupSelectionToolbar() {
            const toolbar = document.getElementById('floatingToolbar');
            
            document.addEventListener('mouseup', function(e) {
                if (e.target.closest('.text-block')) {
                    const textarea = e.target;
                    const start = textarea.selectionStart;
                    const end = textarea.selectionEnd;
                    
                    if (start !== end) {
                        const rect = textarea.getBoundingClientRect();
                        toolbar.style.display = 'flex';
                        toolbar.style.left = rect.left + (rect.width / 2) - (toolbar.offsetWidth / 2) + 'px';
                        toolbar.style.top = rect.top - toolbar.offsetHeight - 8 + window.scrollY + 'px';
                    } else {
                        toolbar.style.display = 'none';
                    }
                } else {
                    toolbar.style.display = 'none';
                }
            });
            
            document.addEventListener('click', function(e) {
                if (!e.target.closest('.floating-toolbar')) {
                    toolbar.style.display = 'none';
                }
            });
        }

        function formatText(command) {
            // This would format selected text in the active textarea
            showNotification('Text formatted');
        }

        function insertLink() {
            const url = prompt('Enter URL:');
            if (url) {
                showNotification('Link inserted');
            }
        }

        function isEditingText() {
            const activeElement = document.activeElement;
            return activeElement && (
                activeElement.tagName === 'TEXTAREA' ||
                activeElement.tagName === 'INPUT' ||
                activeElement.contentEditable === 'true'
            );
        }

        function autoSave() {
            clearTimeout(saveTimeout);
            saveTimeout = setTimeout(() => {
                savePost('draft', false);
            }, 2000);
        }

        function showNotification(message) {
            const notification = document.createElement('div');
            notification.className = 'notification';
            notification.textContent = message;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.remove();
            }, 3000);
        }

        function autoResizeTextarea(textarea) {
            textarea.style.height = 'auto';
            textarea.style.height = Math.max(textarea.scrollHeight, 50) + 'px';
        }

        function updateWordCount() {
            const textareas = document.querySelectorAll('.text-block');
            let totalWords = 0;
            
            textareas.forEach(textarea => {
                const words = textarea.value.trim().split(/\s+/).filter(word => word.length > 0);
                totalWords += words.length;
            });
            
            document.getElementById('wordCount').textContent = totalWords + (totalWords === 1 ? ' word' : ' words');
        }

        function savePost(status = 'draft', showNotification = true) {
            const title = document.getElementById('postTitle').value;
            const blocks = [];
            
            document.querySelectorAll('.text-block').forEach(textarea => {
                if (textarea.value.trim()) {
                    blocks.push({
                        type: 'text',
                        content: textarea.value
                    });
                }
            });
            
            document.querySelectorAll('.image-block-container .image-preview').forEach(img => {
                const caption = img.parentNode.querySelector('.image-caption');
                blocks.push({
                    type: 'image',
                    src: img.src,
                    caption: caption ? caption.textContent : ''
                });
            });
            
            console.log('Saving post:', { title, blocks, status });
            
            if (showNotification) {
                showNotification('Post saved as ' + status);
            }
        }
    </script>
</body>
</html>