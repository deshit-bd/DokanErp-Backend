export interface ProductPictureStoragePort {
  /** Persists a data: URL to disk and returns its public URL; passes through anything else (already-hosted URL) unchanged. */
  store(dataUrlOrUrl: string, requestOrigin: string): Promise<string>;
}
