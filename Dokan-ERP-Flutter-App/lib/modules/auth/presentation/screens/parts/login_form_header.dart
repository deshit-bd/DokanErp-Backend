part of '../auth_screens.dart';

class _LoginFormHeader extends StatelessWidget {
  const _LoginFormHeader({
    required this.isSalesman,
  });

  final bool isSalesman;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSalesman ? 'সেলসম্যান লগইন' : 'মার্চেন্ট লগইন',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF131D21),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSalesman
              ? 'সেলসম্যান মোবাইল নম্বর ও PIN ব্যবহার করে লগইন করুন'
              : 'মার্চেন্ট/অ্যাডমিন মোবাইল নম্বর ও পাসওয়ার্ড ব্যবহার করে লগইন করুন',
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF3D4943),
          ),
        ),
      ],
    );
  }
}

class _LoginInputField extends StatelessWidget {
  const _LoginInputField({
    required this.label,
    required this.hintText,
    required this.helperText,
    this.prefix,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.controller,
    this.inputFormatters,
  });

  final String label;
  final String hintText;
  final String helperText;
  final Widget? prefix;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3D4943),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              if (prefix != null) ...[
                prefix!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  obscuringCharacter: '•',
                  cursorColor: const Color(0xFF00694C),
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    color: Color(0xFF131D21),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF93A1A7),
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFBCCAC1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF00694C), width: 1.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: onToggleObscure == null
                        ? null
                        : IconButton(
                            onPressed: onToggleObscure,
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF6D7A73),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6D7A73),
          ),
        ),
      ],
    );
  }
}

class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBCCAC1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '+88',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF131D21),
        ),
      ),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBCCAC1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF6D7A73)),
    );
  }
}

class _RememberForgotRow extends StatelessWidget {
  const _RememberForgotRow({
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotPressed,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback? onForgotPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onRememberChanged(!rememberMe),
            borderRadius: BorderRadius.circular(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFBCCAC1)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: rememberMe
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Color(0xFF00694C))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'মনে রাখুন',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3D4943),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00694C),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'পাসওয়ার্ড ভুলে গেছেন?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00694C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3300694C),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFBCCAC1), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6D7A73),
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFBCCAC1), thickness: 1),
        ),
      ],
    );
  }
}
