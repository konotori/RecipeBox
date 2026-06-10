import NaviStack

/// The app's concrete NaviStack router, specialised for our route enums.
/// One instance per tab (see ``RootTabView``).
typealias AppRouter = BaseRouter<AppRoute, AppSheet, AppCover>
