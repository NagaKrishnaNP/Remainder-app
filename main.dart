import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReminderHome(),
    );
  }
}

class ReminderHome extends StatefulWidget {
  @override
  _ReminderHomeState createState() => _ReminderHomeState();
}

class _ReminderHomeState extends State<ReminderHome> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String selectedDay = 'Monday';
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedActivity = 'Wake up';

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    loadReminder();
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  Future<void> _scheduleNotification() async {
    var time = Time(selectedTime.hour, selectedTime.minute, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'notification_sound.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      selectedActivity,
      'It\'s time to $selectedActivity!',
      time,
      platformChannelSpecifics,
    );

    saveReminder();
  }

  void saveReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDay', selectedDay);
    await prefs.setInt('selectedHour', selectedTime.hour);
    await prefs.setInt('selectedMinute', selectedTime.minute);
    await prefs.setString('selectedActivity', selectedActivity);
  }

  void loadReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDay = prefs.getString('selectedDay') ?? 'Monday';
      selectedTime = TimeOfDay(
        hour: prefs.getInt('selectedHour') ?? TimeOfDay.now().hour,
        minute: prefs.getInt('selectedMinute') ?? TimeOfDay.now().minute,
      );
      selectedActivity = prefs.getString('selectedActivity') ?? 'Wake up';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (String newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Text("Time: ${selectedTime.format(context)}"),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    _selectTime(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: <String>[
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
