class Event {
  Event({
    required this.id,
    required this.name,
    required this.description,
    this.iconEmoji,
    required this.startTime,
    required this.endTime,
    this.allocatedTicketCountPerUser = 100,
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

  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    DateTime? startTime,
    DateTime? endTime,
    int? allocatedTicketCountPerUser,
    ConditionsOfAccess? conditionsOfAccess,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allocatedTicketCountPerUser: allocatedTicketCountPerUser ?? this.allocatedTicketCountPerUser,
      conditionsOfAccess: conditionsOfAccess ?? this.conditionsOfAccess,
    );
  }
}

enum ConditionsOfAccess {
  public,
  private,
}
