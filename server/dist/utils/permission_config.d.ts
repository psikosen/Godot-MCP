export type PathRule = {
    type: 'directory';
    value: string;
} | {
    type: 'file';
    value: string;
} | {
    type: 'extension';
    value: string;
};
export interface CapabilityConfig {
    writeAllow: PathRule[];
    writeDeny: PathRule[];
}
/**
 * Default capability configuration describing which relative paths can be
 * written by automated patch tooling. These values err on the side of
 * protecting project assets that could break the sample project when edited
 * blindly (e.g. imported assets, binaries).
 */
export declare const defaultCapabilityConfig: CapabilityConfig;
