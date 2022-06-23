import 'package:git/git.dart' as git;
import 'dart:io';
import 'log_parser.dart';
import 'git_log.dart';
import 'git_log_error.dart';

final parser = LogParser();
final logs = <GitLog>[];
final gitRoot = "/Users/jack/Dev/medxoom";
final repoList = <String>[];
final outputFileName = "./GitLogsData.csv";
final errors = <GitLogError>[];
final processed = <String>[];

void main() async {
  try {
    populateRepoList(gitRoot, repoList);
  } catch (e) {
    handleIOException("Reading gitRoot directory.", e);
    exit(0);
  }

  for (final dir in repoList) {
    try {
      final gitDir = await getGitDir(dir);
      await pull(gitDir);
      final logString = await getLog(gitDir);
      logs.addAll(parser.parse(gitDir.path, logString));
      processed.add(dir);
    } catch (e) {
      handleGitError(dir, e);
    }
  }

  try {
    writeCSVFile(logs, outputFileName);
  } catch (e) {
    handleIOException("Writing file.", e);
  }

  writeErrorFile(errors, "./GitLogsFileErrors.txt");
  print("File Errors:");
  for (final e in errors) {
    print(e);
  }

  writeErrorFile(parser.errors, "./GitLogsParseErrors.txt");
  print("Parse Errors:");
  for (final e in parser.errors) {
    print(e);
  }

  print("Repos processed:");
  for (final p in processed) {
    print(p);
  }
}

void populateRepoList(String gitRoot, List<String> repoList) {
  final dir = Directory(gitRoot);
  final List<FileSystemEntity> fileSystemEntities = dir.listSync().toList();
  final Iterable<Directory> dirs = fileSystemEntities.whereType<Directory>();
  for (final dir in dirs) {
    repoList.add(dir.path);
  }
}

Future<git.GitDir> getGitDir(String dir) async {
  print('Checking directory $dir');
  if (await git.GitDir.isGitDir(dir)) {
    return await git.GitDir.fromExisting(dir);
  } else {
    throw Exception("$dir is not a Git repo.");
  }
}

Future<void> pull(git.GitDir gitDir) async {
  print('Pulling...');
  gitDir.runCommand(["pull"]);
}

Future<String> getLog(git.GitDir gitDir) async {
  print('Getting log...');
  try {
    final processResult = await gitDir.runCommand(LogParser.gitLogArgs);
    return processResult.stdout.toString();
  } catch (e) {
    handleIOException("Reading $gitDir", e);
    return "";
  }
}

void writeCSVFile(List<GitLog> gitLogs, String fileName) {
  print("Writing to file $fileName");
  var fileHandle = File(fileName);

  fileHandle.writeAsStringSync(GitLog.getCSVHeaders() + "\r");
  for (final log in gitLogs) {
    fileHandle.writeAsStringSync("${log.toCSV()}\r", mode: FileMode.append);
  }
}

void writeErrorFile(List<GitLogError> errors, String fileName) {
  print("Writing to file $fileName");
  var fileHandle = File(fileName);

  fileHandle.writeAsStringSync("${DateTime.now()}\r", mode: FileMode.append);
  for (final e in errors) {
    fileHandle.writeAsStringSync("$e\r", mode: FileMode.append);
  }
}

void handleGitError(String context, Object e) {
  print("Unable to get log $e");
  errors.add(GitLogError(context, e));
}

void handleIOException(String context, Object e) {
  print("IO Exception occured $e");
  errors.add(GitLogError(context, e));
}
