class Constants {
  static const solversRemote = SolversRemote();
  static const problems = Problems();
}

class SolversRemote {
  Status get status => const Status();
  Properties get properties => const Properties();

  const SolversRemote();
}

class Status {
  String get online => "ONLINE";
  String get offline => "OFFLINE";

  const Status();
}

class Properties {
  Category get category => const Category();

  const Properties();
}

class Category {
  String get qpu => "qpu";

  const Category();
}

class Problems {
  Type get type => const Type();

  const Problems();
}

class Type {
  String get qubo => "qubo";
  String get ising => "ising";

  const Type();
}
