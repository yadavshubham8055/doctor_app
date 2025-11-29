import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const DoctorConsultationApp());

class DoctorConsultationApp extends StatelessWidget {
  const DoctorConsultationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Consultation',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal, width: 2)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const DoctorListScreen(),
      routes: {
        BookAppointmentScreen.routeName: (_) => const BookAppointmentScreen(),
      },
    );
  }
}

class Doctor {
  final String name;
  final String specialization;
  final double rating;

  Doctor(this.name, this.specialization, this.rating);
}

final List<Doctor> doctors = [
  Doctor('Dr. Sanjeev', 'Cardiologist', 4.7),
  Doctor('Dr. Ram', 'Dermatologist', 3.9),
  Doctor('Dr. Sujal', 'General Physician', 4.5),
  Doctor('Dr. Kunal', 'Pediatrician', 4.9),
];

// ---------- DOCTOR LIST SCREEN ----------
class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/image.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.3),
        appBar: AppBar(
          title: const Text('Doctors'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal.withOpacity(0.8),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: doctors.length,
          itemBuilder: (_, index) {
            final d = doctors[index];
            return Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 6,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    BookAppointmentScreen.routeName,
                    arguments: d,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.teal,
                        child: Text(
                          d.name.split(' ').length > 1
                              ? d.name.split(' ')[1][0]
                              : d.name[0],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(d.specialization,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(d.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- BOOKING SCREEN ----------
class BookAppointmentScreen extends StatefulWidget {
  static const routeName = '/book-appointment';

  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late Doctor selectedDoctor;
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    selectedDoctor = args is Doctor ? args : doctors.first;
  }

  // 🔢 Generate Booking Number
  String _generateBookingNumber() {
    return "APT${100000 + Random().nextInt(900000)}";
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please complete all fields')));
      return;
    }

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final bookingNumber = _generateBookingNumber();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          patientName: _nameController.text,
          doctor: selectedDoctor,
          dateTime: appointmentDateTime,
          bookingNumber: bookingNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (v) => v!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? ' Date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(_selectedTime == null
                    ? ' Time'
                    : _selectedTime!.format(context)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- CONFIRMATION SCREEN ----------
class BookingConfirmationScreen extends StatelessWidget {
  final String patientName;
  final Doctor doctor;
  final DateTime dateTime;
  final String bookingNumber;

  const BookingConfirmationScreen({
    super.key,
    required this.patientName,
    required this.doctor,
    required this.dateTime,
    required this.bookingNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.teal),
                const SizedBox(height: 12),
                Text("Appointment Confirmed!",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text("Booking Number: $bookingNumber",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text("Patient: $patientName"),
                Text("Doctor: ${doctor.name} (${doctor.specialization})"),
                Text("Date & Time: ${dateTime.toString().substring(0, 16)}"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
