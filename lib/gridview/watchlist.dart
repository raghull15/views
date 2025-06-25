import 'package:flutter/material.dart';

class WatchListAndGridScreen extends StatefulWidget {
  @override
  State<WatchListAndGridScreen> createState() => _WatchListAndGridScreenState();
}

class _WatchListAndGridScreenState extends State<WatchListAndGridScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> _brands = [
    'Rolex', 'Sonata', 'Titan', 'Jacob & Co.', 'G-Shock', 'Casio'
  ];
  final List<Color> _colors = [
    Colors.teal, Colors.orange, Colors.blue, Colors.purple, Colors.green
  ];

  List<String> _watchCompanies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _watchCompanies = List.generate(12, (i) => _brands[i % _brands.length]);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading) {
      _loadMore();
    }
  }

  void _loadMore() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _watchCompanies.addAll(List.generate(6, (i) => _brands[(_watchCompanies.length + i) % _brands.length]));
      _isLoading = false;
    });
  }

  void _removeItem(int index) {
    setState(() => _watchCompanies.removeAt(index));
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch List & Grid')),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
        tooltip: "Scroll to Top",
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _watchCompanies.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _watchCompanies.removeAt(oldIndex);
                  _watchCompanies.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _watchCompanies[index];
                return Dismissible(
                  key: ValueKey('$item-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red),
                  onDismissed: (_) => _removeItem(index),
                  child: ListTile(
                    title: Text(item),
                    leading: const Icon(Icons.watch),
                    tileColor: Colors.grey.shade100,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: _watchCompanies.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _watchCompanies.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final color = _colors[index % _colors.length];
                return Card(
                  color: color.withOpacity(0.8),
                  child: Center(
                    child: Text(
                      _watchCompanies[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
