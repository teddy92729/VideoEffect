import { Texture, Sprite, NoiseFilter, WebGLRenderer } from "pixi.js";
import { log, error } from "../old/utils.mjs";
import { Container } from "./Container.mjs";

import { splitRGB } from "./shaders/splitRGB.mjs";
import { Anime4k_Deblur_DOG } from "./shaders/Anime4k_Deblur_DOG.mjs";
import { carton } from "./shaders/carton.mjs";
import { Anime4K_3DGraphics_AA_Upscale_x2_US } from "./shaders/Anime4K_3DGraphics_AA_Upscale_x2_US/Anime4K_3DGraphics_AA_Upscale_x2_US.mjs";
import { HDR } from "./shaders/HDR.mjs";
import { line } from "./shaders/line.mjs";
import { deband } from "./shaders/deband.mjs";
/**
 * @param {VideoApp} videoApp
 */
function filters(videoApp) {
    return [
        deband(),
        carton(),
        ...Anime4K_3DGraphics_AA_Upscale_x2_US(videoApp._texture.source),
        HDR(),
        deband(),
        line(),
        Anime4k_Deblur_DOG(),
        // new NoiseFilter({ noise: 0.03 }),
        // splitRGB(0.5),
    ];
}

export class VideoApp extends EventTarget {
    /**
     * @param {HTMLVideoElement} video
     */
    constructor(video) {
        super();
        this._renderer = new WebGLRenderer();
        const canvas = document.createElement("canvas");

        this._container = new Container(video, canvas);
        this._ready = this._container.ready
            .then(() => {
                log("Initializing VideoApp");
                return this._renderer.init({
                    width: video.videoWidth,
                    height: video.videoHeight,
                    antialias: true,
                    canvas: canvas,
                    resolution: 1,
                    powerPreference: "high-performance",
                    preferWebGLVersion: 2,
                    depth: false,
                });
            })
            .then(() => {
                const texture = Texture.from(video);
                const source = texture.source;
                texture.dynamic = true;
                source.autoUpdate = false;
                video.removeEventListener("play", source._onPlayStart);
                video.removeEventListener("pause", source._onPlayStop);
                video.removeEventListener("seeked", source._onSeeked);
                video.removeEventListener("canplay", source._onCanPlay);
                video.removeEventListener(
                    "canplaythrough",
                    this._onCanPlayThrough
                );
                video.removeEventListener("error", source._onError, true);

                this._texture = texture;
            })
            .then(() => {
                this._sprite = new Sprite();
                this._sprite.texture = this._texture;
                this.resize();
                this._sprite.filters = filters(this);
                console.log(this._sprite.filters);

                video.addEventListener("playing", () => this.resize());
                video.addEventListener("resize", () => this.resize());
                video.addEventListener("loadeddata", () => this.resize());
                document.addEventListener(
                    "visibilitychange",
                    () => this.resize(),
                    {
                        signal: this._container.abortSignal,
                    }
                );

                video.requestVideoFrameCallback(() => this.update());
                log("VideoApp initialized");
            })
            .catch(error);

        this._container.addEventListener("destroy", () => this.destroy());
    }

    update() {
        if (
            this._container.canvas.checkVisibility({
                contentVisibilityAuto: true,
            })
        ) {
            this._texture.source.update();
            this._renderer.render(this._sprite);
        }
        this._container.video.requestVideoFrameCallback(() => this.update());
    }

    resize() {
        const video = this._container.video;
        const { videoWidth, videoHeight } = video;

        this._texture.update();
        this._texture.updateUvs();
        this._renderer.resize(videoWidth, videoHeight);
        this.dispatchEvent(new Event("resize"));
    }

    destroy() {
        if (this._destroyed) return;
        this._destroyed = true;
        this._texture?.destroy();
        this._sprite?.destroy();
        this._renderer?.destroy();
        this._container.destroy();
        this.dispatchEvent(new Event("destroy"));
    }
    get container() {
        return this._container;
    }
    get ready() {
        return this._ready;
    }
    /**
     * @param {Filter[]} filters
     */
    set filters(filters) {
        this._sprite.filters = filters;
    }
}
