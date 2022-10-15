import 'package:chunk/chunk.dart';
import 'package:test/test.dart';

void main() {
  group('should have expected state for', () {
    const expectedData = ["expectedData"];
    const expectedCursor = "expectedCursor";
    const customLimit = 50;

    group('default constructor', () {
      test('with required arguments', () {
        const chunk = Chunk();

        expect(chunk.cursor, isNull);
        expect(chunk.data, const []);
        expect(chunk.limit, Chunk.defaultLimit);
        expect(chunk.status, ChunkStatus.nextAvailable);
      });

      test('with custom limit', () {
        const chunk = Chunk();

        expect(chunk.cursor, isNull);
        expect(chunk.data, const []);
        expect(chunk.limit, customLimit);
        expect(chunk.status, ChunkStatus.nextAvailable);
      });
    });

    group('next constructor', () {
      test('with required arguments', () {
        const chunk = Chunk.next(data: expectedData, cursor: expectedCursor);

        expect(chunk.cursor, expectedCursor);
        expect(chunk.data, expectedData);
        expect(chunk.limit, Chunk.defaultLimit);
        expect(chunk.status, ChunkStatus.nextAvailable);
      });

      test('with custom limit', () {
        const chunk = Chunk.next(
          data: expectedData,
          cursor: expectedCursor,
          limit: customLimit,
        );

        expect(chunk.cursor, expectedCursor);
        expect(chunk.data, expectedData);
        expect(chunk.limit, customLimit);
        expect(chunk.status, ChunkStatus.nextAvailable);
      });
    });

    group('last constructor', () {
      test('with required arguments', () {
        const chunk = Chunk.last(data: expectedData, cursor: expectedCursor);

        expect(chunk.cursor, expectedCursor);
        expect(chunk.data, expectedData);
        expect(chunk.limit, Chunk.defaultLimit);
        expect(chunk.status, ChunkStatus.last);
      });

      test('with custom limit', () {
        const chunk = Chunk.last(
          data: expectedData,
          cursor: expectedCursor,
          limit: customLimit,
        );

        expect(chunk.cursor, expectedCursor);
        expect(chunk.data, expectedData);
        expect(chunk.limit, customLimit);
        expect(chunk.status, ChunkStatus.last);
      });
    });
  });
}
