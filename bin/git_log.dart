class GitLog {
  String hash;
  String repo = "";
  String refNames = "";
  String authorName = "";
  String authorEmail = "";
  String authorDate = "";
  String commitName = "";
  String commitEmail = "";
  String commitDate = "";
  int filesChanged = 0;
  int insertions = 0;
  int deletions = 0;

  GitLog(this.hash);

  String toCSV() {
    return '"$hash","$repo","$refNames","$authorName","$authorEmail",$authorDate,"$commitName","$commitEmail",$commitDate,$filesChanged,$insertions,$deletions';
  }

  static String getCSVHeaders() {
    return 'hash,repo,refNames,authorName,authorEmail,authorDate,commitName,commitEmail,commitDate,filesChanged,insertions,deletions';
  }

  @override
  String toString() {
    return """Commit: {
      hash: $hash,
      repo: $repo, 
      refNames: $refNames, 
      authorName: $authorName,
      authorEmail: $authorEmail,
      authorDate: $authorDate,
      commitName: $commitName,
      commitEmail: $commitEmail,
      commitDate: $commitDate,
      filesChanged: $filesChanged,
      insertions: $insertions,
      deletions: $deletions
    }""";
  }
}
