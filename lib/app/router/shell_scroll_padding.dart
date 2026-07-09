import 'package:flutter/material.dart';

/// Bottom inset for scrollable roots inside [MainShellScreen] when the tab bar
/// is drawn as a floating overlay (not in [Scaffold.bottomNavigationBar]).
abstract final class ShellScrollPadding {
  /// Clears the floating pill nav ([HomeBottomNav] offset + min height + shadow).
  ///
  /// Matches [MainShellScreen] layout: `18 + navMinHeight (~74–86) + clearance`.
  static double floatingNavigationClearance(BuildContext context) => 150;

  /// Home, Services, Activity tabs — clears floating pill + shadow + home indicator.
  static double tabScrollBottom(BuildContext context) =>
      floatingNavigationClearance(context) +
      MediaQuery.paddingOf(context).bottom;

  /// Account tab — more cards; extra space so lower rows stay above the nav.
  static double accountTabScrollBottom(BuildContext context) =>
      180 + MediaQuery.paddingOf(context).bottom;
}
