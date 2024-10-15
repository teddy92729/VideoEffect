import { Vapp } from "./vapp.mjs";
import "pixi.js/unsafe-eval";
import { log } from "./utils.mjs";

let cache = new WeakMap();

let observer = new MutationObserver((mutations) => {
    for (let mutation of mutations) {
        for (let node of mutation.addedNodes) {
            if (node instanceof HTMLVideoElement) {
                log("New video element detected", node);
                cache.set(node, new Vapp(node));
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
    cache.set(videoElement, new Vapp(videoElement));
});

log("Global initialized");
