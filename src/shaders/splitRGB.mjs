import { Filter, GlProgram } from "pixi.js";

import vertex3 from "./vertex3.glsl";
import shader from "./splitRGB.glsl";

export function splitRGB(strength) {
    return new Filter({
        glProgram: GlProgram.from({
            vertex: vertex3,
            fragment: shader,
        }),
        resources: {
            timeUniform: {
                strength: {
                    type: "f32",
                    value: strength,
                },
            },
        },
    });
}
