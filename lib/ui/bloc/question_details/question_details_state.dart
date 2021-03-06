import 'package:masterstudy_app/data/models/QuestionAddResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QuestionDetailsState {}

class InitialQuestionDetailsState extends QuestionDetailsState {}

class LoadedQuestionDetailsState extends QuestionDetailsState {
  LoadedQuestionDetailsState();
}

class ReplyAddingState extends QuestionDetailsState {}

class ReplyAddedState extends QuestionDetailsState {
  final QuestionAddResponse questionAddResponse;

  ReplyAddedState(this.questionAddResponse);
}

class ErrorQuestionDetailsState extends QuestionDetailsState {}
