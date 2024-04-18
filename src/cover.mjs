import { InitBase, log } from "./utils.mjs";

/**
 * Cover video element with canvas element
 */
export class Cover extends InitBase {
    /**
     * @param {HTMLVideoElement} videoElement
     * @param {HTMLCanvasElement} canvasElement
     */
    constructor(videoElement, canvasElement) {
        super();
        this.__videoElement = videoElement;
        this.__canvasElement = canvasElement;

        // use div to cover video element
        this.__canvasElementContainer = document.createElement("div");
        this.__canvasElementContainer.style.position = "absolute";
        this.__canvasElementContainer.style.display = "block";
        this.__canvasElementContainer.appendChild(this.__canvasElement);

        this.__canvasElement.style.position = "absolute";
        this.__canvasElement.style.display = "block";

        // keep canvas at the center of div element

        // sometimes not work
        // this.__canvasElement.style.top = "50%";
        // this.__canvasElement.style.left = "50%";
        // this.__canvasElement.style.transform = "translate(-50%, -50%)";

        this.__canvasElement.style.margin = "auto";
        this.__canvasElement.style.top = "0px";
        this.__canvasElement.style.bottom = "0px";
        this.__canvasElement.style.left = "0px";
        this.__canvasElement.style.right = "0px";

        // fill the div element
        this.__canvasElement.style.height = "100%";
        this.__canvasElement.style.width = "100%";
        this.__canvasElement.style.objectFit = "contain";

        this.__videoElement.parentNode.insertBefore(
            this.__canvasElementContainer,
            this.__videoElement.nextSibling
        );

        this.__initialized = new Promise((resolve) => {
            if (this.__videoElement.readyState > 0) resolve();
            else
                this.__videoElement.addEventListener("canplay", resolve, {
                    once: true,
                });
        })
            .then(() => {
                this.__fit();
                this.__resizeObserver = new ResizeObserver(
                    this.__fit.bind(this)
                );
                this.__resizeObserver.observe(this.__videoElement);
            })
            .then(() => {
                log("Cover initialized");
            })
            .catch((e) => {
                log("Cover initialization error", e);
            });
    }

    /**
     * fit div to video element
     */
    __fit() {
        let { width, height } = getComputedStyle(this.__videoElement);
        this.__canvasElementContainer.style.width = width;
        this.__canvasElementContainer.style.height = height;
        this.__canvasElementContainer.style.top = `${this.__videoElement.offsetTop}px`;
        this.__canvasElementContainer.style.left = `${this.__videoElement.offsetLeft}px`;
    }

    /**
     * destroy
     */
    destroy() {
        this.__resizeObserver.disconnect();
        this.__canvasElementContainer.remove();
    }
}
