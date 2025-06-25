import 'package:flutter/material.dart';
import 'watchlist.dart';

void main() => runApp(WatchGridViewApp());

class WatchGridViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watch Grid Types',
      theme: ThemeData(useMaterial3: true),
      home: WatchTabsScreen(),
    );
  }
}

class WatchTabsScreen extends StatelessWidget {
  final List<String> brands = [
    'Rolex',
    'Sonata',
    'Titan',
    'Jacob & Co.',
    'G-Shock',
    'Casio',
  ];

  final List<Color> colors = [
    Colors.teal,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Watch Grid Types'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Builder'),
              Tab(text: 'Count'),
              Tab(text: 'Extent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BuilderGridView(brands: brands, colors: colors),
            CountGridView(brands: brands, colors: colors),
            ExtentGridView(brands: brands, colors: colors),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WatchListAndGridScreen()),
            );
          },
          label: Text('Advanced View'),
          icon: Icon(Icons.open_in_new),
        ),
      ),
    );
  }
}

class BuilderGridView extends StatefulWidget {
  final List<String> brands;
  final List<Color> colors;

  const BuilderGridView({required this.brands, required this.colors});

  @override
  State<BuilderGridView> createState() => _BuilderGridViewState();
}

class _BuilderGridViewState extends State<BuilderGridView> {
  final ScrollController _scrollController = ScrollController();
  late List<String> _watchCompanies;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _watchCompanies = List.generate(12, (i) => widget.brands[i % widget.brands.length]);
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
      _watchCompanies.addAll(List.generate(6, (i) => widget.brands[(_watchCompanies.length + i) % widget.brands.length]));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _watchCompanies.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _watchCompanies.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final color = widget.colors[index % widget.colors.length];
        return WatchCard(name: _watchCompanies[index], color: color);
      },
    );
  }
}

class CountGridView extends StatelessWidget {
  final List<String> brands;
  final List<Color> colors;

  const CountGridView({required this.brands, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(12),
      children: List.generate(18, (index) {
        final name = brands[index % brands.length];
        final color = colors[index % colors.length];
        return WatchCard(name: name, color: color);
      }),
    );
  }
}

class ExtentGridView extends StatelessWidget {
  final List<String> brands;
  final List<Color> colors;

  const ExtentGridView({required this.brands, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 150,
      padding: const EdgeInsets.all(12),
      children: List.generate(18, (index) {
        final name = brands[index % brands.length];
        final color = colors[index % colors.length];
        return WatchCard(name: name, color: color);
      }),
    );
  }
}

class WatchCard extends StatelessWidget {
  final String name;
  final Color color;

  const WatchCard({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.8),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
