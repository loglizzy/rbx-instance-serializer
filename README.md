# 📦 Roblox Instance Serializer

**Ultra-fast, size-efficient serializer for Roblox Instances.**

Serialize game instances to text with exceptional speed and minimal size.

## ⚡ Performance

Benchmarks performed on a **model with 34,686 children**:

| Mode                                    | Size (bytes) | Size (KB) | Size (MB) | Time (seconds) |
| --------------------------------------- | ------------ | --------- | --------- | -------------- |
| Single (selected instance only)         | 35           | 0.035     | 0.000035  | 0.000027       |
| Recursive (instance + children)         | 4,963,573    | 4,963.573 | 4.964     | 0.132          |
| RecursiveWithDiffs (recusive + caching) | 4,324,440    | 4,324.440 | 4.324     | 0.274          |

_Benchmarks run on a low-end **Intel i5 vPRO** laptop CPU._

_Model: [Super Target Store (Roblox)](https://create.roblox.com/store/asset/6700116748/Super-Target-Store)_

## 🚀 Features

- Blazing fast serialization & deserialization
- Highly compact output
- Easy usage

## 📝 Roadmap

- [ ] Multi-threading support
- [x] Deserialization (unserializer) function
- [ ] Script/LocalScript support (via coroutine emulation)
- [x] Instance diffs (cache similar instances)
- [ ] Attributes support
- [ ] Metadata for versioning
- [ ] Property whitelist/blacklist

## 🤝 Contributing

Contributions and feedback are welcome!  
Feel free to open issues or submit pull requests.