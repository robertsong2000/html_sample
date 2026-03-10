#!/bin/bash
# 每小时自动生成创意HTML页面的脚本

set -e

WORKSPACE="/home/ubuntu/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE/html_sample"
LOG_FILE="$WORKSPACE/memory/page-generator.log"

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "开始生成新页面..."

# 切换到工作目录
cd "$WORKSPACE"

# 使用 OpenClaw 生成页面
# 通过 sessions_spawn 创建一个子任务
log "调用 OpenClaw 生成页面..."

# 由于 cron 环境限制，我们使用一个简化的方案
# 创建一个标记文件，让主会话的 heartbeat 来处理
MARKER_FILE="$WORKSPACE/memory/pending-page-gen.json"

# 生成随机主题
THEMES=(
    "粒子动画" "星空效果" "波浪动画" "几何图形" 
    "音乐可视化" "时钟设计" "日历特效" "文字动画"
    "分形艺术" "流体模拟" "物理模拟" "游戏demo"
    "数据可视化" "3D旋转" "光影效果" "彩虹渐变"
)

RANDOM_INDEX=$((RANDOM % ${#THEMES[@]}))
THEME="${THEMES[$RANDOM_INDEX]}"

# 写入任务标记
cat > "$MARKER_FILE" << EOF
{
    "type": "generate_page",
    "theme": "$THEME",
    "timestamp": "$(date -Iseconds)",
    "status": "pending"
}
EOF

log "已创建页面生成任务，主题: $THEME"

# 实际的页面生成逻辑会在主会话中执行
# 这里我们创建一个简单的占位页面作为示例

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="auto-gen-${TIMESTAMP}.html"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# 生成一个简单的创意页面
cat > "$FILEPATH" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>自动生成 - THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', sans-serif;
            overflow: hidden;
        }
        .container {
            text-align: center;
            color: white;
            animation: fadeIn 1s ease-out;
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .time {
            margin-top: 30px;
            font-size: 1.5em;
            font-family: monospace;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            overflow: hidden;
            z-index: -1;
        }
        .particle {
            position: absolute;
            width: 10px;
            height: 10px;
            background: rgba(255,255,255,0.3);
            border-radius: 50%;
            animation: float 15s infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(100vh) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-100vh) rotate(720deg); opacity: 0; }
        }
    </style>
</head>
<body>
    <div class="particles" id="particles"></div>
    <div class="container">
        <h1>🎨 THEME_PLACEHOLDER</h1>
        <p>自动生成的创意页面</p>
        <p class="time" id="time"></p>
    </div>
    <script>
        // 生成粒子
        const container = document.getElementById('particles');
        for (let i = 0; i < 30; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.left = Math.random() * 100 + '%';
            particle.style.animationDelay = Math.random() * 15 + 's';
            particle.style.animationDuration = (10 + Math.random() * 10) + 's';
            container.appendChild(particle);
        }
        
        // 显示时间
        function updateTime() {
            document.getElementById('time').textContent = 
                new Date().toLocaleString('zh-CN');
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
HTMLEOF

# 替换主题
sed -i "s/THEME_PLACEHOLDER/$THEME/g" "$FILEPATH"

log "页面已生成: $FILENAME"

# Git 提交
cd "$WORKSPACE"
git add "$FILEPATH"
git commit -m "feat: 自动生成页面 - $THEME ($TIMESTAMP)" || {
    log "没有需要提交的更改"
    exit 0
}

# 推送 (使用存储的凭证)
git push origin master

log "页面已提交并推送到 GitHub"
echo "✅ 完成: $FILENAME (主题: $THEME)"
