import 'package:chunk/chunk.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

void main() {
  late Chunker<String, String> chunker;
  final List<DataChunkerProps<String?>> dataChunkerCalls = [];
  final alphabet = "abcdefghijklmnopqrstuvwkyz".split('');

  setUp(() {
    chunker = Chunker<String, String>(
      cursorSelector: (v) => v,
      dataChunker: (cursor, limit) {
        dataChunkerCalls.add(DataChunkerProps<String?>(cursor, limit));

        final chunk = cursor == null
            ? alphabet.take(limit)
            : alphabet
                .skipWhile((letter) => letter != cursor)
                .skip(1)
                .take(limit);

        return Future.value(chunk.toList());
      },
    );
  });

  tearDown(() {
    dataChunkerCalls.clear();
  });

  test('should use default Chunk limit for explicit null', () async {
    final chunk = await chunker.getNext(null);

    expect(chunk.limit, Chunk.defaultLimit);
  });

  group('#dataChunker callback', () {
    test('when data is less than limit', () async {
      final limit = 10;

      // Note, expecting 4 function calls, 3 callback calls
      // The `getNext` function returns the provided chunk once the status
      // is ChunkStatus.last
      final firstChunk = await chunker.getNext(Chunk(limit: limit));
      final middleChunk = await chunker.getNext(firstChunk);
      final lastChunk = await chunker.getNext(middleChunk);
      await chunker.getNext(lastChunk);

      expect(dataChunkerCalls, [
        DataChunkerProps<String?>(null, limit),
        DataChunkerProps<String?>(alphabet[limit - 1], limit),
        DataChunkerProps<String?>(alphabet[limit * 2 - 1], limit),
      ]);
    });

    test('when data is equal to limit', () async {
      final limit = 13;

      // Note, expecting 4 function calls, 3 callback calls
      // The `getNext` function returns the provided chunk once the status
      // is ChunkStatus.last
      final firstChunk = await chunker.getNext(Chunk(limit: limit));
      final middleChunk = await chunker.getNext(firstChunk);
      final lastChunk = await chunker.getNext(middleChunk);
      await chunker.getNext(lastChunk);

      expect(dataChunkerCalls, [
        DataChunkerProps<String?>(null, limit),
        DataChunkerProps<String?>(alphabet[limit - 1], limit),
        DataChunkerProps<String?>(alphabet.last, limit),
      ]);
    });
  });

  group('#getNext', () {
    group('on first call', () {
      late Chunk<String, String> firstChunk;
      final limit = 20;

      setUp(() async {
        firstChunk = await chunker.getNext(Chunk(limit: limit));
      });

      test('should set cursor to value at limit index', () async {
        final limitAsIndex = limit - 1;
        expect(firstChunk.cursor, alphabet[limitAsIndex]);
      });

      test('should set data to first chunk', () async {
        final expectedData = alphabet.take(limit).join('');

        expect(firstChunk.data.join(''), expectedData);
      });

      test('should set limit', () async {
        expect(firstChunk.limit, limit);
      });

      test('should set status to nextAvailable', () async {
        expect(firstChunk.status, ChunkStatus.nextAvailable);
      });
    });

    group('on middle call', () {
      late Chunk<String, String> middleChunk;
      final limit = 10;

      setUp(() async {
        final firstChunk = await chunker.getNext(Chunk(limit: limit));
        middleChunk = await chunker.getNext(firstChunk);
      });

      test('should set cursor to value at limit*2 index', () async {
        final limitAsIndex = limit * 2 - 1;
        expect(middleChunk.cursor, alphabet[limitAsIndex]);
      });

      test('should set data to second chunk', () async {
        final expectedData = alphabet.skip(limit).take(limit).join('');

        expect(middleChunk.data.join(''), expectedData);
      });

      test('should set limit', () async {
        expect(middleChunk.limit, limit);
      });

      test('should set status to nextAvailable', () async {
        expect(middleChunk.status, ChunkStatus.nextAvailable);
      });
    });

    group('on last call, where data is less than limit', () {
      late Chunk<String, String> lastChunk;
      final limit = 20;

      setUp(() async {
        final firstChunk = await chunker.getNext(Chunk(limit: limit));
        lastChunk = await chunker.getNext(firstChunk);
      });

      test('should set cursor to last value', () async {
        expect(lastChunk.cursor, alphabet.last);
      });

      test('should set data to last subset of data after skipping limit',
          () async {
        final expectedData = alphabet.skip(limit).take(limit).join('');

        expect(lastChunk.data.join(''), expectedData);
      });

      test('should set limit', () async {
        expect(lastChunk.limit, limit);
      });

      test('should set status to last', () async {
        expect(lastChunk.status, ChunkStatus.last);
      });
    });

    group('on last call, where data is equal to limit', () {
      late Chunk<String, String> lastChunk;
      final limit = 13;

      setUp(() async {
        final firstChunk = await chunker.getNext(Chunk(limit: limit));
        lastChunk = await chunker.getNext(firstChunk);
      });

      test('should set cursor to last value', () async {
        expect(lastChunk.cursor, alphabet.last);
      });

      test('should set data to the last limit of data', () async {
        final expectedData =
            alphabet.reversed.take(limit).toList().reversed.join('');

        expect(lastChunk.data.join(''), expectedData);
      });

      test('should set limit', () async {
        expect(lastChunk.limit, limit);
      });

      test('should set status to nextAvailable', () async {
        expect(lastChunk.status, ChunkStatus.nextAvailable);
      });
    });
  });
}

class DataChunkerProps<CursorType> extends Equatable {
  const DataChunkerProps(this.cursor, this.limit);
  final CursorType cursor;
  final int limit;

  @override
  List<Object?> get props => [cursor, limit];

  @override
  String toString() {
    return '($cursor, $limit)';
  }
}
