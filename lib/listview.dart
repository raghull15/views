import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ListView Food ',
      home: const ListViewDemo(),
    );
  }
}

class ListViewDemo extends StatefulWidget {
  const ListViewDemo({super.key});

  @override
  State<ListViewDemo> createState() => _ListViewDemoState();
}

class _ListViewDemoState extends State<ListViewDemo> {
  final ScrollController _controller = ScrollController();
  final List<String> _sampleFoods = [
    'Pizza', 'Burger', 'Sushi', 'Pasta', 'Taco', 'Salad',
    'Fries', 'Curry', 'Ramen', 'Steak', 'Biryani', 'Dumplings',
    'Falafel', 'Hot Dog', 'Kebab', 'Chow Mein', 'Pancakes',
    'Donut', 'Ice Cream', 'Sandwich',
  ];

  List<String> _foods = [];
  bool _isLoadingMore = false;
  int _selectedView = 0;

  @override
  void initState() {
    super.initState();
    _foods = List.generate(30, (index) => _sampleFoods[index % _sampleFoods.length]);
    _controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent && !_isLoadingMore) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 2));
    final newItems = List.generate(10, (i) => _sampleFoods[(_foods.length + i) % _sampleFoods.length]);
    setState(() {
      _foods.addAll(newItems);
      _isLoadingMore = false;
    });
  }

  void _scrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _builderWithDismissible() {
    return ListView.builder(
      controller: _controller,
      itemCount: _foods.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _foods.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Dismissible(
          key: ValueKey(_foods[index] + index.toString()),
          background: Container(color: Colors.redAccent),
          onDismissed: (_) => setState(() => _foods.removeAt(index)),
          child: Card(
            color: Colors.lightGreen,
            child: ListTile(
              leading: const Icon(Icons.fastfood),
              title: Text(_foods[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _separatedList() {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) => ListTile(
        tileColor: Colors.green.shade100,
        leading: const Icon(Icons.restaurant),
        title: Text('Separated ${_sampleFoods[index % _sampleFoods.length]}'),
      ),
    );
  }

  Widget _customList() {
    return ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          tileColor: Colors.amber.shade100,
          leading: const Icon(Icons.local_dining),
          title: Text('Custom ${_sampleFoods[index % _sampleFoods.length]}'),
        ),
        childCount: 10,
      ),
    );
  }

  Widget _reorderableList() {
    return ReorderableListView(
      children: _foods.take(10).map((item) {
        return ListTile(
          key: ValueKey(item),
          tileColor: Colors.purple.shade100,
          leading: const Icon(Icons.drag_handle),
          title: Text(item),
        );
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _foods.removeAt(oldIndex);
          _foods.insert(newIndex, item);
        });
      },
    );
  }

  List<Widget> get _listViews => [
        _builderWithDismissible(),
        _separatedList(),
        _customList(),
        _reorderableList(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Food Types'),
        actions: [
          if (_selectedView == 0)
            IconButton(onPressed: _scrollToTop, icon: const Icon(Icons.arrow_upward)),
          PopupMenuButton<int>(
            onSelected: (val) => setState(() => _selectedView = val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text('Builder + Dismissible + Infinite')),
              PopupMenuItem(value: 1, child: Text('Separated')),
              PopupMenuItem(value: 2, child: Text('Custom')),
              PopupMenuItem(value: 3, child: Text('Reorderable')),
            ],
          ),
        ],
      ),
      body: _listViews[_selectedView],
    );
  }
}
