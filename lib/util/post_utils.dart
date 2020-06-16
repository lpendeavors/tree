
getAbbreviatedPost(String post) {
  if ((post ?? "").length > 300) {
    return post.substring(0, 300);
  }
  return post;
}