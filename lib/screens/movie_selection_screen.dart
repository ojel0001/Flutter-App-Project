import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_swipable/flutter_swipable.dart'; 
import 'package:final_project/utils/movie_service.dart';
import 'package:final_project/utils/ movie.dart' as utils;

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  List<utils.Movie> _movies = [];
  int _currentIndex = 0; 
  List<utils.Movie> _likedMovies = []; 
  final StreamController<double> _swipeController = StreamController<double>();

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  void dispose() {
    _swipeController.close();
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
    final movie = _movies[_currentIndex];

    if (isLiked) {
      _likedMovies.add(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Liked: ${movie.title}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disliked: ${movie.title}')),
      );
    }

    
    setState(() {
      _currentIndex++;
    });
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
                  child: Swipable(
                    swipe: _swipeController.stream, 
                    onSwipeLeft: (finalPosition) => _handleSwipe(false),
                    onSwipeRight: (finalPosition) => _handleSwipe(true),
                    child: _buildMovieCard(_movies[_currentIndex]),
                  ),
                ),
      floatingActionButton: _movies.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    _swipeController.add(math.pi); 
                  },
                  child: const Icon(Icons.thumb_down),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    _swipeController.add(0); 
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
