import 'package:chunk/chunk.dart';

typedef DataChunker<DataType, CursorType> = Future<List<DataType>> Function(
  CursorType? cursor,
  int limit,
);

enum Failure { chunkLimitExceeded }

class Chunker<DataType, CursorType> {
  Chunker({
    required this.cursorSelector,
    required this.dataChunker,
  });

  /// Used to select the value to passed into the [dataChunker] the next time
  /// it's called.
  ///
  /// The cursor will come from the last item in the data returned by the
  /// [dataChunker]. The cursor should be used to skip any records previously
  /// retrieved before getting the next `n` records. `n` being the number of
  /// records specified by the limit provided to the [dataChunker] callback.
  final CursorType Function(DataType) cursorSelector;

  /// Called to retrieve the next `n` number of items from your data source.
  ///
  /// Use the provided [cursor] and [limit] to skip and get the next 'n' number
  /// of items. The cursor will be the identifier selected using the
  /// [cursorSelector] from the last time the [getNext] method was called.
  ///
  /// If the [cursor] is `null`, this is the first time the method is being run
  /// for this data source. Alternatively, it is possible to also receive a null cursor if the
  ///
  /// The [limit] is the maximum amount of items the method expects to receive
  /// when being invoked.
  ///
  /// Warning: To avoid duplicate items, ensure you're getting the
  /// [limit] number of items AFTER the [cursor].
  final DataChunker<DataType, CursorType> dataChunker;

  /// Retrieve the next chunk of data
  ///
  /// If [chunk.status] is [ChunkStatus.last], the [dataChunker] method will not
  /// be called and the [chunk] will be returned instead.
  ///
  /// Throws [Failure.chunkLimitExceeded] when more data is returned than
  /// expected.
  ///
  /// See details on the [cursorSelector], and [dataChunker] provided to this
  /// class as they are used in this method to create the chunk returned.
  Future<Chunk<DataType, CursorType>> getNext(
    Chunk<DataType, CursorType>? chunk,
  ) async {
    // Allows for this function to be called as the initial function if the user
    // wants to use the default values of a Chunk
    final nextChunk = chunk ?? Chunk();
    final limit = nextChunk.limit;

    // Do not continue to hit the data source when no more data is available
    if (nextChunk.status == ChunkStatus.last) return nextChunk;

    final data = await dataChunker(nextChunk.cursor, limit);
    final dataLength = data.length;

    if (dataLength > limit) throw Failure.chunkLimitExceeded;

    final cursor = dataLength == 0 ? null : cursorSelector(data.last);

    // There's a potential for the data's length to equal the limit and still be
    // the last of the data from the data source. If this happens it will just
    // mean we provide the wrong status to the user, resulting in one additional
    // request to the data source; resulting in no data being returned and the
    // correct status being provided.
    final isLast = dataLength < limit;

    return isLast
        ? Chunk.last(
            limit: limit,
            data: data,
            cursor: cursor,
          )
        : Chunk.next(
            limit: limit,
            data: data,
            cursor: cursor,
          );
  }
}
