Used to paginate any type of data

## Getting started

Simply use the `Chunker` class to select the value you'll be using as your identifier between chunks. Then supply a function to be called each time you need a new chunk from your data source. Once those are provided, a single function is all that's needed to infinitely walk through your data.

## Usage

### Set up

```dart
final chunker = Chunker<String, String>(
  cursorSelector: (v) => v,
  dataChunker: (cursor, limit) {
  final isFirstRun = cursor == null;

  return isFirstRun
    ? dataSouce.take(limit)
    : dataSource
      .skipWhile((value) => value != cursor)
      .skip(1) // Start afer the previous cursor
      .take(limit);
  },
);
```

### Paginate

#### First Chunk

For the first chunk you can provide a new Chunk with a custom limit or provide `null` to accept the default limit of 20

```dart
final Chunk<String, String> nextChunk = await chunker.getNext(
  Chunk(limit: 15),
);
```

#### Remaining Chunks

For all future chunks, all you need to do is pass the previous chunk in.

```dart
await chunker.getNext(nextChunk);
```
