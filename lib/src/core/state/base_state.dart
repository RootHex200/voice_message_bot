

abstract class BaseState{
  const BaseState();
}

class InitialState<T> extends BaseState{
  const InitialState();
}

class LoadingState<T> extends BaseState{
  final T? data;
  const LoadingState({this.data});
}

class SuccessState<T> extends BaseState{
  final T? data;
  const SuccessState({this.data});
}

class ErrorState<T> extends BaseState{
  final T? data;
  const ErrorState({this.data});
}