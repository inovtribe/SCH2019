import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parc/blocs/balance_bloc/balance_bloc.dart';
import 'package:parc/util/theme.dart';

import 'blocs/areas_bloc/areas_bloc.dart';
import 'blocs/areas_bloc/areas_event.dart';
import 'blocs/authentication_bloc/bloc.dart';
import 'blocs/map_bloc/bloc.dart';
import 'blocs/reservation_bloc/bloc.dart';
import 'blocs/timer_bloc/timer_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'util/app_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = AppBlocDelegate();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc()..add(AppStarted()),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parc',
      theme: appThemeData[AppTheme.Gredient],
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<MapBloc>(
                  create: (context) => MapBloc()..add(LoadCurrent()),
                ),
                BlocProvider<AreasBloc>(
                  create: (context) => AreasBloc()..add(LoadAreas()),
                ),
                BlocProvider<BalanceBloc>(
                  create: (context) => BalanceBloc(state.user),
                ),
                BlocProvider<ReservationBloc>(
                  create: (context) => ReservationBloc()
                    ..add(Fetch(state.user.currentReservation)),
                ),
                BlocProvider<TimerBloc>(
                  create: (context) => TimerBloc(),
                ),

              ],
              child: HomeScreen(state.user),
            );
          } else if (state is Unauthenticated) {
            return SignInScreen();
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}
