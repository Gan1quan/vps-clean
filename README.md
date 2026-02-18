# 🚀 VPS 智能空间管家 (VPS Manager)

一款轻量、强大且极具视觉冲击力的 VPS 维护工具。不仅能帮你深度清理磁盘碎片，还能一键释放内存，彻底解决 VPS 的“空间焦虑”。

> **Powered by Gemini 3.0 make!**

---

## ✨ 核心功能

- **基础清理**：快速清除 APT 缓存与过时系统日志，不影响正在运行的下载任务。
- **深度清理**：彻底删除 `/tmp` 缓存，重置系统日志，并重启下载引擎（qbittorrent/rclone）以释放“幽灵空间”。
- **内存优化**：集成系统缓存深度回收机制，显著提升小内存 VPS 的响应速度。
- **定时任务**：支持一键开启每日凌晨 04:00 的自动静默清理，让你的 VPS 每天都像新的一样。
- **直观战报**：内置清理记录追踪，空间变化一目了然。

---

## 🛠️ 一键安装与运行

只需在你的 VPS 终端执行以下命令：
```bash

wget -O vps_manager.sh https://raw.githubusercontent.com/Gan1quan/vps-clean/main/vps_manager.sh && chmod +x vps_manager.sh && ./vps_manager.sh

