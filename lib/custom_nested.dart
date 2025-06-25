import 'package:flutter/material.dart';

void main() {
  runApp(SportsApp());
}

class SportsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Teams',
      home: SportsHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SportsHomePage extends StatefulWidget {
  @override
  _SportsHomePageState createState() => _SportsHomePageState();
}

class _SportsHomePageState extends State<SportsHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> favoriteTeams = ['RCB', 'CSK', 'PBKS', 'SRH', 'DD'];
  List<String> sportsCategories =
      List.generate(10, (index) => 'Sport Category ${index + 1}');
  bool isLoadingMore = false;
  bool showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreSports();
    }

    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != showScrollToTopButton) {
      setState(() => showScrollToTopButton = shouldShow);
    }
  }

  void _loadMoreSports() {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        sportsCategories.addAll(List.generate(
          5,
          (index) => 'Sport Category ${sportsCategories.length + index + 1}',
        ));
        isLoadingMore = false;
      });
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = favoriteTeams.removeAt(oldIndex);
    favoriteTeams.insert(newIndex, item);
    setState(() {});
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 150,
                backgroundColor: Colors.green.shade700,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Sports Teams Manager'),
                  background: Image.asset(
                    'assets/sports.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your Favorite Teams (Reorder or Swipe to Remove)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: favoriteTeams.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final team = favoriteTeams[index];
                    return Dismissible(
                      key: ValueKey(team),
                      background: Container(
                        color: const Color.fromARGB(255, 233, 229, 24),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) {
                        setState(() => favoriteTeams.removeAt(index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$team dismissed')),
                        );
                      },
                      child: ListTile(
                        key: ValueKey('reorder_$team'),
                        title: Text(team),
                        leading: Icon(Icons.sports_soccer, color: Colors.blueAccent),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Explore your favorite sports and manage your teams.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black87),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == sportsCategories.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Card(
                      color: Colors.orange.shade100,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(sportsCategories[index]),
                        leading: Icon(Icons.sports),
                      ),
                    );
                  },
                  childCount: isLoadingMore
                      ? sportsCategories.length + 1
                      : sportsCategories.length,
                ),
              ),
            ],
          ),
          if (showScrollToTopButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.blueAccent,
                onPressed: _scrollToTop,
                child: Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ),
    );
  }
}
