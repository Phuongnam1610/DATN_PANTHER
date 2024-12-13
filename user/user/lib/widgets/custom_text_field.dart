import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? initialValue;
  final void Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.validator,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      initialValue: widget.initialValue,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(), // Customize border as needed
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor), // Customize focused border
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Customize error border
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700), // Customize focused error border
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
