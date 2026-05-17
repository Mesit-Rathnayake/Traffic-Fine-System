/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          orange: '#ff7a00',
          light: '#ffb36b',
        },
        secondary: {
          dark: '#0b4f6c',
          medium: '#1b85b8',
        },
        neutral: {
          bg: '#f6f2ea',
        }
      },
    },
  },
  plugins: [],
}
