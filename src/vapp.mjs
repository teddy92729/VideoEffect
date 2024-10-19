import {
    Texture,
    autoDetectRenderer,
    Sprite,
    NoiseFilter,
    EventEmitter,
} from "pixi.js";
import { InitBase, log, error } from "./utils.mjs";
import { Cover } from "./cover.mjs";

import { splitRGB } from "./shaders/splitRGB.mjs";
import { Anime4k_Deblur_DOG } from "./shaders/Anime4k_Deblur_DOG.mjs";
import { carton } from "./shaders/carton.mjs";
import { Anime4K_3DGraphics_AA_Upscale_x2_US } from "./shaders/Anime4K_3DGraphics_AA_Upscale_x2_US/Anime4K_3DGraphics_AA_Upscale_x2_US.mjs";
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
                    resolution: 1,
                    preferWebGLVersion: 2,
                    powerPreference: "high-performance",
                    preference: "webgl",
                });
                this.__canvasElement = this.__renderer.canvas;

                this.__sprite = new Sprite();
                this.__resize(); //intialize texture

                // this.__videoElement.addEventListener(
                //     "resize",
                //     this.__resize.bind(this)
                // );
                // this.__videoElement.addEventListener(
                //     "loadeddata",
                //     this.__resize.bind(this)
                // );
                this.__videoElement.addEventListener(
                    "playing",
                    this.__resize.bind(this)
                );
                window.addEventListener("focus", this.__resize.bind(this));

                //-------------------   Add Filters Here   -------------------
                this.__Anime4K_3DGraphics_AA_Upscale_x2_US =
                    Anime4K_3DGraphics_AA_Upscale_x2_US(this.__texture.source);
                this.addEventListener("resize", () => {
                    this.__Anime4K_3DGraphics_AA_Upscale_x2_US[3].resources.uOTexture =
                        this.__texture.source;
                });

                this.__sprite.filters = [
                    deband(),
                    carton(),
                    ...this.__Anime4K_3DGraphics_AA_Upscale_x2_US,
                    HDR(),
                    deband(),
                    line(),
                    Anime4k_Deblur_DOG(),
                    new NoiseFilter({ noise: 0.03 }),
                    // splitRGB(0.5),
                ];
                //-------------------   Add Filters Here   -------------------

                log("Initializing Vapp Video Frame Callback");
                if ("requestVideoFrameCallback" in this.__videoElement) {
                    this.__updateMethod = (callback) => {
                        this.__videoElement.requestVideoFrameCallback(callback);
                    };
                } else {
                    this.__updateMethod = (callback) => {
                        requestAnimationFrame(callback);
                    };
                }

                let checkCors = new Promise((resolve, reject) => {
                    this.__updateMethod(() => {
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
        this.__updateMethod(() => this.__update());
    }

    __resize() {
        let { videoWidth, videoHeight } = this.__videoElement;

        this.__texture?.destroy();
        this.__texture = Texture.from(this.__videoElement);
        this.__texture.source.unload();
        this.__texture.source.update();
        this.__texture.update();
        this.__texture.updateUvs();

        this.__sprite.texture = this.__texture;
        console.log(this.__texture);
        this.__renderer.resize(videoWidth, videoHeight);

        this.dispatchEvent(new Event("resize"));
        log("Resize", videoWidth, videoHeight);
    }
}
