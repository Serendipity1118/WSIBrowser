// Domain and path matching (F-03-1). Same semantics as WSI's matchesDomain:
//   '*'            every host
//   '*.example.com' example.com and any subdomain
//   'example.com'   exact host
// `paths` are globs against location.pathname: '*' matches within one
// segment, '**' matches across segments. No paths = every path.

bool matchesDomain(String hostname, List<String> domains) {
  final host = hostname.toLowerCase();
  if (host.isEmpty) return false;
  for (final pattern in domains) {
    final p = pattern.toLowerCase();
    if (p == '*') return true;
    if (p.startsWith('*.')) {
      final suffix = p.substring(2);
      if (host == suffix || host.endsWith('.$suffix')) return true;
    } else if (host == p) {
      return true;
    }
  }
  return false;
}

bool matchesPath(String path, List<String> globs) {
  if (globs.isEmpty) return true;
  final p = path.isEmpty ? '/' : path;
  return globs.any((g) => globToRegExp(g).hasMatch(p));
}

final Map<String, RegExp> _globCache = {};

RegExp globToRegExp(String glob) {
  return _globCache.putIfAbsent(glob, () {
    final sb = StringBuffer('^');
    for (var i = 0; i < glob.length; i++) {
      final c = glob[i];
      if (c == '*') {
        if (i + 1 < glob.length && glob[i + 1] == '*') {
          sb.write('.*');
          i++;
          // '/**' at the end also matches the bare directory ('/manage' for '/manage/**')
          if (i + 1 >= glob.length && sb.toString().endsWith('/.*')) {
            final s = sb.toString();
            sb.clear();
            sb.write('${s.substring(0, s.length - 3)}(/.*)?');
          }
        } else {
          sb.write('[^/]*');
        }
      } else if (c == '?') {
        sb.write('[^/]');
      } else {
        sb.write(RegExp.escape(c));
      }
    }
    sb.write(r'$');
    return RegExp(sb.toString());
  });
}

/// True when the plugin declared for [domains] / [paths] applies to [url].
bool matchesUrl(Uri url, List<String> domains, List<String> paths) {
  return matchesDomain(url.host, domains) && matchesPath(url.path, paths);
}
