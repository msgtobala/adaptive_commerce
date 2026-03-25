import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';

/// Fixed bottom prompt row: text field + send ([Icons.send_rounded]).
///
/// Wired for GenUI / chat later via [onSend].
class ShellPromptBar extends StatefulWidget {
  const ShellPromptBar({
    super.key,
    this.onSend,
  });

  /// Called with trimmed text when the user taps send or presses the keyboard send action.
  final ValueChanged<String>? onSend;

  @override
  State<ShellPromptBar> createState() => _ShellPromptBarState();
}

class _ShellPromptBarState extends State<ShellPromptBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: AppStrings.shellPromptHint,
                      isDense: true,
                    ).applyDefaults(theme.inputDecorationTheme),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  tooltip: AppStrings.shellPromptSendTooltip,
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shell tab page layout: scrollable / main area + fixed [ShellPromptBar] at the bottom.
class ShellPageScaffold extends StatelessWidget {
  const ShellPageScaffold({
    super.key,
    required this.body,
    this.onPromptSend,
  });

  final Widget body;
  final ValueChanged<String>? onPromptSend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: body),
          ShellPromptBar(onSend: onPromptSend),
        ],
      ),
    );
  }
}
