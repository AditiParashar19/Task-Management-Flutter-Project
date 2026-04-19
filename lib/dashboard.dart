import 'package:flutter/material.dart';
import 'tabs_content.dart';

class MainDashboard extends StatefulWidget {
  final VoidCallback onLogout;
  const MainDashboard({super.key, required this.onLogout});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _tasks = [];
  final List<Map<String, String>> _notes = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TasksPage(tasks: _tasks, onUpdate: () => setState(() {})),
      SchedulePage(tasks: _tasks),
      NotesPage(notes: _notes, onUpdate: () => setState(() {})),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? "Tasks"
              : _selectedIndex == 1
              ? "Schedule"
              : "Notes",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tasks"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Schedule",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
        ],
      ),
    );
  }
}
