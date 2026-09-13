import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// YOUR LIVE RENDER BACKEND
const String apiBase =
    'https://christian-prayer-platform.onrender.com';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Christian Prayer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const Home(),
    );
  }
}


// ================= HOME =================

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🙏 Christian Prayer Platform'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Discover • Pray • Request • Book • Purchase • Support',
          ),

          const SizedBox(height: 16),

          menuItem(
            context,
            '🙏 REQUEST PRAYER',
            null,
          ),

          menuItem(
            context,
            '📹 ONLINE VIDEO PRAYER',
            const Booking(),
          ),

          menuItem(
            context,
            '🏠 BOOK HOUSE VISIT',
            null,
          ),

          menuItem(
            context,
            '🫒 ORDER PRAYER OIL',
            null,
          ),

          menuItem(
            context,
            '🎁 OFFERINGS',
            null,
          ),

          menuItem(
            context,
            '🛒 SHOP DEVOTIONAL PRODUCTS',
            null,
          ),
        ],
      ),
    );
  }

  Widget menuItem(
    BuildContext context,
    String title,
    Widget? page,
  ) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: const Icon(Icons.chevron_right),

        onTap: page == null
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title coming soon'),
                  ),
                );
              }
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => page,
                  ),
                );
              },
      ),
    );
  }
}


// ================= BOOKING =================

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}


class _BookingState extends State<Booking> {

  final formKey = GlobalKey<FormState>();


  final nameController =
      TextEditingController();

  final mobileController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final prayerController =
      TextEditingController();

  final notesController =
      TextEditingController();


  String category = 'Personal Prayer';

  String sessionType = 'Individual';

  String language = 'English';

  int duration = 30;


  DateTime selectedDate =
      DateTime.now().add(
    const Duration(days: 1),
  );


  TimeOfDay selectedTime =
      const TimeOfDay(
    hour: 10,
    minute: 0,
  );


  bool loading = false;


  // ================= SUBMIT BOOKING =================

  Future<void> submitBooking() async {

    if (!formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      loading = true;
    });


    try {

      final response =
          await http.post(

        Uri.parse(
          '$apiBase/api/video-prayer/bookings',
        ),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({

          "name":
              nameController.text.trim(),

          "mobile":
              mobileController.text.trim(),

          "email":
              emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),

          "language":
              language,

          "category":
              category,

          "preferred_date":
              "${selectedDate.year.toString().padLeft(4, '0')}"
              "-"
              "${selectedDate.month.toString().padLeft(2, '0')}"
              "-"
              "${selectedDate.day.toString().padLeft(2, '0')}",

          "preferred_time":
              "${selectedTime.hour.toString().padLeft(2, '0')}"
              ":"
              "${selectedTime.minute.toString().padLeft(2, '0')}"
              ":00",

          "duration_minutes":
              duration,

          "session_type":
              sessionType,

          "prayer_request":
              prayerController.text.trim(),

          "additional_notes":
              notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),

        }),
      );


      final data =
          jsonDecode(response.body);


      if (!mounted) {
        return;
      }


      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        showDialog(

          context: context,

          barrierDismissible: false,

          builder: (_) {

            return AlertDialog(

              title: const Text(
                '🙏 Booking Submitted',
              ),

              content: Text(
                'Your prayer booking has been successfully created!\n\n'
                'Booking ID:\n'
                '${data["booking_id"]}\n\n'
                'Status: ${data["status"]}',
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(context);

                    Navigator.pop(context);

                  },

                  child:
                      const Text('DONE'),
                ),

              ],
            );
          },
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              'Booking failed: $data',
            ),
          ),
        );

      }

    } catch (e) {

      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Connection error: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });

      }

    }

  }


  // ================= DATE PICKER =================

  Future<void> pickDate() async {

    final date =
        await showDatePicker(

      context: context,

      initialDate:
          selectedDate,

      firstDate:
          DateTime.now(),

      lastDate:
          DateTime.now().add(
        const Duration(days: 365),
      ),

    );


    if (date != null) {

      setState(() {

        selectedDate = date;

      });

    }

  }


  // ================= TIME PICKER =================

  Future<void> pickTime() async {

    final time =
        await showTimePicker(

      context: context,

      initialTime:
          selectedTime,

    );


    if (time != null) {

      setState(() {

        selectedTime = time;

      });

    }

  }


  @override
  void dispose() {

    nameController.dispose();

    mobileController.dispose();

    emailController.dispose();

    prayerController.dispose();

    notesController.dispose();

    super.dispose();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          '📹 Book Online Prayer',
        ),
      ),


      body: Form(

        key: formKey,


        child: ListView(

          padding:
              const EdgeInsets.all(16),


          children: [

            const Text(

              'Private Online Video Prayer',

              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),

            ),


            const SizedBox(height: 16),


            textField(
              nameController,
              'Name',
              required: true,
            ),


            textField(
              mobileController,
              'Mobile number',
              required: true,
              keyboardType:
                  TextInputType.phone,
            ),


            textField(
              emailController,
              'Email',
              keyboardType:
                  TextInputType.emailAddress,
            ),


            dropdown(

              'Language',

              language,

              [
                'English',
                'Telugu',
                'Hindi',
                'Tamil',
                'Malayalam',
              ],

              (value) {

                setState(() {

                  language = value!;

                });

              },

            ),


            dropdown(

              'Prayer Category',

              category,

              [

                'Personal Prayer',

                'Family Prayer',

                'Thanksgiving Prayer',

                'Bible Prayer',

                'Special Prayer Request',

                'Counseling/Spiritual Fellowship',

                'Emergency Prayer Request',

              ],

              (value) {

                setState(() {

                  category = value!;

                });

              },

            ),


            Card(

              child: ListTile(

                leading:
                    const Icon(
                  Icons.calendar_month,
                ),

                title:
                    const Text(
                  'Preferred Date',
                ),

                subtitle:
                    Text(
                  '${selectedDate.day}/'
                  '${selectedDate.month}/'
                  '${selectedDate.year}',
                ),

                onTap: pickDate,

              ),

            ),


            Card(

              child: ListTile(

                leading:
                    const Icon(
                  Icons.access_time,
                ),

                title:
                    const Text(
                  'Preferred Time',
                ),

                subtitle:
                    Text(
                  selectedTime
                      .format(context),
                ),

                onTap: pickTime,

              ),

            ),


            dropdown(

              'Duration',

              '$duration minutes',

              [

                '15 minutes',

                '30 minutes',

                '45 minutes',

                '60 minutes',

              ],

              (value) {

                setState(() {

                  duration =
                      int.parse(
                    value!
                        .split(' ')
                        .first,
                  );

                });

              },

            ),


            dropdown(

              'Session Type',

              sessionType,

              [

                'Individual',

                'Family',

                'Group',

              ],

              (value) {

                setState(() {

                  sessionType =
                      value!;

                });

              },

            ),


            textField(

              prayerController,

              'Prayer Request',

              required: true,

              maxLines: 4,

            ),


            textField(

              notesController,

              'Additional Notes',

              maxLines: 3,

            ),


            const SizedBox(height: 20),


            SizedBox(

              height: 55,


              child:
                  FilledButton(

                onPressed:
                    loading
                        ? null
                        : submitBooking,


                child:
                    loading

                        ? const CircularProgressIndicator()

                        : const Text(
                            'CONFIRM PRAYER BOOKING',
                          ),

              ),

            ),

          ],

        ),

      ),

    );

  }


  // ================= TEXT FIELD =================

  Widget textField(

    TextEditingController controller,

    String label,

    {

    bool required = false,

    TextInputType?
        keyboardType,

    int maxLines = 1,

  }) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),


      child:
          TextFormField(

        controller:
            controller,

        keyboardType:
            keyboardType,

        maxLines:
            maxLines,


        decoration:
            InputDecoration(

          labelText:
              label,

          border:
              const OutlineInputBorder(),

        ),


        validator:
            required

                ? (value) {

                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {

                      return 'Please enter $label';

                    }

                    return null;

                  }

                : null,

      ),

    );

  }


  // ================= DROPDOWN =================

  Widget dropdown(

    String label,

    String value,

    List<String> items,

    ValueChanged<String?>
        onChanged,

  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),


      child:
          DropdownButtonFormField<String>(

        value:
            value,


        decoration:
            InputDecoration(

          labelText:
              label,

          border:
              const OutlineInputBorder(),

        ),


        items:
            items.map(

          (item) {

            return DropdownMenuItem(

              value:
                  item,

              child:
                  Text(item),

            );

          },

        ).toList(),


        onChanged:
            onChanged,

      ),

    );

  }

}
