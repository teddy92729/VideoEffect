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
        this.__canvasElementContainer.style.display = "flex";
        this.__canvasElementContainer.style.justifyContent = "center";
        this.__canvasElementContainer.style.alignItems = "center";
        this.__canvasElementContainer.style.overflow = "hidden";
        this.__canvasElementContainer.style.pointerEvents = "none";
        this.__canvasElementContainer.style.contentVisibility = "auto";
        this.__canvasElementContainer.style.backgroundColor = "black";
        this.__canvasElementContainer.appendChild(this.__canvasElement);
        // fill the div element
        this.__canvasElement.style.flex = "1 1 auto";
        this.__canvasElement.style.maxWidth = "100%";
        this.__canvasElement.style.maxHeight = "100%";
        // insert div after video element
        this.__videoElement.parentNode.insertBefore(
            this.__canvasElementContainer,
            this.__videoElement.nextSibling
        );
        // remove cover when video element is removed
        this.__removeObserver = new MutationObserver((mutationsList) => {
            for (let mutation of mutationsList) {
                for (let node of mutation.removedNodes) {
                    if (node === this.__videoElement) {
                        this.destroy();
                    }
                }
            }
        });
        this.__removeObserver.observe(this.__videoElement.parentNode, {
            childList: true,
        });
        // fit div to video element
        this.__fit();
        this.__resizeObserver = new ResizeObserver(this.__fit.bind(this));
        this.__resizeObserver.observe(this.__videoElement);
    }

    /**
     * fit div to video element
     */
    __fit() {
        const vRect = this.__videoElement.getBoundingClientRect();
        const pRect = this.__videoElement.parentNode.getBoundingClientRect();
        const pCss = getComputedStyle(this.__videoElement.parentNode);

        let top = vRect.top - pRect.top + parseFloat(`0${pCss.top}`);
        let left = vRect.left - pRect.left + parseFloat(`0${pCss.left}`);
        let width = vRect.width;
        let height = vRect.height;

        this.__canvasElementContainer.style.top = `${top}px`;
        this.__canvasElementContainer.style.left = `${left}px`;
        this.__canvasElementContainer.style.width = `${width}px`;
        this.__canvasElementContainer.style.height = `${height}px`;
    }

    /**
     * destroy
     */
    destroy() {
        this.__resizeObserver.disconnect();
        this.__canvasElementContainer.remove();
    }
}
