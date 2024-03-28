/// Represents a version of the coast_audio library.
class CaVersion {
  const CaVersion(this.major, this.minor, this.revision);
  final int major;
  final int minor;
  final int revision;

  static const supportedVersion = CaVersion(1, 0, 0);

  bool isSupported(CaVersion current) {
    final isSameMajor = current.major == supportedVersion.major;
    final isLowerMinor = current.minor < supportedVersion.minor;

    if (!isSameMajor || isLowerMinor) {
      return false;
    }

    // If the major and minor versions are the same, the revision must be greater or equal to the supported version.
    if (current.minor == supportedVersion.minor) {
      return current.revision >= supportedVersion.revision;
    }

    return true;
  }

  @override
  String toString() {
    return '$major.$minor.$revision';
  }
}
