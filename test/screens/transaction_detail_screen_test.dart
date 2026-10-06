import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salary_tracker/app/app.dart';
import 'package:salary_tracker/app/router.dart';
import 'package:salary_tracker/data/services/local_ai_service.dart';
import 'package:salary_tracker/design_system/components/components.dart';
import 'package:salary_tracker/ui/screens/transaction_detail/widgets/ai_receipt_section.dart';
import 'package:salary_tracker/ui/screens/transaction_detail/widgets/merchant_info_section.dart';
import 'package:salary_tracker/ui/screens/transaction_detail/widgets/receipt_viewer_modal.dart';
import 'package:salary_tracker/ui/screens/transaction_detail/widgets/transaction_detail_header.dart';
import 'package:salary_tracker/ui/screens/transaction_detail/widgets/transaction_hero_section.dart';

void main() {
  group('TransactionDetailScreen (Screen 2) Widget Tests', () {
    setUp(() {
      appRouter.go('/transaction/txn_wf_01');
    });

    testWidgets('Renders all Screen 2 elements with exact mockup values',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header components
      expect(find.byType(TransactionDetailHeader), findsOneWidget);
      expect(find.text('Transaction Detail'), findsOneWidget);

      // 2. Hero section
      expect(find.byType(TransactionHeroSection), findsOneWidget);
      expect(find.text('Whole Foods Market'), findsWidgets);
      expect(find.text('Food'), findsWidgets);
      expect(find.textContaining('Groceries'), findsWidgets);
      expect(find.text('AI Categorized ✦'), findsOneWidget);
      expect(find.text('Cleared'), findsOneWidget);

      // 3. AI Receipt Section
      expect(find.byType(AiReceiptSection), findsOneWidget);
      expect(find.text('AI Receipt Scan'), findsOneWidget);
      expect(find.text('4 Items • Verified'), findsOneWidget);
      expect(find.byType(ReceiptThumb), findsOneWidget);
      expect(find.byType(ReceiptCard), findsOneWidget);

      // Line items breakdown
      expect(find.textContaining('Organic Oat Milk'), findsOneWidget);
      expect(find.textContaining('Avocados'), findsOneWidget);
      expect(find.textContaining('Greek Yogurt'), findsOneWidget);
      expect(find.textContaining('Artisan Sourdough'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Estimated Tax'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // 4. Merchant Info Section
      expect(find.byType(MerchantInfoSection), findsOneWidget);
      expect(find.text('Merchant Details'), findsOneWidget);
      expect(find.byType(MerchantCard), findsOneWidget);
      expect(find.textContaining('8 visits this month'), findsOneWidget);
      expect(find.textContaining('250 E 57th St'), findsOneWidget);
      expect(find.textContaining('(212) 759-8457'), findsOneWidget);

      // 5. Bottom action buttons
      expect(find.text('Download Receipt'), findsOneWidget);
      expect(find.text('Share Details'), findsOneWidget);
    });

    testWidgets('Tapping more "..." button opens popover menu',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final moreButtonFinder = find.bySemanticsLabel('More Options');
      expect(moreButtonFinder, findsOneWidget);

      await tester.tap(moreButtonFinder);
      await tester.pumpAndSettle();

      // Check popover items
      expect(find.text('Edit Transaction'), findsOneWidget);
      expect(find.text('Export Receipt PDF'), findsOneWidget);
      expect(find.text('Delete Transaction'), findsOneWidget);

      // Tap outside to close popover
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsNothing);
    });

    testWidgets('Tapping on ReceiptThumb opens fullscreen ReceiptViewerModal',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      final thumbFinder = find.byType(ReceiptThumb);
      expect(thumbFinder, findsOneWidget);

      await tester.tap(thumbFinder);
      await tester.pumpAndSettle();

      // Verifies ReceiptViewerModal is mounted
      expect(find.byType(ReceiptViewerModal), findsOneWidget);
      expect(find.text('Original Receipt'), findsOneWidget);
      expect(find.text('Pinch to zoom • Pan to inspect'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Done to dismiss modal
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptViewerModal), findsNothing);
    });

    testWidgets('Back button navigates back to Home',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Start on Home first
      appRouter.go('/');
      await tester.pumpWidget(
        const ProviderScope(
          child: AppApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap a transaction to navigate to detail
      final wholeFoodsFinder = find.text('Whole Foods Market').first;
      await tester.tap(wholeFoodsFinder);
      await tester.pumpAndSettle();

      expect(find.text('Transaction Detail'), findsOneWidget);

      // Tap back button
      final backButtonFinder = find.bySemanticsLabel('Go Back');
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Verified back on Home screen
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
    });
  });

  group('LocalAiService Unit Tests', () {
    const aiService = LocalAiService();

    test('scanReceiptFromBytes returns mock receipt with high confidence',
        () async {
      final result = await aiService.scanReceiptFromBytes([0, 1, 2]);

      expect(result.merchantName, 'Whole Foods Market');
      expect(result.items.length, 4);
      expect(result.subtotal.cents, 3046);
      expect(result.tax.cents, 245);
      expect(result.total.cents, 3291);
      expect(result.confidenceScore, greaterThan(0.95));
      expect(result.suggestedCategory, 'Groceries');
    });

    test('parseReceiptText extracts items, subtotal, tax, and total', () async {
      const ocr = '''
Trader Joe's
1x Almond Butter \$7.99
2x Bananas \$1.50
SUBTOTAL \$9.49
TAX \$0.76
TOTAL \$10.25
''';

      final result = await aiService.parseReceiptText(ocr);

      expect(result.merchantName, "Trader Joe's");
      expect(result.items.length, 2);
      expect(result.items[0].name, 'Almond Butter');
      expect(result.items[0].price.cents, 799);
      expect(result.items[1].name, 'Bananas');
      expect(result.items[1].quantity, 2);
      expect(result.subtotal.cents, 949);
      expect(result.tax.cents, 76);
      expect(result.total.cents, 1025);
      expect(result.suggestedCategory, 'Groceries');
    });

    test('suggestCategoryForMerchant classifies common merchants accurately',
        () async {
      expect(await aiService.suggestCategoryForMerchant('Uber BV'), 'Transport');
      expect(await aiService.suggestCategoryForMerchant('Whole Foods Market'), 'Groceries');
      expect(await aiService.suggestCategoryForMerchant('Blue Bottle Coffee'), 'Dining');
      expect(await aiService.suggestCategoryForMerchant('Apple Store 5th Ave'), 'Shopping');
      expect(await aiService.suggestCategoryForMerchant('Metropolitan Real Estate Rent'), 'Rent');
      expect(await aiService.suggestCategoryForMerchant('TechCorp Payroll'), 'Salary');
    });
  });
}
