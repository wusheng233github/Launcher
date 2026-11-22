#!/usr/bin/env bash
# 从源码重新编译 launcher.jar（跨平台：Linux / macOS / Windows Git Bash）
set -eu
cd -- "$(dirname -- "$0")" || exit 1
ROOT="$(pwd -P)"

JAVAC="${JAVAC:-javac}"
JAR="${JAR:-jar}"
if ! command -v "$JAVAC" >/dev/null 2>&1; then
    echo "错误：找不到 javac，请安装 JDK（如 sudo apt install openjdk-21-jdk）或设置 JAVAC 环境变量。" >&2
    exit 1
fi

OUT="$ROOT/out"
rm -rf "$OUT"
mkdir -p "$OUT"

# 固定编译到 Java 17 字节码：Java 17/20/21/25 都能运行，兼容性最好
# （源码用了 instanceof 模式匹配，无法降到 11；老 Java 8 跑不了本启动器）
RELEASE="${RELEASE:-17}"
echo "正在编译源码（--release $RELEASE）…"
"$JAVAC" --release "$RELEASE" -encoding UTF-8 -d "$OUT" $(find "$ROOT/src" -name '*.java')

echo "正在打包 launcher.jar…"
rm -f "$ROOT/launcher.jar"
"$JAR" cfe "$ROOT/launcher.jar" com.mclauncher.main.Main -C "$OUT" .

echo "完成：$ROOT/launcher.jar"
