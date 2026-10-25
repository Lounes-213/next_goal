/// Interface for accessing date and time, enabling unit test mockability.
abstract class DateTimeProvider {
  DateTime now();
}

/// Concrete implementation of [DateTimeProvider] using standard [DateTime].
class DateTimeProviderImpl implements DateTimeProvider {
  const DateTimeProviderImpl();

  @override
  DateTime now() => DateTime.now();
}
