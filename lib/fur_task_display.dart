class FurTaskDisplay {

  String name;
  String tags;
  late String fullName;
  int totalSeconds;
  late String totalTime;
  String startDate;
  DateTime stopTime;
  List<int> idsWithin = [];

  FurTaskDisplay(int id, this.name, this.tags, this.stopTime, this.totalSeconds, this.startDate) {
    idsWithin.add(id);
    totalTime = durationToString(totalSeconds);
    fullName = '$name $tags';
  }

  void addTime(int duration) {
    totalSeconds += duration;
    totalTime = durationToString(totalSeconds);
  }

  void updateStartTime(DateTime stopTime) {
    this.stopTime = stopTime;
  }

  void addID(int id) {
    idsWithin.add(id);
  }

  // Move this or remove it from FurTask so it's not duplicated
  // FurTask could only show num seconds for total time
  String durationToString(int duration) {
    var hours = duration ~/ Duration.secondsPerHour;
    duration = duration.remainder(Duration.secondsPerHour);

    var minutes = duration ~/ Duration.secondsPerMinute;
    duration = duration.remainder(Duration.secondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = duration;

    var secondsPadding = seconds < 10 ? "0" : "";

    return "$hours:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }

}