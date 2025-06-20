# 📦 Roblox Instance Serializer

**Ultra-fast and size-effective instance serializer for Roblox.**

Turns game instances into text at a insane speed.

---

## ⚡ Performance

Benchmark made using a **Model with 34,686 childrens**:

| Mode               | Size (b) | Size (kb) | Size (mb) | Time (secs)           |
|--------------------|----------|-----------|-----------|-----------------------|
| Single_(only the selected instance)_             | 35       | 0.035     | 0.000035  | 0.0000268             |
| Recursive_(instance and it's children)_          | 4,963,573| 4,963.573 | 4.963573  | 0.1320675             |
| RecursiveWithDiffs_(instance + children + caching)_ | 4,324,440| 4,324.44  | 4.32444   | 0.2742459             |

_Benchmark made using a low-end **Intel i5 vPRO** laptop CPU_;

_Model used: [**Super Target Store** on Roblox](https://create.roblox.com/store/asset/6700116748/Super-Target-Store);_


---

## 📝 Todos

- [ ] Multi-threading support
- [ ] Unserializer function
- [ ] Support for Script/LocalScript instances (via coroutine emulation)
- [x] Instance diffs (cache similar instances)
- [ ] Attributes support
- [ ] Metadata for versioning
- [ ] Whitelist/Blacklist property names

---

> _Contributions and feedback are welcome!_
