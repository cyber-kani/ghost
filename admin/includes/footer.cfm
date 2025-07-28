                        </div>
                    </div>
                </div>
            </div>
            <!--  Main wrapper End -->
        </div>
    </main>
    
    <!-- Preline UI -->
    <script src="https://cdn.jsdelivr.net/npm/preline@2.0.2/dist/preline.js"></script>
    
    <!-- ApexCharts - Only load on dashboard pages -->
    <cfif structKeyExists(variables, "loadApexCharts") AND variables.loadApexCharts>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.min.js"></script>
    </cfif>
    
    <!-- Theme Toggle Script -->
    <script>
        // Initialize Preline components first
        window.addEventListener('load', () => {
            if (typeof HSStaticMethods !== 'undefined') {
                HSStaticMethods.autoInit();
            }
        });
        
        // Function to apply theme
        function applyTheme(theme) {
            if (theme === 'dark') {
                document.documentElement.classList.add('dark');
                localStorage.setItem('hs-theme', 'dark');
            } else {
                document.documentElement.classList.remove('dark');
                localStorage.setItem('hs-theme', 'light');
            }
        }
        
        // Check current theme and apply on page load
        const currentTheme = localStorage.getItem('hs-theme') || 'light';
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
        
        // Listen for theme changes from other tabs
        window.addEventListener('storage', (e) => {
            if (e.key === 'hs-theme') {
                applyTheme(e.newValue || 'light');
            }
        });
    </script>
</body>
</html>