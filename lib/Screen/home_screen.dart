import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/firestore_service.dart';
import '../model/task_model.dart';
import 'add_task_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart'; // <-- You'll need to create this
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color creamBackground = const Color(0xFFFFF9F0);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color lightGold = const Color(0xFFF5E1A4);
  final Color lightGreen = const Color(0xFF7BC47F);
  final Color darkRed = const Color(0xFF8B0000);

  final Set<String> selectedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: creamBackground,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: goldColor, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text("Todo List",
            style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        backgroundColor: creamBackground.withOpacity(0.95),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset('assets/welcome-3.jpg', width: 150, height: 150, fit: BoxFit.cover),
                    const SizedBox(height: 12),
                    Text("Welcome, traveler!",
                        style: TextStyle(
                            color: goldColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, thickness: 0.5),
              ListTile(
  leading: Icon(Icons.dashboard, color: goldColor),
  title: Text(
    "Dashboard",
    style: TextStyle(color: goldColor, fontWeight: FontWeight.w600),
  ),
  onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  },
),

              ListTile(
                leading: Icon(Icons.person, color: goldColor),
                title: Text("Profile",
                    style:
                        TextStyle(color: goldColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: goldColor),
                title: Text("Logout",
                    style:
                        TextStyle(color: goldColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Task>>(
        stream: Provider.of<FirestoreService>(context).getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: goldColor));
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return Center(
              child: Text("No tasks yet, start your journey!",
                  style: TextStyle(color: goldColor, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isSelected = selectedTaskIds.contains(task.id);

              return Card(
                color: Colors.white.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selectedTaskIds.remove(task.id)
                            : selectedTaskIds.add(task.id);
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected ? lightGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: goldColor, width: 2),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: lightGreen, size: 20)
                          : null,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(task.title,
                            style: TextStyle(
                                color: goldColor,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Provider.of<FirestoreService>(context, listen: false)
                              .toggleTaskImportance(task.id, task.isImportant);
                        },
                        child: Icon(
                          task.isImportant ? Icons.star : Icons.star_border,
                          color: task.isImportant ? Colors.orange : goldColor,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(task.description,
                      style: TextStyle(color: goldColor.withOpacity(0.8))),
                  trailing: isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: lightGreen),
                              onPressed: () {
                                Provider.of<FirestoreService>(context,
                                        listen: false)
                                    .toggleTaskCompletion(
                                        task.id, task.isCompleted);
                                setState(() => selectedTaskIds.remove(task.id));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: darkRed),
                              onPressed: () {
                                Provider.of<FirestoreService>(context,
                                        listen: false)
                                    .deleteTask(task.id);
                                setState(() => selectedTaskIds.remove(task.id));
                              },
                            ),
                          ],
                        )
                      : null,
                  onLongPress: () {
                    setState(() {
                      isSelected
                          ? selectedTaskIds.remove(task.id)
                          : selectedTaskIds.add(task.id);
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lightGold,
        foregroundColor: goldColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddTaskScreen())),
      ),
    );
  }
}
