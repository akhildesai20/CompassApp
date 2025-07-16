/// Convert degrees to a cardinal direction string (N, NE, E, …)
String cardinal(double heading) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return dirs[((heading % 360) / 45).round() % 8];
}
