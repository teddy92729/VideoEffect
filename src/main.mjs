import { VideoApp } from "./VideoApp.mjs";
import "pixi.js/unsafe-eval";
import { log } from "./utils.mjs";

let cache = new Map();

let observer = new MutationObserver((mutations) => {
    for (let mutation of mutations) {
        for (let node of mutation.addedNodes) {
            if (node instanceof HTMLVideoElement && !cache.has(node)) {
                log("New video element detected", node);
                let vapp = new VideoApp(node);
                cache.set(node, vapp);
                vapp.addEventListener("destroy", () => {
                    cache.delete(node);
                });
            }
        }
    }
});
observer.observe(document.body, {
    childList: true,
    subtree: true,
});

document.querySelectorAll("video").forEach((videoElement) => {
    log("Video element detected", videoElement);
    let vapp = new VideoApp(videoElement);
    cache.set(videoElement, vapp);
    vapp.addEventListener("destroy", () => {
        cache.delete(videoElement);
    });
});

log("Global initialized");
