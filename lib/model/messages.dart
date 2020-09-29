class Messages {
  final String content;
  final String idFrom;
  final String idTo;
  final String timestamp;
  final int type;
  final String time;

  Messages({
    this.content,
    this.idFrom,
    this.idTo,
    this.timestamp,
    this.type,
    this.time,
  });
  static Messages fromJson(Map<String, dynamic> map) {
    if (map == null) return null;
    return Messages(
      content: map['content'],
      idFrom: map['idFrom'],
      idTo: map['idTo'],
      timestamp: map['timestamp'],
      type: map['type'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': 'content',
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'type': type,
      'time': time,
    };
  }
}
