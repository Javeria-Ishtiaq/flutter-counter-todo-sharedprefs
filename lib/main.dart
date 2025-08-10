import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter & To‑Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.indigo.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: CardTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScaffold(),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentIndex = 0;
  final GlobalKey<_CounterScreenState> _counterKey =
      GlobalKey<_CounterScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Counter' : 'To‑Do',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_currentIndex == 0)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'reset') {
                  _counterKey.currentState?.reset();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(value: 'reset', child: Text('Reset')),
              ],
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CounterScreen(key: _counterKey),
          const TodoScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.exposure), label: 'Counter'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'To‑Do'),
        ],
      ),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  static const String _prefsKey = 'counter_value';
  int _counter = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_prefsKey) ?? 0;
      _loaded = true;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _counter);
  }

  void _increment() {
    setState(() => _counter++);
    _saveCounter();
    _lightHaptic(context);
  }

  void _decrement() {
    setState(() => _counter--);
    _saveCounter();
    _lightHaptic(context);
  }

  void reset() {
    setState(() => _counter = 0);
    _saveCounter();
  }

  static void _lightHaptic(BuildContext context) {
    // Keep code simple: omit platform channels; visual feedback is sufficient.
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.10),
            Theme.of(context).colorScheme.secondary.withOpacity(0.06),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$_counter',
                      key: ValueKey(_counter),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: _decrement,
                    style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(CircleBorder()),
                      padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
                    ),
                    child: const Icon(Icons.remove, size: 28),
                  ),
                  const SizedBox(width: 24),
                  FilledButton(
                    onPressed: _increment,
                    style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(CircleBorder()),
                      padding: WidgetStatePropertyAll(EdgeInsets.all(24)),
                    ),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;

  const TodoItem(
      {required this.id, required this.title, required this.isCompleted});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
      );
}

class _TodoScreenState extends State<TodoScreen> {
  static const String _prefsKey = 'todo_items';
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<TodoItem> _items = <TodoItem>[];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? <String>[];
    setState(() {
      _items = stored
          .map((s) {
            try {
              final map = jsonDecode(s) as Map<String, dynamic>;
              return TodoItem.fromJson(map);
            } catch (_) {
              return null;
            }
          })
          .whereType<TodoItem>()
          .toList();
      _loaded = true;
    });
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList =
        _items.map((e) => jsonEncode(e.toJson())).toList(growable: false);
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      isCompleted: false,
    );
    setState(() => _items = [newItem, ..._items]);
    _textController.clear();
    _saveItems();
  }

  void _toggleItem(String id) {
    setState(() {
      _items = _items
          .map((e) => e.id == id
              ? TodoItem(id: e.id, title: e.title, isCompleted: !e.isCompleted)
              : e)
          .toList();
    });
    _saveItems();
  }

  void _deleteItem(String id) {
    setState(() => _items = _items.where((e) => e.id != id).toList());
    _saveItems();
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _deleteItem(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _inputFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Add a task...',
                          prefixIcon: Icon(Icons.edit_outlined),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _addItem,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _addItem(_textController.text),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _items.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              await _confirmDelete(context, item.id);
                              return false;
                            },
                            child: Card(
                              child: CheckboxListTile(
                                value: item.isCompleted,
                                onChanged: (_) => _toggleItem(item.id),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: TextStyle(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isCompleted
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                  child: Text(item.title),
                                ),
                                secondary: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _confirmDelete(context, item.id),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
