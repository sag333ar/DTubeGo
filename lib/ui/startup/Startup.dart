import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dtube_go/bloc/settings/settings_bloc.dart';
import 'package:dtube_go/bloc/settings/settings_bloc_full.dart';
import 'package:dtube_go/ui/startup/PinPad.dart';
import 'package:dtube_go/bloc/auth/auth_bloc_full.dart';
import 'package:dtube_go/style/ThemeData.dart';
import 'package:dtube_go/ui/widgets/dtubeLogoPulse/dtubeLoading.dart';
import 'package:dtube_go/ui/startup/login/LoginScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class StartUp extends StatefulWidget {
  StartUp({Key? key}) : super(key: key);

  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
// Create storage
  double _logoSize = 40.w;
  @override
  void initState() {
    super.initState();
    print(Device.width);
    if (kIsWeb) {
      _logoSize = 10.w;
    }

    // sec.deleteAllSettings(); // flush ALL app settings including logindata, hivesigner and so on
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // if the user has been authenticated before using login credentials
        //// show Pinpad
        if (state is SignedInState) {
          return BlocProvider<SettingsBloc>(
              create: (BuildContext context) =>
                  SettingsBloc()..add(FetchSettingsEvent()),

              // add event FetchSettingsEvent to prepare the data for the pinpad dialog
              child: PinPadScreen(
                currentTermsAccepted: state.termsAccepted,
              ));
        }
        // if credentials are wrong or key got deleted -> show login form with the prefilled username
        if (state is SignInFailedState) {
          return LoginForm(
            message: state.message,
            username: state.username,
            showOnboardingJourney: false,
          );
        }
        // if the user logged out or no login credentials have been found in the secure storage
        //// show login form
        if (state is SignOutCompleteState ||
            state is NoSignInInformationFoundState) {
          return LoginForm(
            showOnboardingJourney: false,
          );
        }
        // if the app is opened for the first time
        // show Login with onboarding journey on top
        if (state is NeverUsedTheAppBeforeState) {
          return LoginForm(
            showOnboardingJourney: true,
          );
        }

        if (state is ApiNodeOfflineState) {
          // as long as there are no informations from the authentication logic -> show loading animation
          return Scaffold(
            backgroundColor: globalBlue,
            body: Center(
              child: DtubeLogoPulseWithSubtitle(
                subtitle:
                    "No API node can be reached. Check your internet connnection or contact us on discord...",
                size: _logoSize,
              ),
            ),
          );
        }

        if (state is AuthErrorState) {
          // as long as there are no informations from the authentication logic -> show loading animation
          return Scaffold(
            backgroundColor: globalBlue,
            body: Center(
              child: Column(
                children: [
                  DtubeLogoPulseWithSubtitle(
                    subtitle: "error on login",
                    size: _logoSize,
                  ),
                  Container(
                      color: globalBGColor,
                      height: 50.h,
                      width: 95.w,
                      child: Markdown(
                        data: state.message,
                        selectable: true,
                      ))
                ],
              ),
            ),
          );
        }

        if (state is NeverUsedTheAppBeforeState) {
          return LoginForm(showOnboardingJourney: true);
        }

        // as long as there are no informations from the authentication logic -> show loading animation
        return Scaffold(
          backgroundColor: globalBlue,
          body: Center(
            child: DtubeLogoPulseWithSubtitle(
              subtitle:
                  "We are currently searching for the fastest Avalon API node...",
              size: _logoSize,
            ),
          ),
        );
      },
    );
  }
}
