                        </div>
                    </div>
                </div>
            </div>
            <!--  Main wrapper End -->
        </div>
    </main>
    
    <!-- Theme Toggle Script (without Preline) -->
    <script>
        // Function to apply theme
        function applyTheme(theme) {
            if (theme === 'dark') {
                document.documentElement.classList.add('dark');
                localStorage.setItem('hs-theme', 'dark');
                localStorage.setItem('theme', 'dark'); // Keep both for compatibility
            } else {
                document.documentElement.classList.remove('dark');
                localStorage.setItem('hs-theme', 'light');
                localStorage.setItem('theme', 'light'); // Keep both for compatibility
            }
        }
        
        // Check current theme and apply on page load
        const currentTheme = localStorage.getItem('hs-theme') || localStorage.getItem('theme') || 'light';
        applyTheme(currentTheme);
        
        // Add click handlers for theme toggle buttons
        document.addEventListener('DOMContentLoaded', () => {
            const darkButton = document.getElementById('dark-layout');
            const lightButton = document.getElementById('light-layout');
            
            if (darkButton) {
                darkButton.addEventListener('click', () => {
                    applyTheme('dark');
                });
            }
            
            if (lightButton) {
                lightButton.addEventListener('click', () => {
                    applyTheme('light');
                });
            }
        });
    </script>
</body>
</html>