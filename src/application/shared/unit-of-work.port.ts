// Abstracts prisma.$transaction so application/use-cases never import the
// Prisma client directly. `TxClient` is intentionally opaque here (application/
// must not know it's a PrismaClient) and is threaded through to repository
// methods that accept it as an optional transaction handle.
export type TxClient = unknown;

export interface UnitOfWork {
  run<T>(fn: (tx: TxClient) => Promise<T>): Promise<T>;
}
