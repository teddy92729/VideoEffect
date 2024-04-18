import { Vapp } from "./vapp.mjs";

Array.from(document.querySelectorAll("video")).forEach((videoElement) => {
    new Vapp(videoElement).initialized.then(() => {});
});

let observer = new MutationObserver((mutationsList, observer) => {
    for (let mutation of mutationsList) {
        if (mutation.type === "childList") {
            for (let node of mutation.addedNodes) {
                if (node.tagName === "VIDEO") {
                    new Vapp(node);
                }
            }
        }
    }
});
observer.observe(document.body, { childList: true, subtree: true });
