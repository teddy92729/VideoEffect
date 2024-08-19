import { Filter, GlProgram } from "pixi.js";

import vertex3 from "./vertex3.glsl";
import shader from "./line.glsl";

export function line() {
    return new Filter({
        glProgram: GlProgram.from({
            vertex: vertex3,
            fragment: shader,
        }),
    });
}
