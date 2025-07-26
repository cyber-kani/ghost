/** @type {import('tailwindcss').Config} */
const plugin = require('tailwindcss/plugin');
// const colors = require('tailwindcss/colors');

module.exports = {
	darkMode: 'class',
	content: ['node_modules/preline/dist/*.js','./src/**/*.html'],
	
	theme: {
		fontFamily: {
			sans: ['Plus Jakarta Sans', 'sans-serif'],
		},
		extend: {
			boxShadow: {
				'md': '0px 2px 6px rgba(37,83,185,0.1)',
				'dark-md': '0px 2px 6px rgba(37,83,185,0.1)',
				'sm':'0 0.125rem 0.25rem rgba(0, 0, 0, 0.075)'
			},
			borderRadius: {
				md: "18px",
				sm:"8px",
				xs:"4px",
			},
			container: {
				center: true,
			},
			fontSize: {
				"fs_15": "15px",
				"fs_13": "13px",
				"fs_12": "12px",
				"fs_10": "10px",
				"fs_21": "21px",
				"fs_28": "28px",
			},

			colors: {

				//Light Colors Variables
				primary:"var(--color-primary)",
				secondary: "var(--color-secondary)",
				info: "var(--color-info)",
				success: "var(--color-success)",
				warning: "var(--color-warning)",
				error: "var(--color-error)",
				body:"var(--color-body)",
				darkbody:"var(--color-darkbody)",
				lightprimary: "var(--color-lightprimary)",
				lightsecondary: "var(--color-lightsecondary)",
				lightsuccess: "var(--color-lightsuccess)",
				lighterror: "var(--color-lighterror)",
				lightinfo: "var(--color-lightinfo)",
				lightwarning: "var(--color-lightwarning)",
				border:"var(--color-border)",
				bordergray:"var(--color-bordergray)",
				lightgray:"var( --color-lightgray)",
				bodytext:"var( --color-bodytext)",
				indigo:"var( --color-indigo)",
				lightindigo:"var( --color-lightindigo)",
				info:"var( --color-info)",
	
				
				//Dark Colors Variables
				dark: "var(--color-dark)",
				link:"var(--color-link)",
				darklink:"var(--color-darklink)",
				darkborder: "var(--color-darkborder)",
				darkgray:"var(--color-darkgray)",
				darkinfo: "var(--color-darkinfo)",
				darksuccess: "var(--color-darksuccess)",
				darkwarning: "var(--color-darkwarning)",
				darkerror: "var(--color-darkerror)",
				darkprimary:"var(--color-darkprimary)",
				darksecondary:"var(--color-darksecondary)",
				darkindigo:"var( --color-darkindigo)",
				darkinfo:"var( --color-darkinfo)",
				bghover:"var(--color-bghover)",

				primaryemphasis: "var(--color-primary-emphasis)",
				secondaryemphasis: "var(--color-secondary-emphasis)",
				warningemphasis: "var(--color-warning-emphasis)",
				erroremphasis: "var(--color-error-emphasis)",
				successemphasis: "var(--color-success-emphasis)",
		
			},
		},

		

	},
	variants: {},
	plugins: [
		require('@tailwindcss/forms')({
			strategy: 'base', // only generate global styles
		}),
		require('@tailwindcss/typography'),
		require('preline/plugin'),
	],
};
