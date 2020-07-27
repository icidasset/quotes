import defaultTheme from "tailwindcss/defaultTheme.js"


export default {

  /////////////////////////////////////////
  // THEME ////////////////////////////////
  /////////////////////////////////////////

  theme: {

    // Colors
    // ------

    colors: {
      base00: "#3b3228",
      base01: "#534636",
      base02: "#645240",
      base03: "#7e705a",
      base04: "#b8afad",
      base05: "#d0c8c6",
      base06: "#e9e1dd",
      base07: "#f5eeeb",

      red: "#cb6077",
      orange: "#d28b71",
      yellow: "#f4bc87",
      green: "#beb55b",
      teal: "#7bbda4",
      blue: "#8ab3b5",
      purple: "#a89bb9",
      brown: "#bb9584",

      black: "#000",
      white: "#fff",

      inherit: "inherit"
    },

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

    // Opacity
    // -------

    opacity: {
      "0": "0",
      "025": ".025",
      "05": ".05",
      "075": ".075",
      "10": ".1",
      "20": ".2",
      "25": ".25",
      "30": ".3",
      "40": ".4",
      "50": ".5",
      "60": ".6",
      "70": ".7",
      "75": ".75",
      "80": ".8",
      "90": ".9",
      "100": "1",
    },

    // Extensions
    // ==========

    extend: {

      fontSize: {
        xxs: "0.6875rem"
      },

      screens: {
        dark: { raw: "(prefers-color-scheme: dark)" }
      },

      letterSpacing: {
        "pushing-it": "0.125em"
      }

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
