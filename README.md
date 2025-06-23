<!-- To copilot: never use "---" when writing in this file, it's ugly. -->

# 📦 Roblox Instance Serializer

**Ultra-fast, size-efficient serializer for Roblox Instances**

Easily serialize and deserialize Roblox Instances with insane speed and minimal size.

## ✨ Usage

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

| Mode                                     | Size (bytes) | Time (seconds) |
| ---------------------------------------- | ------------ | -------------- |
| Single (model instance only, no childs)  | 35           | 0.000027       |
| Recursive (instance + children)          | 4,963,573    | 0.132          |
| RecursiveWithDiffs (recursive + caching) | 4,324,440    | 0.274          |

_Benchmarks run on a low-end **Intel i5 vPRO** laptop CPU._  
_Model: [Super Target Store (Roblox)](https://create.roblox.com/store/asset/6700116748/Super-Target-Store)_

## 🤝 Contributing

Contributions and feedback are welcome!  
Feel free to open issues or submit pull requests.

**Quick start:**
1. Clone repository

```bash
git clone https://github.com/loglizzy/rbx-instance-serializer
```

2. Start Rojo at VS Code(_repo has a rojo project configured, you just need to start it_)
3. Connect Rojo plugin in Roblox Studio
4. Playtest by pressing `F8` at studio
5. Make any improvement or addition you find usefull and commit it

---

<sub>_README generated entirely by GitHub Copilot_</sub>
