import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wallet_controller.dart';

final walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(WalletController.new);
