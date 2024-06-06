class FurTask {
  late int id;
  late String name;
  late DateTime startTime;
  late DateTime stopTime;
  late String tags;
  late String totalTime;

  FurTask(this.id, this.name, String startTime, String stopTime, String tags) {
    this.startTime = DateTime.parse(startTime);
    this.stopTime = DateTime.parse(stopTime);
    if (tags.isNotEmpty) {
      this.tags = '#$tags';
    } else {
      this.tags = '';
    }

    Duration timeDifference = this.stopTime.difference(this.startTime);
    totalTime = durationToString(timeDifference.inSeconds);
  }

  Map<String, dynamic> toMap() {
    return {
      "task_name": name,
      "start_time": startTime,
      "stop_time": stopTime,
      "tags": tags,
    };
  }

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