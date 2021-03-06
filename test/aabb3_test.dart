// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library vector_math.test.aabb3_test;

import 'dart:typed_data';

import 'package:unittest/unittest.dart';

import 'package:vector_math/vector_math.dart';

import 'test_utils.dart';

void testAabb3ByteBufferInstanciation() {
  final buffer =
      new Float32List.fromList([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]).buffer;
  final aabb = new Aabb3.fromBuffer(buffer, 0);
  final aabbOffest =
      new Aabb3.fromBuffer(buffer, Float32List.BYTES_PER_ELEMENT);

  expect(aabb.min.x, equals(1.0));
  expect(aabb.min.y, equals(2.0));
  expect(aabb.min.z, equals(3.0));
  expect(aabb.max.x, equals(4.0));
  expect(aabb.max.y, equals(5.0));
  expect(aabb.max.z, equals(6.0));

  expect(aabbOffest.min.x, equals(2.0));
  expect(aabbOffest.min.y, equals(3.0));
  expect(aabbOffest.min.z, equals(4.0));
  expect(aabbOffest.max.x, equals(5.0));
  expect(aabbOffest.max.y, equals(6.0));
  expect(aabbOffest.max.z, equals(7.0));
}

void testAabb3Center() {
  final aabb = new Aabb3.minMax($v3(1.0, 2.0, 4.0), $v3(8.0, 16.0, 32.0));
  final center = aabb.center;

  expect(center.x, equals(4.5));
  expect(center.y, equals(9.0));
  expect(center.z, equals(18.0));
}

void testAabb3CopyCenterAndHalfExtents() {
  final a1 = new Aabb3.minMax($v3(10.0, 20.0, 30.0), $v3(20.0, 40.0, 60.0));
  final a2 = new Aabb3.minMax($v3(-10.0, -20.0, -30.0), $v3(0.0, 0.0, 0.0));

  final center = new Vector3.zero();
  final halfExtents = new Vector3.zero();

  a1.copyCenterAndHalfExtents(center, halfExtents);

  relativeTest(center, $v3(15.0, 30.0, 45.0));
  relativeTest(halfExtents, $v3(5.0, 10.0, 15.0));

  a2.copyCenterAndHalfExtents(center, halfExtents);

  relativeTest(center, $v3(-5.0, -10.0, -15.0));
  relativeTest(halfExtents, $v3(5.0, 10.0, 15.0));
}

void testAabb3setCenterAndHalfExtents() {
  final a1 =
      new Aabb3.centerAndHalfExtents($v3(0.0, 0.0, 0.0), $v3(10.0, 20.0, 30.0));
  final a2 = new Aabb3.centerAndHalfExtents(
      $v3(-10.0, -20.0, -30.0), $v3(10.0, 20.0, 30.0));

  relativeTest(a1.min, $v3(-10.0, -20.0, -30.0));
  relativeTest(a1.max, $v3(10.0, 20.0, 30.0));

  relativeTest(a2.min, $v3(-20.0, -40.0, -60.0));
  relativeTest(a2.max, $v3(0.0, 0.0, 0.0));
}

void testAabb3setSphere() {
  final s = new Sphere.centerRadius($v3(10.0, 20.0, 30.0), 10.0);
  final a = new Aabb3.fromSphere(s);

  expect(a.intersectsWithVector3(a.center), isTrue);
  expect(a.intersectsWithVector3($v3(20.0, 20.0, 30.0)), isTrue);
}

void testAabb3setRay() {
  final r = new Ray.originDirection(
      $v3(1.0, 2.0, 3.0), $v3(1.0, 5.0, -1.0)..normalize());
  final a = new Aabb3.fromRay(r, 0.0, 10.0);

  expect(a.intersectsWithVector3(r.at(0.0)), isTrue);
  expect(a.intersectsWithVector3(r.at(10.0)), isTrue);
}

void testAabb3setTriangle() {
  final t = new Triangle.points(
      $v3(2.0, 0.0, 0.0), $v3(0.0, 2.0, 0.0), $v3(0.0, 0.0, 2.0));
  final a = new Aabb3.fromTriangle(t);

  expect(a.intersectsWithVector3(t.point0), isTrue);
  expect(a.intersectsWithVector3(t.point1), isTrue);
  expect(a.intersectsWithVector3(t.point2), isTrue);
}

void testAabb3setQuad() {
  final q = new Quad.points($v3(2.0, 0.0, 0.0), $v3(0.0, 2.0, 0.0),
      $v3(0.0, 0.0, 2.0), $v3(0.0, 0.0, -2.0));
  final a = new Aabb3.fromQuad(q);

  expect(a.intersectsWithVector3(q.point0), isTrue);
  expect(a.intersectsWithVector3(q.point1), isTrue);
  expect(a.intersectsWithVector3(q.point2), isTrue);
  expect(a.intersectsWithVector3(q.point3), isTrue);
}

void testAabb3ContainsAabb3() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = new Aabb3.minMax($v3(2.0, 2.0, 2.0), $v3(7.0, 7.0, 7.0));
  final cutting = new Aabb3.minMax($v3(0.0, 0.0, 0.0), $v3(5.0, 5.0, 5.0));
  final outside =
      new Aabb3.minMax($v3(10.0, 10.0, 10.0), $v3(20.0, 20.0, 20.0));
  final grandParent =
      new Aabb3.minMax($v3(0.0, 0.0, 0.0), $v3(10.0, 10.0, 10.0));

  expect(parent.containsAabb3(child), isTrue);
  expect(parent.containsAabb3(parent), isFalse);
  expect(parent.containsAabb3(cutting), isFalse);
  expect(parent.containsAabb3(outside), isFalse);
  expect(parent.containsAabb3(grandParent), isFalse);
}

void testAabb3ContainsSphere() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = new Sphere.centerRadius($v3(3.0, 3.0, 3.0), 1.5);
  final cutting = new Sphere.centerRadius($v3(0.0, 0.0, 0.0), 6.0);
  final outside = new Sphere.centerRadius($v3(-10.0, -10.0, -10.0), 5.0);

  expect(parent.containsSphere(child), isTrue);
  expect(parent.containsSphere(cutting), isFalse);
  expect(parent.containsSphere(outside), isFalse);
}

void testAabb3ContainsVector3() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = $v3(7.0, 7.0, 7.0);
  final cutting = $v3(1.0, 2.0, 1.0);
  final outside = $v3(-10.0, 10.0, 10.0);

  expect(parent.containsVector3(child), isTrue);
  expect(parent.containsVector3(cutting), isFalse);
  expect(parent.containsVector3(outside), isFalse);
}

void testAabb3ContainsTriangle() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = new Triangle.points(
      $v3(2.0, 2.0, 2.0), $v3(3.0, 3.0, 3.0), $v3(4.0, 4.0, 4.0));
  final edge = new Triangle.points(
      $v3(1.0, 1.0, 1.0), $v3(3.0, 3.0, 3.0), $v3(4.0, 4.0, 4.0));
  final cutting = new Triangle.points(
      $v3(2.0, 2.0, 2.0), $v3(3.0, 3.0, 3.0), $v3(14.0, 14.0, 14.0));
  final outside = new Triangle.points(
      $v3(0.0, 0.0, 0.0), $v3(-3.0, -3.0, -3.0), $v3(-4.0, -4.0, -4.0));

  expect(parent.containsTriangle(child), isTrue);
  expect(parent.containsTriangle(edge), isFalse);
  expect(parent.containsTriangle(cutting), isFalse);
  expect(parent.containsTriangle(outside), isFalse);
}

void testAabb3IntersectionAabb3() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = new Aabb3.minMax($v3(2.0, 2.0, 2.0), $v3(7.0, 7.0, 7.0));
  final cutting = new Aabb3.minMax($v3(0.0, 0.0, 0.0), $v3(5.0, 5.0, 5.0));
  final outside =
      new Aabb3.minMax($v3(10.0, 10.0, 10.0), $v3(20.0, 20.0, 10.0));
  final grandParent =
      new Aabb3.minMax($v3(0.0, 0.0, 0.0), $v3(10.0, 10.0, 10.0));

  final siblingOne = new Aabb3.minMax($v3(0.0, 0.0, 0.0), $v3(3.0, 3.0, 3.0));
  final siblingTwo = new Aabb3.minMax($v3(3.0, 0.0, 0.0), $v3(6.0, 3.0, 3.0));
  final siblingThree = new Aabb3.minMax($v3(3.0, 3.0, 3.0), $v3(6.0, 6.0, 6.0));

  expect(parent.intersectsWithAabb3(child), isTrue);
  expect(child.intersectsWithAabb3(parent), isTrue);

  expect(parent.intersectsWithAabb3(parent), isTrue);

  expect(parent.intersectsWithAabb3(cutting), isTrue);
  expect(cutting.intersectsWithAabb3(parent), isTrue);

  expect(parent.intersectsWithAabb3(outside), isFalse);
  expect(outside.intersectsWithAabb3(parent), isFalse);

  expect(parent.intersectsWithAabb3(grandParent), isTrue);
  expect(grandParent.intersectsWithAabb3(parent), isTrue);

  expect(siblingOne.intersectsWithAabb3(siblingTwo), isTrue,
      reason: 'Touching edges are counted as intersection.');
  expect(siblingOne.intersectsWithAabb3(siblingThree), isTrue,
      reason: 'Touching corners are counted as intersection.');
}

void testAabb3IntersectionSphere() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = new Sphere.centerRadius($v3(3.0, 3.0, 3.0), 1.5);
  final cutting = new Sphere.centerRadius($v3(0.0, 0.0, 0.0), 6.0);
  final outside = new Sphere.centerRadius($v3(-10.0, -10.0, -10.0), 5.0);

  expect(parent.intersectsWithSphere(child), isTrue);
  expect(parent.intersectsWithSphere(cutting), isTrue);
  expect(parent.intersectsWithSphere(outside), isFalse);
}

void testAabb3IntersectionVector3() {
  final parent = new Aabb3.minMax($v3(1.0, 1.0, 1.0), $v3(8.0, 8.0, 8.0));
  final child = $v3(7.0, 7.0, 7.0);
  final cutting = $v3(1.0, 2.0, 1.0);
  final outside = $v3(-10.0, 10.0, 10.0);

  expect(parent.intersectsWithVector3(child), isTrue);
  expect(parent.intersectsWithVector3(cutting), isTrue);
  expect(parent.intersectsWithVector3(outside), isFalse);
}

void testAabb3Hull() {
  final a = new Aabb3.minMax($v3(1.0, 1.0, 4.0), $v3(3.0, 4.0, 10.0));
  final b = new Aabb3.minMax($v3(3.0, 2.0, 3.0), $v3(6.0, 2.0, 8.0));

  a.hull(b);

  expect(a.min.x, equals(1.0));
  expect(a.min.y, equals(1.0));
  expect(a.min.z, equals(3.0));
  expect(a.max.x, equals(6.0));
  expect(a.max.y, equals(4.0));
  expect(a.max.z, equals(10.0));
}

void testAabb3HullPoint() {
  final a = new Aabb3.minMax($v3(1.0, 1.0, 4.0), $v3(3.0, 4.0, 10.0));
  final b = $v3(6.0, 2.0, 8.0);

  a.hullPoint(b);

  expect(a.min.x, equals(1.0));
  expect(a.min.y, equals(1.0));
  expect(a.min.z, equals(4.0));
  expect(a.max.x, equals(6.0));
  expect(a.max.y, equals(4.0));
  expect(a.max.z, equals(10.0));

  final Vector3 c = $v3(6.0, 0.0, 2.0);

  a.hullPoint(c);

  expect(a.min.x, equals(1.0));
  expect(a.min.y, equals(0.0));
  expect(a.min.z, equals(2.0));
  expect(a.max.x, equals(6.0));
  expect(a.max.y, equals(4.0));
  expect(a.max.z, equals(10.0));
}

void main() {
  group('Aabb3', () {
    test('ByteBuffer instanciation', testAabb3ByteBufferInstanciation);
    test('Center', testAabb3Center);
    test('copyCenterAndHalfExtents', testAabb3CopyCenterAndHalfExtents);
    test('copyCenterAndHalfExtents', testAabb3setCenterAndHalfExtents);
    test('setSphere', testAabb3setSphere);
    test('setRay', testAabb3setRay);
    test('setTriangle', testAabb3setTriangle);
    test('setQuad', testAabb3setQuad);
    test('Contains Aabb3', testAabb3ContainsAabb3);
    test('Contains Vector3', testAabb3ContainsVector3);
    test('Contains Triangle', testAabb3ContainsTriangle);
    test('Contains Sphere', testAabb3ContainsSphere);
    test('Intersection Aabb3', testAabb3IntersectionAabb3);
    test('Intersection Vector3', testAabb3IntersectionVector3);
    test('Intersection Sphere', testAabb3IntersectionSphere);
    test('Hull', testAabb3Hull);
    test('Hull Point', testAabb3HullPoint);
  });
}
