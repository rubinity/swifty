
parseHeaders(String link, String type, Map<String, String> links) {
  String omit = "";
  Map<String, String> curr = {};
  RegExp urlPattern = RegExp(r'<(\S+)>; rel="(\S+)"');
  Iterable<RegExpMatch> matches = urlPattern.allMatches(link);
  if (matches.isEmpty)
    return;
  //creating a map of values
  for (RegExpMatch match in matches) {
    String linkType = match.group(2)!;
    curr[match.group(2)!] = match.group(1)!;
  }

  if (type == "next")
    omit = "prev";
  else if (type == "prev")
    omit = "next";
  //copying map
  for (var key in links.keys){
    if (key != omit ){
      if (curr[key] != null)
        links[key] = curr[key]!;
      else
        links[key] = "";
    }
  }


}

List getPageFromUrl(String url){
  RegExp urlPattern = RegExp(r'[\?&]page=(\d+)&');
  RegExpMatch? match = urlPattern.firstMatch(url);
  if (match == null)
    return [];
  else
    return [match.group(1)!, match?.start, match?.end];
}

String replacePage(String url, String newPage, int start, int end){
  return url.replaceRange(start + 6, end - 1, newPage);
}

