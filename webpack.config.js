const { name, version, author } = require("./package.json");
const { optimize, BannerPlugin, Compilation } = require("webpack");
module.exports = {
    entry: ["./src/main.mjs"],
    output: {
        filename: `${name}-${version}.bundle.js`,
    },
    plugins: [
        new optimize.LimitChunkCountPlugin({
            maxChunks: 1,
        }),
        new BannerPlugin({
            banner: `
// ==UserScript==
// @name        ${name}
// @namespace   Violentmonkey Scripts
// @match       *://*/*
// @grant       none
// @run-at      document-idle
// @version     ${version}
// @author      ${author}
// @description ${new Date().toString()}
// ==/UserScript==`,
            raw: true,
            stage: Compilation.PROCESS_ASSETS_STAGE_REPORT,
        }),
    ],
};
