import { Filter, GlProgram } from "pixi.js";

import vertex3 from "../vertex3.glsl";
import shader1 from "./Anime4K_Restore_CNN_Soft_S_1.glsl";
import shader2 from "./Anime4K_Restore_CNN_Soft_S_2.glsl";
import shader3 from "./Anime4K_Restore_CNN_Soft_S_3.glsl";
import shader4 from "./Anime4K_Restore_CNN_Soft_S_4.glsl";

export function Anime4K_Restore_CNN_Soft_S(orginalTexture) {
    return [
        new Filter({
            glProgram: GlProgram.from({
                vertex: vertex3,
                fragment: shader1,
            }),
        }),
        new Filter({
            glProgram: GlProgram.from({
                vertex: vertex3,
                fragment: shader2,
            }),
        }),
        new Filter({
            glProgram: GlProgram.from({
                vertex: vertex3,
                fragment: shader3,
            }),
        }),
        new Filter({
            glProgram: GlProgram.from({
                vertex: vertex3,
                fragment: shader4,
            }),
            resources: {
                uOTexture: orginalTexture,
            },
        }),
    ];
}
