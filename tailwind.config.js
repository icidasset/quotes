import defaultTheme from "tailwindcss/defaultTheme.js"


export default {

  /////////////////////////////////////////
  // THEME ////////////////////////////////
  /////////////////////////////////////////

  theme: {

    // Fonts
    // -----

    fontFamily: {
      ...defaultTheme.fontFamily,

      body: [ "Roboto", ...defaultTheme.fontFamily.sans ],
      display: [ "Playfair Display", ...defaultTheme.fontFamily.serif ]
    },

    // Inset
    // -----

    inset: {
      "auto": "auto",
      "0": 0,
      "1/2": "50%",
      "full": "100%"
    },

    // Extensions
    // ==========

    extend: {

      screens: {
        dark: { raw: "(prefers-color-scheme: dark)" }
      },

    },

  },


  /////////////////////////////////////////
  // VARIANTS /////////////////////////////
  /////////////////////////////////////////

  variants: {},


  /////////////////////////////////////////
  // PLUGINS //////////////////////////////
  /////////////////////////////////////////

  plugins: []

}
