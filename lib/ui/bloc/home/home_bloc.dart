import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:masterstudy_app/data/repository/home_repository.dart';
import 'package:masterstudy_app/data/repository/instructors_repository.dart';

import './bloc.dart';

@provide
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final CoursesRepository _coursesRepository;
  final InstructorsRepository _instructorsRepository;

  HomeBloc(this._homeRepository, this._coursesRepository,
      this._instructorsRepository);

  @override
  HomeState get initialState => InitialHomeState();

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is FetchEvent) {
      if (state is ErrorHomeState) yield InitialHomeState();
      try {
        var layouts = (await _homeRepository.getAppSettings()).home_layout;

        layouts.removeWhere((element) => element.enabled == false);

        var categories = await _homeRepository.getCategories();
        var coursesFree =
            await _coursesRepository.getCourses(sort: Sort.price_low);

        var coursesNew = await _coursesRepository.getCourses(sort: Sort.rating);
        var coursesTrending = await _coursesRepository.getCourses();

        var instructors =
            await _instructorsRepository.getInstructors(InstructorsSort.rating);

        yield LoadedHomeState(categories, coursesTrending.courses, layouts,
            coursesNew.courses, coursesFree.courses, instructors);
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
        yield ErrorHomeState();
      }
    }
  }
}
