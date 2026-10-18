import 'package:flutter/material.dart';

void goToPage(context, route){
  if (ModalRoute.of(context)?.settings.name != route)
    Navigator.pushNamed(context, route);
  else
    Navigator.pop(context);
}

// void printMatch(RegExp pattern, String input){
//   String match = pattern.allMatches(input)[0];
// }

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