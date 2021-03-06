// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of vector_math_lists;

/// Abstract base class for vector lists. See [Vector2List], [Vector3List], and
/// [Vector4List] for implementations of this class.
abstract class VectorList<T extends Vector> {
  final int _vectorLength;
  final int _offset;
  final int _stride;
  final int _length;
  final Float32List _buffer;

  /// The count of vectors in this list.
  int get length => _length;
  /// The internal storage buffer of this list.
  Float32List get buffer => _buffer;

  static int _listLength(int offset, int stride, int vectorLength, int length) {
    int width = stride == 0 ? vectorLength : stride;
    return offset + width * length;
  }

  /// Create a new vector list with [length] elements that have a size of
  /// [vectorLength]. Optionally it is possible to specify an [offset] in the
  /// [buffer] and a [stride] between each vector.
  VectorList(int length, int vectorLength, [int offset = 0, int stride = 0])
      : _vectorLength = vectorLength,
        _offset = offset,
        _stride = stride == 0 ? vectorLength : stride,
        _length = length,
        _buffer = new Float32List(
            VectorList._listLength(offset, stride, vectorLength, length)) {
    if (_stride < _vectorLength) {
      throw new ArgumentError('Stride cannot be smaller than the vector size.');
    }
  }

  /// Create a new vector list from a list of vectors that have a size of
  /// [vectorLength]. Optionally it is possible to specify an [offset] in the
  /// [buffer] and a [stride] between each vector.
  VectorList.fromList(List list, int vectorLength,
      [int offset = 0, int stride = 0])
      : _vectorLength = vectorLength,
        _offset = offset,
        _stride = stride == 0 ? vectorLength : stride,
        _length = list.length,
        _buffer = new Float32List(
            offset + list.length * (stride == 0 ? vectorLength : stride)) {
    if (_stride < _vectorLength) {
      throw new ArgumentError('Stride cannot be smaller than the vector size.');
    }
    for (int i = 0; i < _length; i++) {
      store(i, list[i]);
    }
  }

  /// Create a new vector list as a view of [buffer] for vectors that have a
  /// size of [vectorLength]. Optionally it is possible to specify an [offset]
  /// in the [buffer] and a [stride] between each vector.
  VectorList.view(Float32List buffer, int vectorLength,
      [int offset = 0, int stride = 0])
      : _vectorLength = vectorLength,
        _offset = offset,
        _stride = stride == 0 ? vectorLength : stride,
        _length = (buffer.length - Math.max(0, offset - stride)) ~/
            (stride == 0 ? vectorLength : stride),
        _buffer = buffer {
    if (_stride < _vectorLength) {
      throw new ArgumentError('Stride cannot be smaller than the vector size.');
    }
  }

  int _vectorIndexToBufferIndex(int index) {
    return _offset + _stride * index;
  }

  /// Create a new instance of [T].
  T newVector();

  /// Retrieves the vector at [index] and stores it in [vector].
  void load(int index, T vector) {
    int bufferIndex = _vectorIndexToBufferIndex(index);
    for (int i = 0; i < _vectorLength; i++) {
      vector.storage[i] = _buffer[bufferIndex];
      bufferIndex++;
    }
  }

  /// Store [vector] in the list at [index].
  void store(int index, T vector) {
    int bufferIndex = _vectorIndexToBufferIndex(index);
    for (int i = 0; i < _vectorLength; i++) {
      _buffer[bufferIndex] = vector.storage[i];
      bufferIndex++;
    }
  }

  /// Copy a range of [count] vectors beginning at [srcOffset] from [src] into
  /// this list starting at [offset].
  void copy(VectorList src, {int srcOffset: 0, int offset: 0, int count: 0}) {
    if (count == 0) {
      count = Math.min(length - offset, src.length - srcOffset);
    }
    int minVectorLength = Math.min(_vectorLength, src._vectorLength);
    for (int i = 0; i < count; i++) {
      int index = _vectorIndexToBufferIndex(i + offset);
      int srcIndex = src._vectorIndexToBufferIndex(i + srcOffset);
      for (int j = 0; j < minVectorLength; j++) {
        _buffer[index++] = src._buffer[srcIndex++];
      }
    }
  }

  /// Retrieves the vector at [index].
  T operator [](int index) {
    var r = newVector();
    load(index, r);
    return r;
  }

  /// Store [v] in the list at [index].
  void operator []=(int index, T v) {
    store(index, v);
  }
}

/// A list of [Vector2].
class Vector2List extends VectorList<Vector2> {
  /// Create a new vector list with [length] elements. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector2List(int length, [int offset = 0, int stride = 0])
      : super(length, 2, offset, stride);

  /// Create a new vector list from a list of vectors. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector2List.fromList(List<Vector2> list, [int offset = 0, int stride = 0])
      : super.fromList(list, 2, offset, stride);

  /// Create a new vector list as a view of [buffer]. Optionally it is possible
  /// to specify a [offset] in the [buffer] and a [stride] between each vector.
  Vector2List.view(Float32List buffer, [int offset = 0, int stride = 0])
      : super.view(buffer, 2, offset, stride);

  @override
  Vector2 newVector() {
    return new Vector2.zero();
  }
}

/// A list of [Vector3].
class Vector3List extends VectorList<Vector3> {
  /// Create a new vector list with [length] elements. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector3List(int length, [int offset = 0, int stride = 0])
      : super(length, 3, offset, stride);

  /// Create a new vector list from a list of vectors. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector3List.fromList(List<Vector3> list, [int offset = 0, int stride = 0])
      : super.fromList(list, 3, offset, stride);

  /// Create a new vector list as a view of [buffer]. Optionally it is possible
  /// to specify a [offset] in the [buffer] and a [stride] between each vector.
  Vector3List.view(Float32List buffer, [int offset = 0, int stride = 0])
      : super.view(buffer, 3, offset, stride);

  @override
  Vector3 newVector() {
    return new Vector3.zero();
  }
}

/// A list of [Vector4].
class Vector4List extends VectorList<Vector4> {
  /// Create a new vector list with [length] elements. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector4List(int length, [int offset = 0, int stride = 0])
      : super(length, 4, offset, stride);

  /// Create a new vector list from a list of vectors. Optionally it is possible
  /// to specify an [offset] in the [buffer] and a [stride] between each vector.
  Vector4List.fromList(List<Vector4> list, [int offset = 0, int stride = 0])
      : super.fromList(list, 4, offset, stride);

  /// Create a new vector list as a view of [buffer]. Optionally it is possible
  /// to specify a [offset] in the [buffer] and a [stride] between each vector.
  Vector4List.view(Float32List buffer, [int offset = 0, int stride = 0])
      : super.view(buffer, 4, offset, stride);

  @override
  Vector4 newVector() {
    return new Vector4.zero();
  }
}
