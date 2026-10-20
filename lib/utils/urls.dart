
String addToUrl(String urlStart, String urlEnd, int insert){
  return ("$urlStart/$insert$urlEnd");
}

String buildUrl(String url, Map<String, String> filter){
  if (filter.isEmpty)
    return url;
  String output = "$url?";
  filter.forEach( (param, value){
    if (param == "page")
      output = "${output}page=$value";
    else if (param == "per_page")
      output = "${output}&per_page=$value";
    else if (param.substring(0, 6) == "range_")//change for different ranges using regex
      output = "${output}&range[${param.substring(6)}]=${value},${value}zzzzzzzzz";
    else
      output = "${output}&filter[$param]=$value";
  });
  return output;
}

String addSize(String url, int size){
  return ('$url?page[size]=$size');
}

