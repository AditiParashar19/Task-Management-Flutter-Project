import 'package:flutter/material.dart';

// --- TASKS PAGE ---
class TasksPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final VoidCallback onUpdate;
  const TasksPage({super.key, required this.tasks, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTask(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: Checkbox(
            value: tasks[i]['isDone'],
            onChanged: (v) {
              tasks[i]['isDone'] = v;
              onUpdate();
            },
          ),
          title: Text(
            tasks[i]['title'],
            style: TextStyle(
              decoration: tasks[i]['isDone']
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Text(
            "${tasks[i]['date'].day}/${tasks[i]['date'].month} at ${tasks[i]['time']}",
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              tasks.removeAt(i);
              onUpdate();
            },
          ),
        ),
      ),
    );
  }

  void _showAddTask(BuildContext context) async {
    final ctrl = TextEditingController();
    DateTime d = DateTime.now();
    TimeOfDay t = TimeOfDay.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: "New Task"),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async => d =
                      (await showDatePicker(
                        context: ctx,
                        firstDate: d,
                        lastDate: DateTime(2030),
                      )) ??
                      d,
                  child: const Text("Set Date"),
                ),
                TextButton(
                  onPressed: () async => t =
                      (await showTimePicker(context: ctx, initialTime: t)) ?? t,
                  child: const Text("Set Time"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                tasks.add({
                  'title': ctrl.text,
                  'date': d,
                  'time': t.format(ctx),
                  'isDone': false,
                });
                onUpdate();
                Navigator.pop(ctx);
              },
              child: const Text("Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCHEDULE PAGE ---
class SchedulePage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const SchedulePage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = tasks
        .where((t) => t['date'].day == now.day && t['date'].month == now.month)
        .toList();
    final upcoming = tasks
        .where((t) => t['date'].isAfter(DateTime(now.year, now.month, now.day)))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(text: "Today"),
            Tab(text: "Upcoming"),
          ],
          labelColor: Colors.teal,
        ),
        body: TabBarView(children: [_buildList(today), _buildList(upcoming)]),
      ),
    );
  }

  Widget _buildList(List list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, i) => Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          list[i]['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Date: ${list[i]['date'].day}/${list[i]['date'].month} | Time: ${list[i]['time']}",
        ),
      ),
    ),
  );
}

// --- NOTES PAGE ---
class NotesPage extends StatelessWidget {
  final List<Map<String, String>> notes;
  final VoidCallback onUpdate;
  const NotesPage({super.key, required this.notes, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.note_add),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: notes.length,
        itemBuilder: (ctx, i) => Card(
          color: Colors.yellow.shade200,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notes[i]['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text(
                      notes[i]['content']!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _openEditor(context, index: i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, {int? index}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          initialTitle: index != null ? notes[index]['title']! : "",
          initialContent: index != null ? notes[index]['content']! : "",
          onSave: (t, c) {
            if (index == null) {
              notes.add({'title': t, 'content': c});
            } else {
              notes[index] = {'title': t, 'content': c};
            }
            onUpdate();
          },
        ),
      ),
    );
  }
}

class NoteEditorScreen extends StatefulWidget {
  final String initialTitle;
  final String initialContent;
  final Function(String, String) onSave;

  const NoteEditorScreen({
    super.key,
    required this.initialTitle,
    required this.initialContent,
    required this.onSave,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _tCtrl;
  late TextEditingController _cCtrl;

  @override
  void initState() {
    super.initState();
    _tCtrl = TextEditingController(text: widget.initialTitle);
    _cCtrl = TextEditingController(text: widget.initialContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        title: const Text("Edit Note"),
        backgroundColor: Colors.yellow.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tCtrl,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _cCtrl,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Start writing...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onSave(_tCtrl.text, _cCtrl.text);
          Navigator.pop(context);
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
