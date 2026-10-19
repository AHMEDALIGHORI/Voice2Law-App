import 'package:flutter/material.dart';

class GlassComposer extends StatelessWidget {
  const GlassComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your legal question (Urdu or English)...',
    this.isBusy = false,
    this.focusNode,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool isBusy;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton.filled(
            tooltip: 'Send question',
            onPressed: isBusy ? null : onSend,
            icon: isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_upward),
          ),
        ),
      ],
    ),
  );
}
