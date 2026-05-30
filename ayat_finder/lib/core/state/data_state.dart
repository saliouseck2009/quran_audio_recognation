import 'package:ayat_finder/core/error/app_exception.dart';

sealed class DataState<T> {
  const DataState();
}

final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(this.data);

  final T data;
}

final class DataFailure<T> extends DataState<T> {
  const DataFailure(this.exception);

  final AppException exception;
}
