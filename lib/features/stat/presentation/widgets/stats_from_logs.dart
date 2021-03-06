import 'package:flutter/material.dart';
import 'package:flutter_achiver/core/presentation/res/constants.dart';
import 'package:flutter_achiver/core/presentation/res/functions.dart';
import 'package:flutter_achiver/core/presentation/res/styles.dart';
import 'package:flutter_achiver/core/presentation/widgets/bordered_container.dart';
import 'package:flutter_achiver/features/stat/data/model/log_model.dart';
import 'package:flutter_achiver/features/stat/presentation/widgets/stats_tile.dart';
import 'package:flutter_achiver/features/stat/res/constants.dart';
import 'stats_block.dart';

class StatsFromLogs extends StatefulWidget {
  final List<WorkLog> logs;
  final ChartTimeType chartTimeType;
  final bool showProjects;
  const StatsFromLogs(
      {Key key,
      @required this.logs,
      this.chartTimeType = ChartTimeType.WEEKLY,
      this.showProjects = true})
      : super(key: key);

  @override
  _StatsFromLogsState createState() => _StatsFromLogsState();
}

class _StatsFromLogsState extends State<StatsFromLogs> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(StatsFromLogs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logs != widget.logs) calculateStats();
  }

  Duration totalTimeSpent;
  Map<int, Duration> timeSpentByDays;
  Map<String, Duration> timeSpentByProjects;
  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  calculateStats() {
    totalTimeSpent = Duration.zero;
    timeSpentByDays = <int, Duration>{
      1: Duration.zero,
      2: Duration.zero,
      3: Duration.zero,
      4: Duration.zero,
      5: Duration.zero,
      6: Duration.zero,
      7: Duration.zero,
    };
    timeSpentByProjects = {};
    widget.logs.forEach((lg) {
      totalTimeSpent += lg.duration;
      timeSpentByDays[lg.date.weekday] += lg.duration;
      if (timeSpentByProjects[lg.project.title] == null)
        timeSpentByProjects[lg.project.title] = lg.duration;
      else
        timeSpentByProjects[lg.project.title] += lg.duration;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logs.length < 1)
      return Container(
        child: Text("Sorry no records found"),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "You have completed "),
                  TextSpan(text: "${widget.logs.length}", style: boldText),
                  TextSpan(
                      text: " work sessions during this period. Awesome job!")
                ]),
              ),
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () => Navigator.pushNamed(context, 'log_list',
                  arguments: widget.logs),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        BorderedContainer(
          padding: const EdgeInsets.all(8.0),
          color: Colors.pink.shade400,
          child: Row(
            children: <Widget>[
              Text(
                "Total time worked",
                style: boldText.copyWith(color: Colors.white70),
              ),
              Spacer(),
              const SizedBox(width: 10.0),
              StatsBlock(
                child: Text(
                  "${durationToHMString(totalTimeSpent)}",
                  style: titleStyle.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (!isDaily(widget.chartTimeType)) ...[
          const SizedBox(height: 10.0),
          Text("Time worked by day of the week"),
          _buildStatByDays(context),
        ],
        if (widget.showProjects) ...[
          const SizedBox(height: 10.0),
          Text("Projects worked on"),
          _buildStatByProjects(context),
        ],
      ],
    );
  }

  BorderedContainer _buildStatByDays(BuildContext context) {
    return BorderedContainer(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          ...[7, 1, 2, 3, 4, 5, 6].map(
            (day) => new StatTile(
              barWidth: timeSpentByDays[day].inSeconds > 0
                  ? MediaQuery.of(context).size.width *
                      (timeSpentByDays[day].inSeconds /
                          totalTimeSpent.inSeconds)
                  : 0,
              title: days[day],
              percent:
                  "${(timeSpentByDays[day].inSeconds / totalTimeSpent.inSeconds * 100).toStringAsFixed(0)}%",
              hours: "${durationToHMString(timeSpentByDays[day])}",
            ),
          ),
        ],
      ),
    );
  }

  BorderedContainer _buildStatByProjects(BuildContext context) {
    return BorderedContainer(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          ...timeSpentByProjects.keys.map(
            (project) => StatTile(
              barWidth: timeSpentByProjects[project].inSeconds > 0
                  ? MediaQuery.of(context).size.width *
                      (timeSpentByProjects[project].inSeconds /
                          totalTimeSpent.inSeconds)
                  : 0,
              title: project,
              hours: "${durationToHMString(timeSpentByProjects[project])}",
              percent:
                  "${(timeSpentByProjects[project].inSeconds / totalTimeSpent.inSeconds * 100).toStringAsFixed(0)}%",
            ),
          ),
        ],
      ),
    );
  }
}
