/** @type {import('tailwindcss').Config} */


export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'body': ['VT323', 'mono'],
      },
      colors: {
        "terminal-green": "#4af626"
      }
    },
  },
  plugins: [],
}

