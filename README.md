# About
Ultra fast and size effective instance serializer for Roblox.

Can serialize a game entire map(with 50k instances) under 1 second even on slow CPUs.

# Warning
Currently by the date im writing this it's literally just a serializer(instance -> text), it has no unserializing method(text -> instance)(im working on it ok, soon it's gonna be published)

# Todo
- [x] Cache classes serialization data
- [x] Configurable data packing formats
- [ ] Multi threading
- [ ] Copy paste support
- [ ] Unserializer function
- [ ] Support for Script/LocalScript Instances(through emulation with coroutines)
- [ ] Instance diffs(caching a instance that has many similars)
- [ ] Compression options(zlib, deflate)
- [ ] Attributes support
- [ ] Add output metadata for versioning
- [ ] Whitelist/Blacklist property names
