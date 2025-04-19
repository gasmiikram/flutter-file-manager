class TaskModel {
  final int? id;
  final String titre;
  final String note;
  final String date;
  final String startTime;
  final String endTime;
  final String remind;
  final String repeat;
  final int color;
  final int utilisateurId;

  TaskModel({
    this.id,
    required this.titre,
    required this.note,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.remind,
    required this.repeat,
    required this.color,
    required this.utilisateurId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'note': note,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'remind': remind,
      'repeat': repeat,
      'color': color,
      'utilisateurId': utilisateurId,
    };
  }
}
