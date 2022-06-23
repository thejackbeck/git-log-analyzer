class GitLogError {
  String context;
  Object error;

  GitLogError(this.context, this.error);

  @override
  String toString() {
    return "$context - $error";
  }
}
