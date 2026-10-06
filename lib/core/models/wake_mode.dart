enum WakeMode { timed, indefinite, appBound }

WakeMode wakeModeFromNative(String value) {
  switch (value) {
    case 'TIMED':
      return WakeMode.timed;
    case 'APP_BOUND':
      return WakeMode.appBound;
    case 'INDEFINITE':
    default:
      return WakeMode.indefinite;
  }
}
