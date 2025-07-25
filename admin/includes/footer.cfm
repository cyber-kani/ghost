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
        // Theme toggle functionality
        const themeToggleBtn = document.getElementById('theme-toggle');
        const htmlElement = document.documentElement;
        
        // Check for saved theme preference or default to 'light'
        const currentTheme = localStorage.getItem('theme') || 'light';
        if (currentTheme === 'dark') {
            htmlElement.classList.remove('light');
            htmlElement.classList.add('dark');
        }
        
        if (themeToggleBtn) {
            themeToggleBtn.addEventListener('click', function() {
                if (htmlElement.classList.contains('dark')) {
                    htmlElement.classList.remove('dark');
                    htmlElement.classList.add('light');
                    localStorage.setItem('theme', 'light');
                } else {
                    htmlElement.classList.remove('light');
                    htmlElement.classList.add('dark');
                    localStorage.setItem('theme', 'dark');
                }
            });
        }
        
        // Initialize Preline components
        window.addEventListener('load', () => {
            if (typeof HSStaticMethods !== 'undefined') {
                HSStaticMethods.autoInit();
            }
        });
    </script>
</body>
</html>