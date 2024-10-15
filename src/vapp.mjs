import { Texture, autoDetectRenderer, Sprite, NoiseFilter } from "pixi.js";
import { InitBase, log, error } from "./utils.mjs";
import { Cover } from "./cover.mjs";

import { splitRGB } from "./shaders/splitRGB.mjs";
import { Anime4k_Deblur_DOG } from "./shaders/Anime4k_Deblur_DOG.mjs";
import { carton } from "./shaders/carton.mjs";
import { HDR } from "./shaders/HDR.mjs";
import { line } from "./shaders/line.mjs";
import { deband } from "./shaders/deband.mjs";

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
                    antialias: false,
                    resolution: 2,
                    preferWebGLVersion: 2,
                    powerPreference: "high-performance",
                    preference: "webgl",
                });

                this.__sprite = new Sprite();
                this.__sprite.filters = [
                    // splitRGB(0.5),
                    // carton(),
                    deband(),
                    HDR(),
                    line(),
                    Anime4k_Deblur_DOG(),
                    new NoiseFilter({ noise: 0.03 }),
                ];
                this.__canvasElement = this.__renderer.canvas;

                this.__resize();
                this.__videoElement.addEventListener("resize", () =>
                    this.__resize()
                );
                this.__videoElement.addEventListener("playing", () => {
                    this.__resize();
                });

                log("Initializing Vapp Video Frame Callback");
                let checkCors = new Promise((resolve, reject) => {
                    this.__videoElement.requestVideoFrameCallback(() => {
                        try {
                            this.__update(); // test cors
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
