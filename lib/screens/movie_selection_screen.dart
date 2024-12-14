import 'dart:math';
import 'package:flutter/material.dart';
import 'package:final_project/utils/movie_service.dart';
import 'package:final_project/utils/ movie.dart' as utils;

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<utils.Movie> _movies = [];
  int _currentIndex = 0;
  List<utils.Movie> _likedMovies = [];
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMovies() async {
    final movieService = MovieService();
    final movies = await movieService.getPopularMovies();
    setState(() {
      _movies = movies;
    });
  }

  void _handleSwipe(bool isLiked) {
    if (isLiked) {
      _likedMovies.add(_movies[_currentIndex]);
    }

    setState(() {
      _currentIndex++;
    });
  }

  void _onPanStart(DragStartDetails details) {
    _dragOffset = Offset.zero;
    _rotation = 0.0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _rotation = _dragOffset.dx / 100;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    const swipeThreshold = 200.0;
    const swipeVelocityThreshold = 1000.0;

    if (_dragOffset.dx.abs() > swipeThreshold ||
        details.velocity.pixelsPerSecond.dx.abs() > swipeVelocityThreshold) {
      bool isLiked = _dragOffset.dx > 0;
      _animateOut(isLiked);
      _handleSwipe(isLiked);
    } else {
      _resetPosition();
    }
  }

  void _animateOut(bool isLiked) {
    final endOffset = isLiked
        ? Offset(MediaQuery.of(context).size.width * 1.5, 0)
        : Offset(-MediaQuery.of(context).size.width * 1.5, 0);
    _animation = Tween<Offset>(begin: _dragOffset, end: endOffset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward(from: 0.0);
  }

  void _resetPosition() {
    _controller.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildLikedMovies(),
              );
            },
          ),
        ],
      ),
      body: _movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex >= _movies.length
              ? const Center(
                  child: Text(
                    'No more movies to swipe!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Center(
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _animation.value,
                          child: Transform.rotate(
                            angle: _rotation,
                            child: child!,
                          ),
                        );
                      },
                      child: _buildMovieCard(_movies[_currentIndex]),
                    ),
                  ),
                ),
      floatingActionButton: _movies.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    _controller.forward(from: 0.0);
                    _handleSwipe(false);
                  },
                  child: const Icon(Icons.thumb_down),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    _controller.forward(from: 0.0);
                    _handleSwipe(true);
                  },
                  child: const Icon(Icons.thumb_up),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildMovieCard(utils.Movie movie) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            height: 400,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  movie.releaseDate,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedMovies() {
    return ListView.builder(
      itemCount: _likedMovies.length,
      itemBuilder: (context, index) {
        final movie = _likedMovies[index];
        return ListTile(
          title: Text(movie.title),
          subtitle: Text(movie.releaseDate),
          leading: Image.network(
            'https://image.tmdb.org/t/p/w200${movie.posterPath}',
          ),
        );
      },
    );
  }
}
