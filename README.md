# 📦 Roblox Instance Serializer

**Ultra-fast and size-effective instance serializer for Roblox.**

---

## ⚡ Performance

Here's the results you get when serializing a really big model:
_Benchmark made using a low-end **Intel i5 vPRO** laptop CPU_

| Metric               | Value     |
| -------------------- | --------- |
| Instances serialized | 34,686    |
| Elapsed Time (s)     | 0.166s    |
| Output Size (B)      | 4,912,895 |
| Output Size (KB)     | 4,912.90  |
| Output Size (MB)     | 4.91      |

___

## 📝 Todos

- [ ] Multi-threading support
- [ ] Unserializer function
- [ ] Support for Script/LocalScript instances (via coroutine emulation)
- [ ] Instance diffs (cache similar instances)
- [ ] Attributes support
- [ ] Metadata for versioning
- [ ] Whitelist/Blacklist property names

---

> _Benchmark model used: [**Super Target Store** on Roblox](https://create.roblox.com/store/asset/6700116748/Super-Target-Store);_

> _Contributions and feedback are welcome!_
