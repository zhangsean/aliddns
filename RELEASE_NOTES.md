# Release v20260301

## 🚀 新特性

### feat(docker): 添加最小化构建的多阶段Dockerfile

添加支持多架构的最小化Dockerfile，包含构建阶段和两种最终镜像选择：

- **基于Alpine的带shell版本** (~55MB)
  - 包含基本的shell和调试工具
  - 适合需要进入容器调试的场景

- **基于scratch的UPX极限压缩版本** (~13MB)
  - 最小攻击面，无shell
  - UPX压缩，体积减少约78%
  - 推荐用于生产环境

**支持架构**: `amd64`, `arm64`, `armv7`

**构建特性**:
- 静态链接构建 (`CGO_ENABLED=0`)
- UPX极限压缩选项 (`--best --lzma`)
- 非root用户运行 (UID 65534)
- 多阶段构建，最小化镜像层

**使用方法**:
```bash
# 构建UPX压缩版本
docker build -f Dockerfile.minimal --target upx -t aliddns:upx .

# 构建Alpine版本
docker build -f Dockerfile.minimal --target alpine -t aliddns:alpine .

# 多架构构建
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  --target upx -t aliddns:latest .
```

---

### feat(build): 添加UPX压缩支持以减少二进制文件大小

在Makefile中添加UPX压缩选项，并通过环境变量控制是否启用。

**压缩效果**:

| 平台 | 原始大小 | UPX压缩后 | 压缩率 |
|------|---------|----------|--------|
| linux-amd64 | ~47MB | ~10MB | **~79%** |
| linux-arm64 | ~46MB | ~10MB | **~78%** |
| linux-armv7 | ~46MB | ~10MB | **~78%** |

**使用方法**:
```bash
# 本地构建启用UPX压缩
ENABLE_UPX=true make release GOOS=linux GOARCH=amd64

# 或手动压缩已有二进制
upx --best --lzma build/aliddns-linux-amd64/aliddns
```

**CI/CD集成**:
- GitHub Actions自动安装UPX 4.2.4
- Linux和FreeBSD平台默认启用UPX压缩
- macOS平台跳过UPX（UPX对macOS支持有限）

---

### feat(ci): 更新Docker工作流配置

- 修复`release`事件触发器语法错误
- 升级所有actions到最新版本 (v3/v4/v5)
- 添加UPX压缩target支持
- 优化Docker层缓存策略

**自动构建的镜像标签**:

| 标签 | Target | 预估大小 | 说明 |
|------|--------|---------|------|
| `latest`, `v20260301` | upx | ~13MB | UPX压缩版（推荐生产使用） |
| `alpine`, `v20260301-alpine` | alpine | ~55MB | Alpine基础版（带shell） |

---

## 📦 构建产物

本次发布包含以下平台的二进制文件（均已UPX压缩）：

- ✅ linux/386
- ✅ linux/amd64
- ✅ linux/amd64 (GOAMD64=v3)
- ✅ linux/arm (GOARM=5)
- ✅ linux/arm (GOARM=6)
- ✅ linux/arm64
- ✅ linux/mips (softfloat)
- ✅ linux/mipsle (softfloat)
- ✅ freebsd/386
- ✅ freebsd/amd64
- ✅ freebsd/arm (GOARM=6)
- ✅ freebsd/arm64
- ✅ windows/386
- ✅ windows/amd64
- ✅ windows/amd64 (GOAMD64=v3)
- ✅ windows/arm64
- ✅ darwin/amd64
- ✅ darwin/arm64

---

## 🔧 技术细节

**静态链接参数**:
```bash
CGO_ENABLED=0
go build -ldflags "-s -w -extldflags '-static'"
```

**UPX压缩参数**:
```bash
upx --best --lzma aliddns
```

**Docker多架构支持**:
- 使用`docker buildx`进行跨平台构建
- 通过`TARGETARCH`自动选择正确的UPX架构版本

---

**Full Changelog**: https://github.com/zhangsean/aliddns/commits/v20260301
