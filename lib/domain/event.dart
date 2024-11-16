class Event {
  Event({
    required this.id,
    required this.name,
    required this.description,
    this.iconEmoji,
    required this.startTime,
    required this.endTime,
    this.allocatedTicketCountPerUser = 10,
    this.conditionsOfAccess = ConditionsOfAccess.public,
  });

  String id;
  String name;
  String description;
  String? iconEmoji;
  DateTime startTime;
  DateTime endTime;
  int allocatedTicketCountPerUser;
  ConditionsOfAccess conditionsOfAccess;
}

enum ConditionsOfAccess {
  public,
  private,
}
