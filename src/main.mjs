import { Vapp } from "./vapp.mjs";
import "pixi.js/unsafe-eval";

let cache = new WeakMap();

Array.from(document.querySelectorAll("video")).forEach((videoElement) => {
    cache.set(videoElement, new Vapp(videoElement));
});

let observer = new MutationObserver((mutationsList, observer) => {
    for (let mutation of mutationsList) {
        if (mutation.type === "childList") {
            for (let node of mutation.addedNodes) {
                if (node.tagName === "VIDEO") {
                    cache.set(node, new Vapp(node));
                }
            }
        }
    }
});
observer.observe(document.body, { childList: true, subtree: true });
