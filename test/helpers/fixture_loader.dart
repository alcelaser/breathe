import 'dart:convert';
import 'dart:io';

String loadFixture(String name) {
  return File('test/fixtures/$name').readAsStringSync();
}

dynamic loadJsonFixture(String name) {
  return jsonDecode(loadFixture(name));
}
