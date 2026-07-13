import 'package:flutter_test/flutter_test.dart';
import 'package:dokan_erp/core/utils/voice_command_parser.dart';
import 'package:dokan_erp/core/utils/due_voice_parser.dart';

void main() {
  group('VoiceCommandParser Specs', () {
    test('Standard and Dialect Sell commands', () {
      final c1 = VoiceCommandParser.parse('চিনি বিক্রি করো ২ কেজি');
      expect(c1.intent, VoiceIntent.sell);
      expect(c1.quantity, 2);
      expect(c1.text, 'চিনি');

      final c2 = VoiceCommandParser.parse('চিনি দুইডা কেজি বেচো');
      expect(c2.intent, VoiceIntent.sell);
      expect(c2.quantity, 2);
      expect(c2.text, 'চিনি');

      final c3 = VoiceCommandParser.parse('তেল এক লিটার বেচ');
      expect(c3.intent, VoiceIntent.sell);
      expect(c3.quantity, 1);
      expect(c3.text, 'তেল');
    });

    test('Bangla quantity and currency terms translation', () {
      final c1 = VoiceCommandParser.parse('চিনি আড়াইশো টাকা বিক্রি');
      expect(c1.intent, VoiceIntent.sell);
      expect(c1.amount, 250);

      final c2 = VoiceCommandParser.parse('তেল একশো পঞ্চাশ টাকার বিক্রি');
      expect(c2.intent, VoiceIntent.sell);
      expect(c2.amount, 150);

      final c3 = VoiceCommandParser.parse('ডাল দেড় কেজি আসছে');
      expect(c3.intent, VoiceIntent.stockIn);
      expect(c3.quantity, 1); // maps দেড় to 1 unit

      final c4 = VoiceCommandParser.parse('৫০০ টাকা দোকান ভাড়া খরচ');
      expect(c4.intent, VoiceIntent.expense);
      expect(c4.amount, 500);
      expect(c4.text, 'দোকান ভাড়া');
    });

    test('Banglish / Mixed commands', () {
      final c1 = VoiceCommandParser.parse('চিনি sell করো two kg');
      expect(c1.intent, VoiceIntent.sell);
      expect(c1.quantity, 2);

      final c2 = VoiceCommandParser.parse('total baki কত');
      expect(c2.intent, VoiceIntent.due);

      final c3 = VoiceCommandParser.parse('ওয়ান লাক্স সোপ সেল');
      expect(c3.intent, VoiceIntent.sell);
      expect(c3.quantity, 1);
      expect(c3.text, 'লাক্স সোপ');

      final c4 = VoiceCommandParser.parse('টু কোক এড');
      expect(c4.intent, VoiceIntent.stockIn);
      expect(c4.quantity, 2);
      expect(c4.text, 'কোক');
    });

    test('Advanced voice intents (remove, staff, stock out)', () {
      final c1 = VoiceCommandParser.parse('চিনি বিক্রি বাদ দাও');
      expect(c1.intent, VoiceIntent.removeSell);
      expect(c1.text, 'চিনি');

      final c2 = VoiceCommandParser.parse('নতুন কর্মচারী সাগর');
      expect(c2.intent, VoiceIntent.addStaff);
      expect(c2.text, 'সাগর');

      final c3 = VoiceCommandParser.parse('তেল ২ কেজি নষ্ট');
      expect(c3.intent, VoiceIntent.stockOut);
      expect(c3.text, 'তেল');
      expect(c3.quantity, 2);

      // Verify product noise words are stripped
      final c4 = VoiceCommandParser.parse('১টা চিনি পান্না বিক্রি');
      expect(c4.intent, VoiceIntent.sell);
      expect(c4.text, 'চিনি');
      
      final c5 = VoiceCommandParser.parse('১টা ডাল পণ্য বিক্রি');
      expect(c5.intent, VoiceIntent.sell);
      expect(c5.text, 'ডাল');
    });
  });

  group('DueVoiceParser Specs', () {
    test('Due/Credit dialect variations', () {
      final c1 = DueVoiceParser.parse('রহিম ভাই ৪০০ টাকা বাকি নিসে');
      expect(c1.isValid, true);
      expect(c1.customerName, 'রহিম ভাই');
      expect(c1.amount, 400);

      final c2 = DueVoiceParser.parse('রহিমর বাকি পাঁচশো দেও');
      expect(c2.isValid, true);
      expect(c2.customerName, 'রহিমর');
      expect(c2.amount, 500);

      final c3 = DueVoiceParser.parse('রহিম টেহা দিছে পাঁচশো বাকি');
      expect(c3.isValid, true);
      expect(c3.customerName, 'রহিম');
      expect(c3.amount, 500);
    });
  });
}
