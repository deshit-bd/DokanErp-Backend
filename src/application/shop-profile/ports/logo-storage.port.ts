export interface LogoStoragePort {
  store(dataUrlOrUrl: string, requestOrigin: string): Promise<string>;
}
