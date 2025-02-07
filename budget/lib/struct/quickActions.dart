import "package:budget/database/tables.dart";
import "package:budget/functions.dart";
import "package:budget/main.dart";
import "package:budget/pages/addTransactionPage.dart";
import "package:budget/pages/budgetPage.dart";
import "package:budget/struct/databaseGlobal.dart";
import "package:budget/struct/settings.dart";
import "package:budget/widgets/openBottomSheet.dart";
import "package:budget/widgets/openPopup.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:quick_actions/quick_actions.dart";
import 'package:budget/pages/addWalletPage.dart';

void runQuickActionsPayLoads(context) async {
  if (kIsWeb) return;
  final QuickActions quickActions = const QuickActions();
  quickActions.initialize((String quickAction) async {
    if (Navigator.of(context).canPop() == false || entireAppLoaded) {
      if (quickAction == "addTransaction") {
        pushRoute(
          context,
          AddTransactionPage(
            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
          ),
        );
      } else if (quickAction == "transferTransaction") {
        openBottomSheet(
          context,
          fullSnap: true,
          TransferBalancePopup(
            allowEditWallet: true,
            wallet: Provider.of<AllWallets>(context, listen: false)
                .indexedByPk[appStateSettings["selectedWalletPk"]],
            showAllEditDetails: true,
          ),
        );
      } else if (quickAction.contains("openBudget")) {
        String budgetPk = quickAction.replaceAll("openBudget-", "");
        try {
          pushRoute(
            context,
            BudgetPage(
              budgetPk: budgetPk,
              dateForRange: DateTime.now(),
              isPastBudget: false,
              isPastBudgetButCurrentPeriod: false,
            ),
          );
        } catch (e) {
          print("Budget doesn't exist");
          print(e.toString());
        }
      }
    }
  });
  List<Budget> budgets = await database.getAllBudgets();
  quickActions.setShortcutItems(<ShortcutItem>[
    ShortcutItem(
      type: "addTransaction",
      localizedTitle: "add-transaction".tr(),
      icon: "addtransaction",
    ),
    if (appStateSettings["showTransactionsBalanceTransferTab"] == true &&
        Provider.of<AllWallets>(context, listen: false).indexedByPk.length > 1)
      ShortcutItem(
        type: "transferTransaction",
        localizedTitle: "transfer".tr(),
        icon: "transfertransaction",
      ),
    for (Budget budget in budgets)
      ShortcutItem(
        type: "openBudget-" + budget.budgetPk.toString(),
        localizedTitle: budget.name,
        icon: "piggybank",
      ),
  ]);
}
