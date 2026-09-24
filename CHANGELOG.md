## 1.1.0

### Supports Dart 3

- Requires Dart `^3.0.0`. The previous `>=2.15.0 <3.0.0` constraint only resolved on Dart 3 through its null-safety allowance, and the package's own tests no longer built there.
- Allows `equatable` `>=2.0.5 <4.0.0`. `Chunk` has no subclasses, so equatable 3 dropping `runtimeType` from equality changes nothing; the suite passes on both majors.
- Completes the `Chunker.dataChunker` documentation for a `null` cursor.

No API changes.

## 1.0.1+1

### Updates Example Readme

- Corrects a misnomer in the dart example where `countries` were referenced instead of `states`.

## 1.0.1

### Updates Examples & Readme

- Adds `flutter_infinite_list` example under `examples_ext`.
- Updates `README.md` to include links to example apps.

## 1.0.0

### Initial Release

#### Features

- Provides ability to "chunk" data into smaller pieces using the "Chunker" class.
