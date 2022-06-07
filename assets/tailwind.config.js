// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
    '../deps/petal_components/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.orange,
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ],
  darkMode: "class"
}
