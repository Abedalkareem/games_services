enum TimeScope { today, week, allTime }

extension TimeScopeValue on TimeScope {
  int get value {
    return index;
  }
}
