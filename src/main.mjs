import { Vapp } from "./vapp.mjs";

Array.from(document.querySelectorAll("video")).forEach((videoElement) => {
    let app = new Vapp(videoElement);
    app.initialized.then(() => {
        app.__sprite.filters = filters;
    });
});

let observer = new MutationObserver((mutationsList, observer) => {
    for (let mutation of mutationsList) {
        if (mutation.type === "childList") {
            for (let node of mutation.addedNodes) {
                if (node.tagName === "VIDEO") {
                    let app = new Vapp(node);
                    app.initialized.then(() => {
                        app.__sprite.filters = filters;
                    });
                }
            }
        }
    }
});
observer.observe(document.body, { childList: true, subtree: true });
