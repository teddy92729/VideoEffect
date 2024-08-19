import { Filter, GlProgram } from "pixi.js";

import vertex3 from "./vertex3.glsl";
import shader from "./Anime4k_Deblur_DOG.glsl";

export function Anime4k_Deblur_DOG() {
    return new Filter({
        glProgram: GlProgram.from({
            vertex: vertex3,
            fragment: shader,
        }),
    });
}
