import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/home_page.dart';
import 'package:flutter_lovers/app/sign_in/sign_in_page.dart';
import 'package:flutter_lovers/view_model/view_model.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _viewModel = Provider.of<ViewModel>(context);

    if (_viewModel.viewState == ViewState.Idle) {
      if (_viewModel.user == null) {
        return SignInPage();
      } else {
        return HomePage(user: _viewModel.user!);
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
