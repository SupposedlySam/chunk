import 'package:chunk/chunk.dart';
import 'package:example/data.dart';

void main(List<String> arguments) async {
  final chunker = Chunker<String, String>(
    cursorSelector: (v) => v,
    dataChunker: (cursor, limit) async {
      final isFirstRun = cursor == null;

      final data = isFirstRun
          ? countries.take(limit)
          : countries
              .skipWhile((value) => value != cursor)
              .skip(1) // Start afer the previous cursor
              .take(limit);

      return data.toList();
    },
  );

  /// Async loop over the data until we're at the end.
  startPaginationLoop(Chunk<String, String> chunk) async {
    final nextChunk = await chunker.getNext(chunk);

    print(nextChunk);

    if (nextChunk.status == ChunkStatus.nextAvailable) {
      await startPaginationLoop(nextChunk);
    }
  }

  print("### Non Divisible By Limit Loop");
  await startPaginationLoop(Chunk(limit: 8));

  print("### Divisible By Limit Loop (extra chunk required to know we're done");
  await startPaginationLoop(Chunk(limit: 10));
}
