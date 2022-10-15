import 'package:chunk/chunk.dart';
import 'package:equatable/equatable.dart';

enum ChunkStatus {
  /// More data is available
  nextAvailable,

  /// No more data is available
  last,
}

/// A subset of data retreived from a data source.
///
/// A [Chunk] is used to store what the last "chunk" of retrieved data was.
///
/// Constructors have been created to facilitate proper state creation. The
/// default constructor should be used initially, then [Chunk.next] should be
/// used when more data is available in the data source, and [Chunk.last] when
/// no more data is available.
///
/// See [Chunker] for a usable implementation using the [Chunk]s.
class Chunk<T, CursorType> extends Equatable {
  static const int defaultLimit = 50;

  /// An identifier use to find the last value retrieved from the data source.
  final CursorType? cursor;

  /// The items retrieved from the data source.
  ///
  /// [data]'s length can be 0 to [limit] inclusive
  final List<T> data;

  /// The maximum amount of items to retrieve with each [Chunk]
  final int limit;

  /// Whether or not more chunks are able to be retrieved from the data source.
  final ChunkStatus status;

  /// Used to initiate data retrieval.
  ///
  /// A limit can be provided, or the [Chunk.defaultLimit] is used.
  ///
  /// /// See [Chunk.next] and [Chunk.last] to signal other statuses.
  const Chunk({
    this.limit = defaultLimit,
  })  : data = const [],
        cursor = null,
        status = ChunkStatus.nextAvailable;

  /// Used to signal more data is available from the data source.
  ///
  /// Normally used for all chunks between the initial and ending chunk.
  ///
  /// See [Chunk] for initial creation and [Chunk.last] to signal the end of the
  /// data source.
  const Chunk.next({
    required this.data,
    required this.cursor,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.nextAvailable;

  /// Used to signal no more data is available from the data source.
  ///
  /// Normally used when the last chunk of data is retrieved from the data
  /// source.
  ///
  /// See [Chunk] for initial creation and [Chunk.next] to signal more data is
  /// available from the data source.
  const Chunk.last({
    required this.data,
    required this.cursor,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.last;

  @override
  List<Object?> get props => [cursor, data, limit, status];

  @override
  String toString() {
    return "Chunk(data:$data, cursor: $cursor, limit: $limit, status: ${status.name})";
  }
}
