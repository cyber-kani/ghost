<cfset pageTitle = "Dashboard">
<cfset variables.loadApexCharts = true>
<cfinclude template="includes/header.cfm">

<!-- Dashboard Content -->
<div class="pt-6 space-y-12">
    
    <!-- Top Row -->
    <div class="grid grid-cols-12 gap-6">
        <!-- Congratulations Admin Card -->
        <div class="lg:col-span-6 col-span-12">
            <div class="card overflow-hidden">
                <div class="card-body relative">
                    <h5 class="card-title">Congratulations Admin</h5>
                    <p class="card-subtitle">Your blog has grown 38% more this month</p>
                    <div class="mt-6">
                        <ul class="mb-0">
                            <li class="flex items-center mb-5 gap-4">
                                <div class="bg-lightsuccess dark:bg-darksuccess h-12 w-12 rounded-full flex items-center justify-center">
                                    <iconify-icon icon="solar:document-text-line-duotone" class="text-2xl text-success"></iconify-icon>
                                </div>
                                <div>
                                    <h6 class="text-base">45 new posts</h6>
                                    <p class="font-medium">Published this month</p>
                                </div>
                            </li>
                            <li class="flex items-center mb-5 gap-4">
                                <div class="bg-lightwarning dark:bg-darkwarning h-12 w-12 rounded-full flex items-center justify-center">
                                    <iconify-icon icon="solar:users-group-two-rounded-line-duotone" class="text-2xl text-warning"></iconify-icon>
                                </div>
                                <div>
                                    <h6 class="text-base">234 new members</h6>
                                    <p class="font-medium">Joined this week</p>
                                </div>
                            </li>
                            <li class="flex items-center mb-5 gap-4">
                                <div class="bg-lightindigo dark:bg-darkindigo h-12 w-12 rounded-full flex items-center justify-center">
                                    <iconify-icon icon="solar:chat-round-dots-line-duotone" class="text-2xl text-indigo"></iconify-icon>
                                </div>
                                <div>
                                    <h6 class="text-base">892 comments</h6>
                                    <p class="font-medium">Total engagement</p>
                                </div>
                            </li>
                            <li class="flex items-center gap-4">
                                <div class="bg-lightprimary dark:bg-darkprimary h-12 w-12 rounded-full flex items-center justify-center">
                                    <iconify-icon icon="solar:eye-line-duotone" class="text-2xl text-primary"></iconify-icon>
                                </div>
                                <div>
                                    <h6 class="text-base">1,456 unique visitors</h6>
                                    <p class="font-medium">Today</p>
                                </div>
                            </li>
                        </ul>
                        <div class="md:absolute relative md:end-0 -end-7 md:bottom-0 -bottom-8">
                            <img src="/ghost/admin/assets/images/backgrounds/man-working-on-laptop.png" alt="" class="w-full">
                        </div>
                    </div>
                </div>
                <div class="card-body border-t border-border dark:border-darkborder">
                    <div class="grid grid-cols-3 gap-4">
                        <!-- Total Posts -->
                        <div class="text-center">
                            <div class="w-12 h-12 bg-lightprimary dark:bg-primary/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                                <i class="ti ti-article text-2xl text-primary"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-gray-800 dark:text-white mb-1">156</h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400">Total Posts</p>
                        </div>
                        
                        <!-- Page Views -->
                        <div class="text-center">
                            <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center mx-auto mb-3">
                                <i class="ti ti-eye text-2xl text-secondary"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-gray-800 dark:text-white mb-1">45.2K</h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400">Page Views</p>
                        </div>
                        
                        <!-- Total Members -->
                        <div class="text-center">
                            <div class="w-12 h-12 bg-green-100 dark:bg-green-900/30 rounded-lg flex items-center justify-center mx-auto mb-3">
                                <i class="ti ti-users text-2xl text-success"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-gray-800 dark:text-white mb-1">2,345</h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400">Total Members</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Latest Posts and Monthly Views Container -->
        <div class="lg:col-span-6 col-span-12">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Latest Posts Card -->
                <div class="card">
                    <div class="card-body">
                        <div class="flex items-baseline justify-between mb-4">
                            <div>
                                <h5 class="card-title">Latest Posts</h5>
                                <p class="card-subtitle">Last 7 days</p>
                            </div>
                            <div class="sm:mt-0">
                                <div class="badge bg-lightsuccess dark:bg-darksuccess border-success text-success">+5 new</div>
                            </div>
                        </div>
                        <div class="my-8">
                            <div class="flex justify-between items-center">
                                <h5 class="text-xl">156</h5>
                                <p class="text-dark dark:text-white font-medium text-fs_15">200 Total</p>
                            </div>
                            <div class="flex my-1.5 w-full h-2 bg-lightprimary dark:bg-darkprimary rounded-md overflow-hidden" role="progressbar" aria-valuenow="78" aria-valuemin="0" aria-valuemax="100">
                                <div class="flex flex-col justify-center overflow-hidden bg-primary text-xs text-white text-center whitespace-nowrap transition duration-500" style="width: 78%"></div>
                            </div>
                            <p class="font-medium">Published: 156/200</p>
                        </div>
                        <div>
                            <h6 class="card-title text-fs_15">Recent Authors</h6>
                            <div class="flex mt-5">
                                <a href="javascript:void(0)" class="relative">
                                    <img src="https://ui-avatars.com/api/?name=John+Doe&background=5D87FF&color=fff" class="rounded-full h-11 w-11 border-2 border-body dark:border-dark" alt="user" />
                                </a>
                                <a href="javascript:void(0)" class="relative -ms-2">
                                    <img src="https://ui-avatars.com/api/?name=Jane+Smith&background=49BEFF&color=fff" class="rounded-full h-11 w-11 border-2 border-body dark:border-dark" alt="user" />
                                </a>
                                <a href="javascript:void(0)" class="relative -ms-2">
                                    <img src="https://ui-avatars.com/api/?name=Mike+Johnson&background=13DEB9&color=fff" class="rounded-full h-11 w-11 border-2 border-body dark:border-dark" alt="user" />
                                </a>
                                <a href="javascript:void(0)" class="relative -ms-2">
                                    <img src="https://ui-avatars.com/api/?name=Sarah+Lee&background=FFAE1F&color=fff" class="rounded-full h-11 w-11 border-2 border-body dark:border-dark" alt="user" />
                                </a>
                                <a href="javascript:void(0)" class="relative -ms-2">
                                    <div class="rounded-full h-11 w-11 border-2 border-body dark:border-dark flex justify-center items-center bg-lightprimary dark:bg-darkprimary text-dark dark:text-white font-medium hover:text-primary">
                                        2+
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Monthly Views Card -->
                <div class="card" style="height: calc(100% + 30px);">
                    <div class="card-body">
                        <div class="flex items-center justify-between mb-4">
                            <div>
                                <h5 class="card-title">Monthly Views</h5>
                                <p class="card-subtitle">Last 30 days</p>
                            </div>
                            <div class="sm:mt-0 mt-4">
                                <h6 class="text-lg">45,234</h6>
                                <div class="badge bg-lightsuccess dark:bg-darksuccess border-success text-success">+12.5%</div>
                            </div>
                        </div>
                        <div id="total-orders" class="total-orders-chart my-1 -me-8"></div>
                        <div class="flex items-center justify-between mb-2">
                            <div class="flex items-center">
                                <i class="ti ti-circle text-primary text-fs_15 me-2"></i>
                                <p class="mb-0 font-medium">Organic</p>
                            </div>
                            <p class="mb-0 font-medium">65%</p>
                        </div>
                        <div class="flex items-center justify-between">
                            <div class="flex items-center">
                                <i class="ti ti-circle text-light text-fs_15 me-2"></i>
                                <p class="mb-0 font-medium">Social</p>
                            </div>
                            <p class="mb-0 font-medium">35%</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Second Row -->
    <div class="grid grid-cols-1 gap-6">
        <!-- Performance Chart -->
        <div class="card mt-8">
            <div class="card-body">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="card-title">Blog Performance</h3>
                    <div class="text-sm text-gray-500">Last 9 months</div>
                </div>
                <div id="performanceChart"></div>
            </div>
        </div>
        
        <!-- Traffic Distribution Chart -->
        <div class="card mt-8">
            <div class="card-body">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="card-title">Traffic Sources</h3>
                    <div class="text-sm text-gray-500">Current month</div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div id="trafficChart"></div>
                    <div id="trafficDistributionChart"></div>
                </div>
            </div>
        </div>
        
        <!-- Popular Posts -->
        <div class="card mt-8">
            <div class="card-body">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="card-title">Popular Posts</h3>
                    <a href="/ghost/admin/posts" class="text-sm text-primary hover:text-primary/80">View All</a>
                </div>
                
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <th class="text-left py-3 px-2 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Title</th>
                                <th class="text-left py-3 px-2 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Views</th>
                                <th class="text-left py-3 px-2 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="border-b border-gray-100 dark:border-gray-700/50">
                                <td class="py-3 px-2">
                                    <div>
                                        <p class="text-sm font-medium text-gray-800 dark:text-white">Getting Started with Ghost CMS</p>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">John Doe</p>
                                    </div>
                                </td>
                                <td class="py-3 px-2">
                                    <p class="text-sm text-gray-800 dark:text-white">2,345</p>
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-success dark:bg-green-900/30">Published</span>
                                </td>
                            </tr>
                            <tr class="border-b border-gray-100 dark:border-gray-700/50">
                                <td class="py-3 px-2">
                                    <div>
                                        <p class="text-sm font-medium text-gray-800 dark:text-white">10 Tips for Better Content</p>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">Jane Smith</p>
                                    </div>
                                </td>
                                <td class="py-3 px-2">
                                    <p class="text-sm text-gray-800 dark:text-white">1,890</p>
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-success dark:bg-green-900/30">Published</span>
                                </td>
                            </tr>
                            <tr class="border-b border-gray-100 dark:border-gray-700/50">
                                <td class="py-3 px-2">
                                    <div>
                                        <p class="text-sm font-medium text-gray-800 dark:text-white">SEO Best Practices 2024</p>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">Mike Johnson</p>
                                    </div>
                                </td>
                                <td class="py-3 px-2">
                                    <p class="text-sm text-gray-800 dark:text-white">1,567</p>
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-success dark:bg-green-900/30">Published</span>
                                </td>
                            </tr>
                            <tr>
                                <td class="py-3 px-2">
                                    <div>
                                        <p class="text-sm font-medium text-gray-800 dark:text-white">The Future of Blogging</p>
                                        <p class="text-xs text-gray-500 dark:text-gray-400">Sarah Lee</p>
                                    </div>
                                </td>
                                <td class="py-3 px-2">
                                    <p class="text-sm text-gray-800 dark:text-white">-</p>
                                </td>
                                <td class="py-3 px-2">
                                    <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-warning dark:bg-yellow-900/30">Draft</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
</div>

<!-- Charts Script -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Theme detection
    const isDarkMode = () => document.documentElement.classList.contains('dark');
    
    // Chart colors based on theme
    const getChartColors = () => ({
        primary: '#5D87FF',
        secondary: '#49BEFF',
        success: '#13DEB9',
        warning: '#FFAE1F',
        danger: '#FA896B',
        textColor: isDarkMode() ? '#e5e7eb' : '#374151',
        gridColor: isDarkMode() ? '#374151' : '#e5e7eb'
    });
    
    // Blog Performance Chart
    const performanceOptions = {
        series: [{
            name: 'Page Views',
            data: [3200, 4100, 3800, 5200, 4800, 5500, 6100, 5900, 6200]
        }, {
            name: 'Visitors',
            data: [1100, 1500, 1300, 1900, 1700, 2100, 2300, 2200, 2400]
        }],
        chart: {
            type: 'area',
            height: 350,
            toolbar: {
                show: false
            },
            fontFamily: 'Plus Jakarta Sans, sans-serif',
            foreColor: getChartColors().textColor
        },
        dataLabels: {
            enabled: false
        },
        stroke: {
            curve: 'smooth',
            width: 2
        },
        fill: {
            type: 'gradient',
            gradient: {
                shadeIntensity: 1,
                opacityFrom: 0.4,
                opacityTo: 0.1,
                stops: [0, 90, 100]
            }
        },
        xaxis: {
            categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'],
            axisBorder: {
                show: false
            },
            axisTicks: {
                show: false
            },
            labels: {
                style: {
                    colors: getChartColors().textColor
                }
            }
        },
        yaxis: {
            labels: {
                style: {
                    colors: getChartColors().textColor
                }
            }
        },
        grid: {
            borderColor: getChartColors().gridColor,
            strokeDashArray: 3
        },
        tooltip: {
            theme: isDarkMode() ? 'dark' : 'light',
            y: {
                formatter: function (val) {
                    return val.toLocaleString()
                }
            }
        },
        colors: [getChartColors().primary, getChartColors().secondary],
        legend: {
            position: 'top',
            horizontalAlign: 'right',
            labels: {
                colors: getChartColors().textColor
            }
        }
    };
    
    const performanceChart = new ApexCharts(document.querySelector("#performanceChart"), performanceOptions);
    performanceChart.render();
    
    // Traffic Distribution Chart
    const trafficOptions = {
        series: [65, 20, 10, 5],
        chart: {
            type: 'donut',
            height: 200,
            fontFamily: 'Plus Jakarta Sans, sans-serif',
            foreColor: getChartColors().textColor
        },
        labels: ['Organic', 'Social', 'Direct', 'Referral'],
        dataLabels: {
            enabled: false
        },
        colors: [getChartColors().primary, getChartColors().secondary, getChartColors().warning, getChartColors().success],
        legend: {
            show: false
        },
        plotOptions: {
            pie: {
                donut: {
                    size: '75%',
                }
            }
        },
        stroke: {
            width: 0
        },
        tooltip: {
            theme: isDarkMode() ? 'dark' : 'light'
        }
    };
    
    const trafficChart = new ApexCharts(document.querySelector("#trafficChart"), trafficOptions);
    trafficChart.render();
    
    // New Traffic Distribution Chart (top row)
    const trafficDistributionChart = new ApexCharts(document.querySelector("#trafficDistributionChart"), trafficOptions);
    trafficDistributionChart.render();
    
    // Update charts on theme change
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.attributeName === 'class') {
                // Update charts with new colors
                performanceChart.updateOptions({
                    chart: {
                        foreColor: getChartColors().textColor
                    },
                    xaxis: {
                        labels: {
                            style: {
                                colors: getChartColors().textColor
                            }
                        }
                    },
                    yaxis: {
                        labels: {
                            style: {
                                colors: getChartColors().textColor
                            }
                        }
                    },
                    grid: {
                        borderColor: getChartColors().gridColor
                    },
                    tooltip: {
                        theme: isDarkMode() ? 'dark' : 'light'
                    },
                    legend: {
                        labels: {
                            colors: getChartColors().textColor
                        }
                    }
                });
                
                trafficChart.updateOptions({
                    chart: {
                        foreColor: getChartColors().textColor
                    },
                    tooltip: {
                        theme: isDarkMode() ? 'dark' : 'light'
                    }
                });
                
                trafficDistributionChart.updateOptions({
                    chart: {
                        foreColor: getChartColors().textColor
                    },
                    tooltip: {
                        theme: isDarkMode() ? 'dark' : 'light'
                    }
                });
            }
        });
    });
    
    observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['class']
    });
});
</script>

<cfinclude template="includes/footer.cfm">