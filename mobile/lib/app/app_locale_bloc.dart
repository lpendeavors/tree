import 'dart:ui';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../bloc/bloc_provider.dart';
import '../shared_pref_util.dart';

final supportedLocaleTitle = <Locale, String>{
  const Locale('en', ''): 'English - en',
};

///
/// Bloc handling change locale and get stream locales
/// Used to support multi language in app
///
class LocaleBloc implements BaseBloc {
  ///
  /// Sinks
  ///
  final Sink<Locale> changeLocale;

  ///
  /// Streams
  ///
  final ValueStream<Locale> locale$;

  ///
  /// Tuple2 with Tuple2.item1 is result (true for successful, false for failure),
  /// Tuple2.item2 is error (nullable)
  ///
  final Stream<Tuple2<bool, Object>> changeLocaleResult$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  LocaleBloc._(
    this.changeLocale,
    this.locale$,
    this._dispose,
    this.changeLocaleResult$,
  );

  factory LocaleBloc(SharedPrefUtil sharedPrefUtil) {
    assert(sharedPrefUtil != null, 'sharedPrefUtil cannot be null');
    final changeLocaleController = PublishSubject<Locale>(sync: true);

    final changeLocaleResult$ = changeLocaleController.distinct().switchMap((locale) {
      return Stream.fromFuture(sharedPrefUtil.saveSelectedLanguageCode(locale.languageCode))
        .map((result) => Tuple2(result, null))
        .onErrorReturnWith((e) => Tuple2(null, e));
    }).publish();

    final selectedLanguageCode$ = sharedPrefUtil.selectedLanguageCode$;
    final selectedLanguageCode = selectedLanguageCode$.value;
    toLocale(String code) => Locale(code, '');

    final locale$ = selectedLanguageCode$.map(toLocale)
      .publishValueSeededDistinct(
        seedValue: selectedLanguageCode == null ? null : toLocale(selectedLanguageCode)
      );

    final subscriptions = [
      locale$.connect(),
      changeLocaleResult$.connect(),
    ];

    return LocaleBloc._(
      changeLocaleController.sink,
      locale$,
      () {
        changeLocaleController.close();
        subscriptions.forEach((s) => s.cancel());
      },
      changeLocaleResult$,
    );
  }

  @override
  void dispose() => _dispose();
}