import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../Services/firestore_service.dart';
import '../model/task_model.dart';
import '../Services/alarm_service.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _image;
  bool _isUploading = false;
  bool _isImportant = false; // 🔥 New field

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF5E1A4),
              onPrimary: Color(0xFF8B0000),
              onSurface: Color(0xFFD4AF37),
            ),
            dialogBackgroundColor: Color(0xFFFFF9F0),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFD4AF37)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF5E1A4),
              onPrimary: Color(0xFF8B0000),
              onSurface: Color(0xFFD4AF37),
            ),
            dialogBackgroundColor: Color(0xFFFFF9F0),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dxen7924h';
    const uploadPreset = 'flutter_unsigned';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty || _selectedDate == null || _selectedTime == null) return;

    setState(() => _isUploading = true);

    String imageUrl = '';
    if (_image != null) {
      final uploadedUrl = await _uploadToCloudinary(_image!);
      if (uploadedUrl != null) imageUrl = uploadedUrl;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final task = Task(
      id: UniqueKey().toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: dateTime,
      imageUrl: imageUrl,
      isImportant: _isImportant, // 🔥 Important flag added
    );

    await Provider.of<FirestoreService>(context, listen: false).addTask(task);

    final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await AndroidAlarmManager.oneShotAt(
      dateTime,
      alarmId,
      AlarmService.buzzTask,
      exact: true,
      wakeup: true,
    );

    setState(() => _isUploading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F0),
      appBar: AppBar(
        title: Text("Add Task", style: TextStyle(fontFamily: 'GenshinFont', color: Color(0xFFD4AF37))),
        backgroundColor: Color(0xFFF5E1A4),
        elevation: 3,
        iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
        foregroundColor: Color(0xFFD4AF37),
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInputField("Title", _titleController),
                    SizedBox(height: 10),
                    _buildInputField("Description", _descriptionController, maxLines: 3),
                    SizedBox(height: 20),
                    _buildDateTimeRow(
                      icon: Icons.calendar_month_outlined,
                      label: _selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(_selectedDate!),
                      actionLabel: "Pick Date",
                      onTap: _pickDate,
                    ),
                    SizedBox(height: 12),
                    _buildDateTimeRow(
                      icon: Icons.access_time,
                      label: _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context),
                      actionLabel: "Pick Time",
                      onTap: _pickTime,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.priority_high_rounded, color: Color(0xFFD4AF37)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text("Mark as Important", style: TextStyle(color: Color(0xFFD4AF37))),
                        ),
                        Switch(
                          value: _isImportant,
                          activeColor: Color(0xFFD4AF37),
                          onChanged: (value) {
                            setState(() => _isImportant = value);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.transparent,
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: Color(0xFFD4AF37), width: 2),
                        ),
                        child: _image == null
                            ? Center(
                                child: Icon(Icons.add_a_photo_rounded,
                                    size: 50, color: Color(0xFFD4AF37)),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Color.fromARGB(255, 162, 154, 6)),
                        label: Text("Save Task", style: TextStyle(color: Color(0xFFFFF9F0))),
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFFF5E1A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Color(0xFFD4AF37)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFD4AF37)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF5E1A4)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow({
    required IconData icon,
    required String label,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFD4AF37)),
        SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: Color(0xFFD4AF37)))),
        ElevatedButton(
          onPressed: onTap,
          child: Text(actionLabel, style: TextStyle(color: Color(0xFFFFF9F0))),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF5E1A4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }
}
