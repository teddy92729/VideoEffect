export class InitBase {
    constructor() {
        /**
         * @type {Promise<any>}
         */
        this.__initialized = Promise.resolve();
    }
    /**
     * if object is ready
     * @returns {Promise<void>}
     */
    get initialized() {
        return this.__initialized;
    }
}

/**
 * console.log
 * @param  {...any} args
 */
export let log = (...args) => {
    console.log(`[ VideoEffect ]`, ...args);
};
/**
 * console.error
 * @param  {...any} args
 */
export let error = (...args) => {
    console.error(`[ VideoEffect ]`, ...args);
};
