import type { CreateNotificationUseCase } from "./create-notification.use-case";

const DUMMY_NOTIFICATIONS: Array<{ type: string; title: string; message: string }> = [
  { type: "SALE", title: "টেস্ট বিক্রয় সম্পন্ন", message: "রসিদ নং TXN-TEST-101 | মোট বিক্রয় ৳১২০০ | কাস্টমার: কামাল হোসেন" },
  { type: "INVENTORY", title: "টেস্ট স্টক সতর্কতা", message: "পণ্য: মিনিকেট চাল ৫০ কেজি এর স্টক কমে ৩ এ নেমেছে।" },
  { type: "GENERAL", title: "নতুন গ্রাহক যুক্ত হয়েছে", message: "গ্রাহক আবির রহমান আপনার কাস্টমার তালিকায় সফলভাবে যুক্ত হয়েছে।" },
];

export class SendTestDummyNotificationsUseCase {
  constructor(private readonly createNotificationUseCase: CreateNotificationUseCase) {}

  async execute(shopId: string): Promise<void> {
    for (const dummy of DUMMY_NOTIFICATIONS) {
      await this.createNotificationUseCase.execute(shopId, dummy.type, dummy.title, dummy.message);
    }
  }
}
