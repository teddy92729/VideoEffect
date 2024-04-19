import { Texture, autoDetectRenderer, Sprite, NoiseFilter } from "pixi.js";
import { InitBase, log, error } from "./utils.mjs";
import { Cover } from "./cover.mjs";
import { splitRGB } from "./filters.mjs";

export class Vapp extends InitBase {
    /**
     * @param {HTMLVideoElement} videoElement
     */
    constructor(videoElement) {
        log("Initializing Vapp");
        super();
        this.__videoElement = videoElement;
        this.__initialized = new Promise((resolve) => {
            if (this.__videoElement.readyState > 0) resolve();
            else
                this.__videoElement.addEventListener("canplay", resolve, {
                    once: true,
                });
        })
            .then(async () => {
                log("Initializing Vapp Renderer");
                this.__renderer = await autoDetectRenderer({
                    width: videoElement.videoWidth,
                    height: videoElement.videoHeight,
                    antialias: true,
                    resolution: devicePixelRatio,
                    autoDensity: false,
                    transparent: false,
                });

                this.__sprite = new Sprite();
                this.__sprite.filters = [
                    splitRGB(0.5),
                    new NoiseFilter({ noise: 0.03 }),
                ];
                this.__canvasElement = this.__renderer.canvas;

                this.__resize();
                this.__videoElement.addEventListener("resize", () =>
                    this.__resize()
                );

                log("Initializing Vapp Video Frame Callback");
                let checkCors = new Promise((resolve, reject) => {
                    this.__videoElement.requestVideoFrameCallback(() => {
                        try {
                            this.__update(); // test cors
                            this.__videoElement.style.visibility = "hidden";
                            resolve();
                        } catch (e) {
                            this.__cover.destroy();
                            reject(e);
                        }
                    });
                });

                log("Vapp initialized");

                this.__cover = new Cover(
                    this.__videoElement,
                    this.__canvasElement
                );
                return Promise.all([this.__cover.initialized, checkCors]);
            })
            .catch((e) => {
                error("Vapp initialization error", e);
            });
    }

    __update() {
        this.__renderer.render(this.__sprite);
        this.__videoElement.requestVideoFrameCallback(this.__update.bind(this));
    }

    __resize() {
        let { videoWidth, videoHeight } = this.__videoElement;

        this.__texture?.destroy();
        this.__texture = Texture.from(this.__videoElement);
        this.__sprite.texture = this.__texture;
        this.__renderer.resize(videoWidth, videoHeight);

        log("Resize", videoWidth, videoHeight);
    }
}
