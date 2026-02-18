#!/bin/bash
# ====================================================
#  🚀 VPS 智能空间管家 V2.1
#  Powered by Gemini 3.0 make! 
# ====================================================

# 定义丰富颜色库
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
PURPLE="\033[35m"
RESET="\033[0m"

LOG_FILE="/var/log/vps_clean.log"

# 强制 Root 权限运行检测
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ 错误: 此脚本需要 root 权限才能执行清理操作。请使用 sudo 或 root 账号运行。${RESET}"
  exit 1
fi

# 深度清理核心逻辑（带静默模式判断）
do_deep_clean() {
    local mode=$1
    [ "$mode" != "auto" ] && echo -e "\n${CYAN}⏳ 正在执行深度清理，请稍候...${RESET}"
    
    SPACE_BEFORE=$(df -h / | awk 'NR==2 {print $4}')
    
    # 1. 清理日志与 APT 缓存
    journalctl --vacuum-time=1d >/dev/null 2>&1
    journalctl --vacuum-size=50M >/dev/null 2>&1
    apt-get autoremove -y >/dev/null 2>&1
    apt-get clean >/dev/null 2>&1
    find /tmp -type f -mtime +2 -delete 2>/dev/null
    
    # 2. 释放系统内存缓存 (VPS 提速神器)
    sync; echo 3 > /proc/sys/vm/drop_caches
    
    # 3. 重启服务释放幽灵空间
    systemctl restart qbittorrent-nox 2>/dev/null
    systemctl restart rclone-webdav 2>/dev/null
    sync
    
    SPACE_AFTER=$(df -h / | awk 'NR==2 {print $4}')
    
    # 4. 写入战报
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 触发: $mode | 清理前可用: $SPACE_BEFORE -> 清理后可用: $SPACE_AFTER" >> $LOG_FILE
    
    if [ "$mode" != "auto" ]; then
        echo -e "${GREEN}✅ 深度清理与内存释放完成！${RESET}"
        echo -e "💿 可用空间变化: ${YELLOW}$SPACE_BEFORE${RESET} ➡️  ${GREEN}$SPACE_AFTER${RESET}"
        read -p "按回车键返回主菜单..."
    fi
}

# ==========================================
# 后台静默执行入口 (给 crontab 定时任务用的)
# ==========================================
if [ "$1" == "auto" ]; then
    do_deep_clean "自动定时"
    exit 0
fi

# ==========================================
# 前台可视化交互菜单
# ==========================================
while true; do
    clear
    echo -e "${CYAN}██████████████████████████████████████████${RESET}"
    echo -e "${PURPLE}       🚀 VPS 智能空间管家 V2.1 ${RESET}"
    echo -e "${YELLOW}           Gemini 3.0 make! ${RESET}"
    echo -e "${CYAN}██████████████████████████████████████████${RESET}"
    echo -e " ${GREEN}1)${RESET} 🧹 基础清理 (清缓存/日志，不中断下载)"
    echo -e " ${GREEN}2)${RESET} 💥 深度清理 (强制释放空间与内存，重启引擎)"
    echo -e " ${GREEN}3)${RESET} 📊 查看当前硬盘与内存状态"
    echo -e " ${GREEN}4)${RESET} ⏰ 开启 [每日凌晨4点自动深度清理]"
    echo -e " ${GREEN}5)${RESET} 📜 查看历史清理记录"
    echo -e " ${RED}0)${RESET} ❌ 退出面板"
    echo -e "${CYAN}==========================================${RESET}"
    read -p "🎯 请输入选项并回车 [0-5]: " choice

    case $choice in
        1)
            echo -e "\n${YELLOW}⏳ 正在清理基础垃圾...${RESET}"
            apt-get clean >/dev/null 2>&1
            journalctl --vacuum-size=50M >/dev/null 2>&1
            echo -e "${GREEN}✅ 基础清理完成！${RESET}"
            read -p "按回车键返回主菜单..."
            ;;
        2)
            do_deep_clean "手动执行"
            ;;
        3)
            echo -e "\n${CYAN}【根目录 (/) 使用情况】${RESET}"
            df -h /
            echo -e "\n${CYAN}【当前内存使用情况】${RESET}"
            free -m
            echo ""
            read -p "按回车键返回主菜单..."
            ;;
        4)
            echo -e "\n${YELLOW}正在配置系统定时任务...${RESET}"
            # 安全更新 crontab
            crontab -l 2>/dev/null | grep -v "/root/vps_manager.sh auto" | crontab -
            (crontab -l 2>/dev/null; echo "0 4 * * * /bin/bash /root/vps_manager.sh auto") | crontab -
            echo -e "${GREEN}✅ 搞定！系统每天凌晨 04:00 会在后台偷偷帮你做一次深度清理！${RESET}"
            read -p "按回车键返回主菜单..."
            ;;
        5)
            echo -e "\n${CYAN}📜 最近的清理战报：${RESET}"
            if [ -f "$LOG_FILE" ]; then
                tail -n 10 $LOG_FILE
            else
                echo -e "${RED}暂无记录，你还没进行过深度清理哦。${RESET}"
            fi
            echo ""
            read -p "按回车键返回主菜单..."
            ;;
        0)
            echo -e "${GREEN}👋 拜拜！有空间焦虑随时叫我。${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}⚠️ 别乱敲，请输入 0 到 5 之间的数字！${RESET}"
            sleep 1.5
            ;;
    esac
done
EOF

# 赋予可执行权限
chmod +x /root/vps_manager.sh
echo -e "\e[32m✅ 脚本已更新并赋予执行权限！输入 /root/vps_manager.sh 即可运行。\e[0m"
