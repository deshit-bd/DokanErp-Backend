import { Server } from "socket.io";
import { Server as HttpServer } from "http";

let io: Server | null = null;

export function initSocket(server: HttpServer) {
  io = new Server(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    },
    allowEIO3: true,
  });

  io.on("connection", (socket) => {
    console.log("Socket client connected:", socket.id);

    socket.on("join-shop", (shopId: string) => {
      if (shopId) {
        socket.join(shopId);
        console.log(`Socket ${socket.id} joined shop: ${shopId}`);
      }
    });

    socket.on("disconnect", () => {
      console.log("Socket client disconnected:", socket.id);
    });
  });

  return io;
}

export function getIo() {
  return io;
}

export function broadcastToShop(shopId: string, event: string, data: any) {
  if (io) {
    io.to(shopId).emit(event, data);
    console.log(`Broadcasted event ${event} to shop ${shopId}`);
  }
}
