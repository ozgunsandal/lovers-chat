import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    Key? key,
    required this.onPressed,
    this.buttonColor,
    this.buttonText,
    this.textColor,
    this.borderRadius,
    this.yukseklik,
    this.buttonIcon,
    this.textSize,
  }) : super(key: key);

  final String? buttonText;
  final Color? buttonColor;
  final Color? textColor;
  final double? textSize;
  final double? borderRadius;
  final double? yukseklik;
  final Widget? buttonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: yukseklik,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonIcon ?? const Text(''),
              Text(
                buttonText ?? '',
                style: TextStyle(color: textColor, fontSize: textSize),
                textAlign: TextAlign.right,
              ),
              Opacity(
                child: buttonIcon ?? const Text(''),
                opacity: 0,
              )
            ],
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(buttonColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: borderRadius == null
                    ? BorderRadius.all(Radius.zero)
                    : BorderRadius.all(
                        Radius.circular(borderRadius!),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
