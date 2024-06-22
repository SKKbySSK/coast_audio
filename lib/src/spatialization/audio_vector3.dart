class AudioVector3 {
  const AudioVector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  @override
  String toString() {
    return 'AudioVector3{x: $x, y: $y, z: $z}';
  }

  AudioVector3 operator +(AudioVector3 other) {
    return AudioVector3(x + other.x, y + other.y, z + other.z);
  }

  AudioVector3 operator -(AudioVector3 other) {
    return AudioVector3(x - other.x, y - other.y, z - other.z);
  }

  AudioVector3 operator *(double scalar) {
    return AudioVector3(x * scalar, y * scalar, z * scalar);
  }

  AudioVector3 operator /(double scalar) {
    return AudioVector3(x / scalar, y / scalar, z / scalar);
  }

  @override
  bool operator ==(Object other) => other is AudioVector3 && runtimeType == other.runtimeType && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => x.hashCode + y.hashCode + z.hashCode;
}
