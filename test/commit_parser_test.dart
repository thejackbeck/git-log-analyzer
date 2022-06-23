import 'package:test/test.dart';
import '../bin/log_parser.dart';
import '../bin/git_log.dart';

void main() {
  test("Parse Test", () {
    var commit = _commitParser.parse(_sampleRepo, _sampleData);
    expect(commit.toString(), getSampleCommit().toString());
  });
}

final _commitParser = LogParser();
final _sampleRepo = "foo";
final _sampleData =
    """a9c0b050e077972a25156a2e133931a8efd55546,HEAD -> master,Damián López,dlopez@medxoom.com,2022-02-08 19:10:08 +0000,Damián López,dlopez@medxoom.com,2022-02-08 19:10:08 +0000

 3 files changed, 18 insertions(+)""";

GitLog getSampleCommit() {
  final sampleCommit = GitLog("a9c0b050e077972a25156a2e133931a8efd55546");
  sampleCommit.repo = _sampleRepo;
  sampleCommit.refNames = "HEAD -> master";
  sampleCommit.authorName = "Damián López";
  sampleCommit.authorEmail = "dlopez@medxoom.com";
  sampleCommit.authorDate = "2022-02-08 19:10:08 +0000";
  sampleCommit.commitName = "Damián López";
  sampleCommit.commitEmail = "dlopez@medxoom.com";
  sampleCommit.commitDate = "2022-02-08 19:10:08 +0000";
  sampleCommit.filesChanged = 3;
  sampleCommit.insertions = 18;
  sampleCommit.deletions = 0;

  return sampleCommit;
}
