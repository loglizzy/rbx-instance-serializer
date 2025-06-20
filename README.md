# 📦 Roblox Instance Serializer

**Ultra-fast, size-efficient serializer for Roblox Instances**

Easily serialize and deserialize Roblox Instances to compact text with exceptional speed and minimal file size. Perfect for saving, sharing, or syncing complex models.

## 📃 Usage

Get the latest release at https://github.com/loglizzy/rbx-instance-serializer/releases

```lua
local InstanceSerializer = require(path.to["instance-serializer"])

-- Serialize an instance
local serialized = InstanceSerializer.Single(workspace.Part)
print(serializer)

-- Deserialize back to an instance
local restored = InstanceSerializer.DeSingle(serialized)
restored.Parent = workspace
```

## ⚡ Performance

Benchmarks on a **model with 34,686 children**:

| Mode                                     | Size (bytes) | Size (KB) | Size (MB) | Time (seconds) |
| ---------------------------------------- | ------------ | --------- | --------- | -------------- |
| Single (selected instance only)          | 35           | 0.035     | 0.000035  | 0.000027       |
| Recursive (instance + children)          | 4,963,573    | 4,963.573 | 4.964     | 0.132          |
| RecursiveWithDiffs (recursive + caching) | 4,324,440    | 4,324.440 | 4.324     | 0.274          |

_Benchmarks run on a low-end **Intel i5 vPRO** laptop CPU._  
_Model: [Super Target Store (Roblox)](https://create.roblox.com/store/asset/6700116748/Super-Target-Store)_

## 🆚 Size

| Tool                                                             | Output Size (bytes) |
| ---------------------------------------------------------------- | ------------------- |
| Instance Recursive                                               | 67,069              |
| Recursive with diffs                                             | 62,473              |
| Serialized using loadable roblox code(loadstring + Instance.new) | 162,831             |

**Rbx Instance Serializer** output is approximately 59%(62% with diffs enabled) smaller than the standard Roblox instance serialization method.

## 🤝 Contributing

Contributions and feedback are welcome!  
Feel free to open issues or submit pull requests.

<sub>_README generated entirely by GitHub Copilot_</sub>
