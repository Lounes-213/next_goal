import 'package:dartz/dartz.dart';

import '../error/error_handler.dart';

/// Encapsulates try/catch logic for local (non-API) operations,
/// returning an [Either] with [Failure] or the result [T].
Future<Either<Failure, T>> safeLocalCall<T>(
  Future<T> Function() call,
) async {
  try {
    final result = await call();
    return Right(result);
  } catch (error) {
    return Left(Failure(code: -1, message: error.toString()));
  }
}
