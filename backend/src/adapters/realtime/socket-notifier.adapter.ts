import type { RealtimeNotifier } from "@application/notification/ports/realtime-notifier.port";

import { broadcastToShop } from "../../utils/socket";

export class SocketNotifierAdapter implements RealtimeNotifier {
  broadcastToShop(shopId: string, event: string, data: unknown): void {
    broadcastToShop(shopId, event, data);
  }
}
