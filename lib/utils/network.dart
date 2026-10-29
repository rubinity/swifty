// Map<String, String> parseHeaders(String link)
// {
//   Map<String, String> r = {};
//   RegExp urlPattern = RegExp(r'<(\S+)>; rel="(\S+)"');
//   Iterable<RegExpMatch> matches = urlPattern.allMatches(link);
//   if (matches.isEmpty)
//     return {};
//   for (RegExpMatch match in matches) {
//     r[match.group(2)!] = match.group(1)!;
//   };
//   return r;
// }
// enum mode {"next", "prev", "none"}

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
  // print("curr links ${curr}");
  // print("type ${type}");
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


  // if (type == "next" || type == "prev") {
  //   if (curr[type] == null) {
  //     print("null or not: ${curr[type]}, type: $type");
  //     links[type] = "";
  //     print("check after update: ${links[type]}");
  //   }
  //   else {
  //       links[type] = curr[type]!;
  //   }
  // }
  // else {
  //   curr.forEach((type, url){
  //     links[type] = curr[type]!;
  //   });
  // }
  // if (curr["last"] != null)
  //     links["last"] = curr["last"]!;
  // else
  //   links["last"] = "";
  // if (curr["first"] != null)
  //     links["first"] = curr["first"]!;
  // else
  //   links["first"] = "";
  // print("flinks after copy $links");

}



List getPageFromUrl(String url){
  RegExp urlPattern = RegExp(r'[\?&]page=(\d+)&');
  RegExpMatch? match = urlPattern.firstMatch(url);
  // print("start ${match?.start}");
  if (match == null)
    return [];
  else
    return [match.group(1)!, match?.start, match?.end];
}

String replacePage(String url, String newPage, int start, int end){
return url.replaceRange(start + 6, end - 1, newPage);
}

