import 'package:flutter/material.dart';

class BudgetField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isNumber;
  final bool enabled;
  final Widget? suffix;
  const BudgetField({super.key, required this.label, required this.hint, this.controller, this.isNumber = false, this.enabled = true, this.suffix});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 6),
      Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
        child: Row(children: [
          Expanded(child: TextField(
            controller: controller, enabled: enabled,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontSize: 12, color: enabled ? Colors.black : Colors.grey),
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12), contentPadding: const EdgeInsets.only(bottom: 12)),
          )),
          if (suffix != null) suffix!,
        ]),
      ),
    ]);
  }
}

class BudgetDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const BudgetDropdown({super.key, required this.label, required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 6),
      Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
        child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, size: 20), style: const TextStyle(fontSize: 12, color: Colors.black87), items: items, onChanged: onChanged)),
      ),
    ]);
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, required this.icon, required this.children, this.color = const Color(0xFF007AFF)});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class ResultInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  const ResultInfoCard({super.key, required this.label, required this.value, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6)],
        Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
      ]),
    );
  }
}
