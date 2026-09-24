import 'package:flutter/material.dart';

import '../controllers/app_ctrl.dart';

class AppLayoutSwitcher extends StatelessWidget {
  final AppScreenState screenState;
  final Widget Function(BuildContext context) setupBuilder;
  final Widget Function(BuildContext context) welcomeBuilder;
  final Widget Function(BuildContext context) agentBuilder;

  final Duration animationDuration;
  final Curve animationCurve;

  const AppLayoutSwitcher({
    super.key,
    required this.screenState,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutSine,
    required this.setupBuilder,
    required this.welcomeBuilder,
    required this.agentBuilder,
  });

  Widget _buildLayer(BuildContext context, AppScreenState layerState, Widget Function(BuildContext) builder) {
    final isActive = screenState == layerState;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isActive,
        child: AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: animationDuration,
          curve: animationCurve,
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            _buildLayer(context, AppScreenState.agent, agentBuilder),
            _buildLayer(context, AppScreenState.welcome, welcomeBuilder),
            _buildLayer(context, AppScreenState.setup, setupBuilder),
          ],
        ),
      );
}
