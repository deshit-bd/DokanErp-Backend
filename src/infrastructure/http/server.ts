import http from "http";
import app from "./app";
import { env } from "../../config/env";
import { initSocket } from "../../utils/socket";
import { startOtpAutoRenewalJob } from "../jobs/otp-renewal.job";

const server = http.createServer(app);
initSocket(server);
startOtpAutoRenewalJob();

server.listen(env.PORT, () => {
  console.log(`Mudi ERP API listening on http://localhost:${env.PORT}`);
});
