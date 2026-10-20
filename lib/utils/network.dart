Map<String, String> parseHeaders(String link)
{
  Map<String, String> r = {};
  RegExp urlPattern = RegExp(r'<(\S+)>; rel="(\S+)"');
  Iterable<RegExpMatch> matches = urlPattern.allMatches(link);
  if (matches.isEmpty)
    return {};
  for (RegExpMatch match in matches) {
    r[match.group(2)!] = match.group(1)!;
  };
  return r;
}


