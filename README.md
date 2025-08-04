<br/>
<p align="center">
    <img src="https://sttci.b-cdn.net/status.swiftlycs2.net/2105/logo.png" alt="Swiftly Private Message Logo" width="600" height="131">
  <p align="center">
    Swiftly - Base Extension
    <br/>
    <a href="https://github.com/swiftly-solution/base-extension/issues">Report Bug</a>
    <a href="https://swiftlys2.net/discord">Discord Server</a>
  </p>
</p>

<div align="center">

![Downloads](https://img.shields.io/github/downloads/swiftly-solution/base-extension/total) ![Contributors](https://img.shields.io/github/contributors/swiftly-solution/base-extension?color=dark-green) ![Issues](https://img.shields.io/github/issues/swiftly-solution/base-extension) ![License](https://img.shields.io/github/license/swiftly-solution/base-extension)

</div>

---
### Build Requirements
-   [hl2sdk](https://github.com/alliedmodders/hl2sdk/tree/cs2) (Downloads automatically with the git cloning using Recurse Submodules)
-   [metamod-source](https://github.com/alliedmodders/metamod-source) (Downloads automatically with the git cloning using Recurse Submodules)
-   [XMake](https://xmake.io/)

---
### For Developers
- [Documentation](https://swiftlys2.net/ext-docs)
---
### Building Commands

#### Clone Repository

```
git clone --recurse-submodules https://github.com/swiftly-solution/base-extension
```

#### Build

```
./setup.ps1 - Windows
./setup.sh - Linux
```

#### Build using Docker

```
docker run --rm -it -e "FOLDER=ext" -e "GAME=cs2" -v .:/ext ghcr.io/swiftly-solution/swiftly:cross-compiler
```