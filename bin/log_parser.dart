import 'git_log.dart';
import 'dart:convert';

import 'git_log_error.dart';

class LogParser {
  final errors = <GitLogError>[];
  static const lineStartMarker = "^^^";
  static const gitLogArgs = <String>[
    "log",
    '--format="$lineStartMarker%H|%D|%an|%ae|%ai|%cn|%ce|%ci"',
    '--since="6 months ago"',
    "--shortstat"
  ];

  List<GitLog> parse(String repo, String commitString) {
    print("Parsing log...");
    var cleanedCommit = removeEmptyLines(deQuote(commitString));

    final commits = <GitLog>[];
    var lineNumber = 0;
    while (lineNumber < cleanedCommit.length) {
      if (cleanedCommit[lineNumber].startsWith(lineStartMarker)) {
        //Most of the fields are on the 1st row; the counts are on the 3rd
        var cleanedCommitFields = separateIntoFields(cleanedCommit[lineNumber]);
        var changesFields = separateIntoFields(cleanedCommit[lineNumber + 2]);

        //Process the main body of the log message
        var commit =
            GitLog(cleanedCommitFields[0].replaceAll(lineStartMarker, ""));
        commit.repo = repo;
        commit.refNames = cleanedCommitFields[1];
        commit.authorName = cleanedCommitFields[2];
        commit.authorEmail = cleanedCommitFields[3];
        commit.authorDate = cleanedCommitFields[4];
        commit.commitName = cleanedCommitFields[5];
        commit.commitEmail = cleanedCommitFields[6];
        commit.commitDate = cleanedCommitFields[7];
        setChanges(commit, changesFields);
        commits.add(commit);
      }
      lineNumber++;
    }
    print("Parsed ${commits.length} items.");
    return commits;
  }

  String deQuote(String original) {
    return original.replaceAll("\"", "");
  }

  List<String> removeEmptyLines(String commitString) {
    return LineSplitter().convert(commitString);
  }

  List<String> separateIntoFields(String cleanedCommitString) {
    return cleanedCommitString.split('|');
  }

  void setChanges(GitLog commit, List<String> changesFields) {
    for (final element in changesFields) {
      if (element.contains("files changed")) {
        commit.filesChanged = extractInt(element);
      }

      if (element.contains("insertions")) {
        commit.insertions = extractInt(element);
      }

      if (element.contains("deletions")) {
        commit.deletions = extractInt(element);
      }
    }
  }

  int extractInt(String field) {
    var chunks = field.split(" ");
    for (final chunk in chunks) {
      final value = int.tryParse(chunk);
      if (value != null) return value;
    }
    return 0;
  }

  handleParseError(String context, String description) {
    errors.add(GitLogError(context, description));
  }
}
