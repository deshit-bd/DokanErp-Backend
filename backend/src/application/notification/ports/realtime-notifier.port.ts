export interface RealtimeNotifier {
  broadcastToShop(shopId: string, event: string, data: unknown): void;
}
