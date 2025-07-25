/**
 * Theme Manager - Light/Dark Mode Support
 * Material 3 + Apple HIG Implementation
 */

class ThemeManager {
    constructor() {
        this.STORAGE_KEY = 'ghost-theme-preference';
        this.THEMES = {
            LIGHT: 'light',
            DARK: 'dark',
            AUTO: 'auto'
        };
        
        this.currentTheme = this.getStoredTheme();
        this.init();
    }

    init() {
        // Set initial theme
        this.applyTheme(this.currentTheme);
        
        // Listen for system theme changes
        if (window.matchMedia) {
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
                if (this.currentTheme === this.THEMES.AUTO) {
                    this.applySystemTheme();
                }
            });
        }

        // Create theme toggle button if it doesn't exist
        this.createThemeToggle();
        
        // Add keyboard shortcut (Cmd/Ctrl + Shift + D)
        document.addEventListener('keydown', (e) => {
            if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key === 'D') {
                e.preventDefault();
                this.toggleTheme();
            }
        });
    }

    getStoredTheme() {
        try {
            const stored = localStorage.getItem(this.STORAGE_KEY);
            return stored && Object.values(this.THEMES).includes(stored) 
                ? stored 
                : this.THEMES.AUTO;
        } catch (e) {
            return this.THEMES.AUTO;
        }
    }

    getEffectiveTheme() {
        if (this.currentTheme === this.THEMES.AUTO) {
            return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches 
                ? this.THEMES.DARK 
                : this.THEMES.LIGHT;
        }
        return this.currentTheme;
    }

    applyTheme(theme) {
        const effectiveTheme = theme === this.THEMES.AUTO 
            ? this.getEffectiveTheme() 
            : theme;
        
        // Remove existing theme classes
        document.documentElement.classList.remove('theme-light', 'theme-dark');
        
        // Add new theme class
        document.documentElement.classList.add(`theme-${effectiveTheme}`);
        
        // Set data attribute for CSS targeting
        document.documentElement.setAttribute('data-theme', effectiveTheme);
        
        // Update meta theme-color for mobile browsers
        this.updateMetaThemeColor(effectiveTheme);
        
        // Dispatch theme change event
        document.dispatchEvent(new CustomEvent('themechange', {
            detail: { 
                theme: effectiveTheme, 
                preference: theme,
                isSystemPreference: theme === this.THEMES.AUTO
            }
        }));
        
        // Update theme toggle button
        this.updateThemeToggle();
        
        // Apply Material 3 elevation adjustments for dark mode
        this.adjustElevationForTheme(effectiveTheme);
    }

    applySystemTheme() {
        this.applyTheme(this.THEMES.AUTO);
    }

    setTheme(theme) {
        if (!Object.values(this.THEMES).includes(theme)) {
            console.warn(`Invalid theme: ${theme}`);
            return;
        }
        
        this.currentTheme = theme;
        
        try {
            localStorage.setItem(this.STORAGE_KEY, theme);
        } catch (e) {
            console.warn('Failed to save theme preference:', e);
        }
        
        this.applyTheme(theme);
    }

    toggleTheme() {
        const themes = Object.values(this.THEMES);
        const currentIndex = themes.indexOf(this.currentTheme);
        const nextIndex = (currentIndex + 1) % themes.length;
        this.setTheme(themes[nextIndex]);
    }

    updateMetaThemeColor(theme) {
        let themeColorMeta = document.querySelector('meta[name="theme-color"]');
        
        if (!themeColorMeta) {
            themeColorMeta = document.createElement('meta');
            themeColorMeta.name = 'theme-color';
            document.head.appendChild(themeColorMeta);
        }
        
        // Material 3 surface colors
        const colors = {
            light: '#FFFBFE',
            dark: '#10151C'
        };
        
        themeColorMeta.content = colors[theme];
    }

    adjustElevationForTheme(theme) {
        // Material 3 recommends different elevation values for dark theme
        const elevationAdjustments = document.createElement('style');
        elevationAdjustments.id = 'theme-elevation-adjustments';
        
        // Remove existing adjustments
        const existing = document.getElementById('theme-elevation-adjustments');
        if (existing) {
            existing.remove();
        }
        
        if (theme === this.THEMES.DARK) {
            elevationAdjustments.textContent = `
                .md3-card {
                    background-color: var(--md-sys-color-surface-variant);
                }
                .ui.card.status-card {
                    background-color: var(--md-sys-color-surface-variant);
                    border-color: var(--md-sys-color-outline-variant);
                }
            `;
        }
        
        document.head.appendChild(elevationAdjustments);
    }

    createThemeToggle() {
        // Check if toggle already exists
        if (document.getElementById('theme-toggle')) {
            return;
        }

        const toggle = document.createElement('button');
        toggle.id = 'theme-toggle';
        toggle.className = 'md3-button md3-button-text md3-state-layer';
        toggle.setAttribute('aria-label', 'Toggle theme');
        toggle.setAttribute('title', 'Toggle theme (Ctrl+Shift+D)');
        
        // Style the toggle button
        toggle.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1000;
            width: 48px;
            height: 48px;
            border-radius: var(--md-sys-shape-corner-full);
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            background: var(--md-sys-color-surface-variant);
            border: 1px solid var(--md-sys-color-outline-variant);
            color: var(--md-sys-color-on-surface-variant);
            transition: all var(--md-sys-motion-duration-short4) var(--md-sys-motion-easing-standard);
        `;
        
        toggle.addEventListener('click', () => {
            this.toggleTheme();
        });
        
        document.body.appendChild(toggle);
    }

    updateThemeToggle() {
        const toggle = document.getElementById('theme-toggle');
        if (!toggle) return;
        
        const icons = {
            [this.THEMES.LIGHT]: '🌙',
            [this.THEMES.DARK]: '☀️',
            [this.THEMES.AUTO]: '🔄'
        };
        
        const labels = {
            [this.THEMES.LIGHT]: 'Switch to dark mode',
            [this.THEMES.DARK]: 'Switch to auto mode', 
            [this.THEMES.AUTO]: 'Switch to light mode'
        };
        
        toggle.textContent = icons[this.currentTheme];
        toggle.setAttribute('aria-label', labels[this.currentTheme]);
        toggle.setAttribute('title', `${labels[this.currentTheme]} (Ctrl+Shift+D)`);
    }

    // Public API
    getCurrentTheme() {
        return this.currentTheme;
    }

    getEffectiveThemeValue() {
        return this.getEffectiveTheme();
    }

    isSystemPreference() {
        return this.currentTheme === this.THEMES.AUTO;
    }

    isDarkMode() {
        return this.getEffectiveTheme() === this.THEMES.DARK;
    }

    isLightMode() {
        return this.getEffectiveTheme() === this.THEMES.LIGHT;
    }

    // Animation utilities for theme transitions
    animateThemeTransition() {
        // Add smooth transition class temporarily
        document.documentElement.classList.add('theme-transitioning');
        
        setTimeout(() => {
            document.documentElement.classList.remove('theme-transitioning');
        }, 300);
    }

    // Utility to get current theme colors
    getCurrentColors() {
        const style = getComputedStyle(document.documentElement);
        return {
            primary: style.getPropertyValue('--md-sys-color-primary').trim(),
            onPrimary: style.getPropertyValue('--md-sys-color-on-primary').trim(),
            surface: style.getPropertyValue('--md-sys-color-surface').trim(),
            onSurface: style.getPropertyValue('--md-sys-color-on-surface').trim(),
            background: style.getPropertyValue('--md-sys-color-background').trim(),
            onBackground: style.getPropertyValue('--md-sys-color-on-background').trim()
        };
    }
}

// Initialize theme manager when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.themeManager = new ThemeManager();
    });
} else {
    window.themeManager = new ThemeManager();
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ThemeManager;
}