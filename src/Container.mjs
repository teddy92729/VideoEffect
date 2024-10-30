export class VideoContainer extends EventTarget {
    /**
     * @param {HTMLVideoElement} video
     */
    constructor(video) {
        super();
        if (!(video instanceof HTMLVideoElement)) {
            throw new TypeError(
                "Parameter is not an instance of HTMLVideoElement"
            );
        }
        this._video = video;
        this._remover = new MutationObserver((mutationsList) => {
            for (let mutation of mutationsList) {
                for (let node of mutation.removedNodes) {
                    if (node === this._video) {
                        this.destroy();
                        return;
                    }
                }
            }
        });
        this._remover.observe(this._video.parentNode, {
            childList: true,
        });

        this._ready = new Promise((resolve) => {
            if (this._video.readyState > 0) {
                resolve();
            } else {
                this._video.addEventListener(
                    "canplay",
                    () => {
                        resolve();
                    },
                    { once: true }
                );
            }
        });

        this._ready.then(() => this.dispatchEvent(new Event("ready")));
        this._abortController = new AbortController();
        this._abortSignal = this._abortController.signal;
    }
    destroy() {
        this._remover.disconnect();
        this._abortController.abort();
        this.dispatchEvent(new Event("destroy"));
    }
    get video() {
        return this._video;
    }
    get ready() {
        return this._ready;
    }
    get abortSignal() {
        return this._abortSignal;
    }
}

export class CanvasContainer {
    /**
     * @param {HTMLCanvasElement} canvas
     */
    constructor(canvas) {
        if (!(canvas instanceof HTMLCanvasElement)) {
            throw new TypeError(
                "Parameter is not an instance of HTMLCanvasElement"
            );
        }
        this._canvas = canvas;
        this._container = document.createElement("div");
        this._container.style.position = "absolute";
        this._container.style.display = "flex";
        this._container.style.justifyContent = "center";
        this._container.style.alignItems = "center";
        this._container.style.overflow = "hidden";
        this._container.style.pointerEvents = "none";
        this._container.style.contentVisibility = "auto";
        this._container.style.backgroundColor = "black";
        this._container.appendChild(this._canvas);
        this._canvas.style.flex = "1 1 auto";
        this._canvas.style.maxWidth = "100%";
        this._canvas.style.maxHeight = "100%";
    }
    destroy() {
        this._container.remove();
    }
    get canvas() {
        return this._canvas;
    }
    get div() {
        return this._container;
    }
}

export class Container extends EventTarget {
    /**
     * @param {HTMLVideoElement} video
     * @param {HTMLCanvasElement} canvas
     */
    constructor(video, canvas) {
        super();
        this._videoContainer = new VideoContainer(video);
        this._canvasContainer = new CanvasContainer(canvas);
        this._videoContainer.addEventListener("destroy", () => this.destroy());

        const div = this._canvasContainer.div;
        video.parentNode.insertBefore(div, video.nextSibling);

        this._resizeObserver = new ResizeObserver(() => this.resize());
        this._resizeObserver.observe(video, {
            box: "device-pixel-content-box",
        });
        document.addEventListener("visibilitychange", () => this.resize(), {
            signal: this._videoContainer.abortSignal,
        });
    }
    destroy() {
        this._canvasContainer.destroy();
        this._resizeObserver.disconnect();
        this.dispatchEvent(new Event("destroy"));
    }
    resize() {
        const video = this._videoContainer.video;
        const div = this._canvasContainer.div;
        const vRect = video.getBoundingClientRect();
        const pRect = video.parentNode.getBoundingClientRect();
        const pCss = getComputedStyle(video.parentNode);

        const top = vRect.top - pRect.top + parseFloat(`0${pCss.top}`);
        const left = vRect.left - pRect.left + parseFloat(`0${pCss.left}`);
        const width = vRect.width;
        const height = vRect.height;

        div.style.top = `${top}px`;
        div.style.left = `${left}px`;
        div.style.width = `${width}px`;
        div.style.height = `${height}px`;

        this.dispatchEvent(new Event("resize"));
    }

    get video() {
        return this._videoContainer.video;
    }
    get videoContainer() {
        return this._videoContainer;
    }
    get canvas() {
        return this._canvasContainer.canvas;
    }
    get canvasContainer() {
        return this._canvasContainer;
    }
    get div() {
        return this._canvasContainer.div;
    }
    get abortSignal() {
        return this._videoContainer.abortSignal;
    }
    get ready() {
        return this._videoContainer.ready;
    }
}
