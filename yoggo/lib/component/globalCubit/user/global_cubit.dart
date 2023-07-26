// import 'package:bloc/bloc.dart';
// import '../user/user_cubit.dart';
// import '../user/user_state.dart';

// class GlobalCubit extends Cubit<bool> {
//   final UserCubit userCubit;
//   GlobalCubit(this.userCubit) : super(false);


//   Future<void> fetchUserFromGlobalCubit() async {
//     // Call the fetchUser method of the userCubit
//     await userCubit.fetchUser();
//   }

//   void setInitialized() async {
//     await fetchUserFromGlobalCubit();
//     emit(true);
//   }
// }

