import 'package:dartz/dartz.dart';

abstract class LyricsRepository {
  Future<Either<String, String?>> getLyrics({required String artist, required String title});
}
