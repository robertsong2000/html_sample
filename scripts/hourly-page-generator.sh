#!/bin/bash
# 每小时自动生成创意HTML页面的脚本（防重复版本）

set -e

WORKSPACE="/home/ubuntu/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE"  # HTML 文件直接保存在根目录
LOG_FILE="$WORKSPACE/memory/page-generator.log"
HISTORY_FILE="$WORKSPACE/memory/page-history.json"

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 主题池 - 扩展到更多主题
declare -A THEME_POOL
THEME_POOL=(
    ["粒子动画"]="particles"
    ["星空效果"]="starry"
    ["波浪动画"]="waves"
    ["几何图形"]="geometry"
    ["音乐可视化"]="music"
    ["时钟设计"]="clock"
    ["日历特效"]="calendar"
    ["文字动画"]="text"
    ["分形艺术"]="fractal"
    ["流体模拟"]="fluid"
    ["物理模拟"]="physics"
    ["游戏demo"]="game"
    ["数据可视化"]="data"
    ["3D旋转"]="3d-rotate"
    ["光影效果"]="light"
    ["彩虹渐变"]="rainbow"
    ["烟花效果"]="fireworks"
    ["下雨动画"]="rain"
    ["下雪效果"]="snow"
    ["火焰效果"]="fire"
    ["气泡动画"]="bubbles"
    ["万花筒"]="kaleidoscope"
    ["矩阵雨"]="matrix"
    ["极光效果"]="aurora"
    ["水波纹"]="ripple"
    ["心电图"]="heartbeat"
    ["DNA螺旋"]="dna"
    ["黑洞引力"]="blackhole"
    ["弹球游戏"]="pong"
    ["俄罗斯方块"]="tetris"
    ["贪吃蛇变体"]="snake-variant"
    ["打砖块"]="breakout"
    ["迷宫生成"]="maze"
    ["生命游戏"]="gameoflife"
    ["曼德博集合"]="mandelbrot"
)

# 读取历史记录
read_history() {
    if [ -f "$HISTORY_FILE" ]; then
        cat "$HISTORY_FILE"
    else
        echo '{"recent_themes":[],"all_themes":{}}'
    fi
}

# 获取最近使用的主题（避免重复）
get_recent_themes() {
    local history=$(read_history)
    echo "$history" | python3 -c "
import json, sys
data = json.load(sys.stdin)
recent = data.get('recent_themes', [])
# 返回最近6次使用的主题
for theme in recent[:6]:
    print(theme)
" 2>/dev/null || echo ""
}

# 选择一个未重复的主题
select_theme() {
    local recent=$(get_recent_themes)
    local all_keys=("${!THEME_POOL[@]}")
    local available=()
    
    for key in "${all_keys[@]}"; do
        if ! echo "$recent" | grep -q "^$key$"; then
            available+=("$key")
        fi
    done
    
    # 如果所有主题都用过了，就重置历史
    if [ ${#available[@]} -eq 0 ]; then
        log "所有主题都已使用，重置历史"
        available=("${all_keys[@]}")
    fi
    
    # 随机选择
    local index=$((RANDOM % ${#available[@]}))
    echo "${available[$index]}"
}

# 更新历史记录
update_history() {
    local theme=$1
    python3 << PYEOF
import json
import os

history_file = "$HISTORY_FILE"
theme = "$theme"

# 读取现有历史
if os.path.exists(history_file):
    with open(history_file, 'r') as f:
        data = json.load(f)
else:
    data = {"recent_themes": [], "all_themes": {}}

# 更新最近主题列表（保留最近20个）
if theme in data["recent_themes"]:
    data["recent_themes"].remove(theme)
data["recent_themes"].insert(0, theme)
data["recent_themes"] = data["recent_themes"][:20]

# 更新使用计数
data["all_themes"][theme] = data["all_themes"].get(theme, 0) + 1

# 保存
with open(history_file, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
}

# 生成页面内容（根据主题定制）
generate_page_content() {
    local theme=$1
    local theme_id=${THEME_POOL[$theme]}
    local timestamp=$2
    
    case $theme_id in
        particles)
            generate_particle_page "$theme" "$timestamp"
            ;;
        starry)
            generate_starry_page "$theme" "$timestamp"
            ;;
        matrix)
            generate_matrix_page "$theme" "$timestamp"
            ;;
        fireworks)
            generate_fireworks_page "$theme" "$timestamp"
            ;;
        snow)
            generate_snow_page "$theme" "$timestamp"
            ;;
        clock)
            generate_clock_page "$theme" "$timestamp"
            ;;
        *)
            generate_default_page "$theme" "$timestamp"
            ;;
    esac
}

# 矩阵雨效果
generate_matrix_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #000;
            overflow: hidden;
            font-family: monospace;
        }
        canvas { display: block; }
        .title {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #0f0;
            font-size: 3em;
            text-shadow: 0 0 20px #0f0;
            z-index: 10;
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 0.8; }
            50% { opacity: 1; }
        }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <div class="title">THEME_PLACEHOLDER</div>
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*';
        const fontSize = 14;
        const columns = canvas.width / fontSize;
        const drops = Array(Math.floor(columns)).fill(1);
        
        function draw() {
            ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = '#0f0';
            ctx.font = fontSize + 'px monospace';
            
            for (let i = 0; i < drops.length; i++) {
                const text = chars[Math.floor(Math.random() * chars.length)];
                ctx.fillText(text, i * fontSize, drops[i] * fontSize);
                if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
                    drops[i] = 0;
                }
                drops[i]++;
            }
        }
        setInterval(draw, 33);
    </script>
</body>
</html>
HTMLEOF
}

# 烟花效果
generate_fireworks_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; }
        body { background: #000; overflow: hidden; }
        canvas { display: block; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        class Particle {
            constructor(x, y, color) {
                this.x = x;
                this.y = y;
                this.color = color;
                this.velocity = {
                    x: (Math.random() - 0.5) * 8,
                    y: (Math.random() - 0.5) * 8
                };
                this.alpha = 1;
                this.decay = Math.random() * 0.015 + 0.015;
            }
            draw() {
                ctx.save();
                ctx.globalAlpha = this.alpha;
                ctx.fillStyle = this.color;
                ctx.beginPath();
                ctx.arc(this.x, this.y, 3, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
            update() {
                this.velocity.y += 0.1;
                this.x += this.velocity.x;
                this.y += this.velocity.y;
                this.alpha -= this.decay;
            }
        }
        
        let particles = [];
        
        function createFirework() {
            const x = Math.random() * canvas.width;
            const y = Math.random() * canvas.height * 0.5;
            const colors = ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff'];
            const color = colors[Math.floor(Math.random() * colors.length)];
            
            for (let i = 0; i < 50; i++) {
                particles.push(new Particle(x, y, color));
            }
        }
        
        function animate() {
            ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            particles = particles.filter(p => p.alpha > 0);
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            
            requestAnimationFrame(animate);
        }
        
        setInterval(createFirework, 800);
        animate();
    </script>
</body>
</html>
HTMLEOF
}

# 下雪效果
generate_snow_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; }
        body {
            background: linear-gradient(to bottom, #1a1a2e, #16213e);
            overflow: hidden;
            height: 100vh;
        }
        .snowflake {
            position: fixed;
            top: -10px;
            color: #fff;
            font-size: 1em;
            animation: fall linear infinite;
        }
        @keyframes fall {
            to { transform: translateY(100vh) rotate(360deg); }
        }
        .title {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #fff;
            font-size: 3em;
            text-shadow: 2px 2px 10px rgba(255,255,255,0.5);
        }
    </style>
</head>
<body>
    <div class="title">❄️ THEME_PLACEHOLDER ❄️</div>
    <script>
        const flakes = ['❄', '❅', '❆', '•'];
        for (let i = 0; i < 100; i++) {
            const flake = document.createElement('div');
            flake.className = 'snowflake';
            flake.textContent = flakes[Math.floor(Math.random() * flakes.length)];
            flake.style.left = Math.random() * 100 + 'vw';
            flake.style.animationDuration = (Math.random() * 3 + 5) + 's';
            flake.style.opacity = Math.random() * 0.7 + 0.3;
            flake.style.fontSize = (Math.random() * 15 + 10) + 'px';
            document.body.appendChild(flake);
        }
    </script>
</body>
</html>
HTMLEOF
}

# 默认页面模板
generate_default_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>THEME_PLACEHOLDER</title>
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
        .time {
            margin-top: 30px;
            font-size: 1.2em;
            opacity: 0.8;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.9); }
            to { opacity: 1; transform: scale(1); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 THEME_PLACEHOLDER</h1>
        <p class="time" id="time"></p>
    </div>
    <script>
        setInterval(() => {
            document.getElementById('time').textContent = 
                new Date().toLocaleString('zh-CN');
        }, 1000);
    </script>
</body>
</html>
HTMLEOF
}

# 粒子动画页面
generate_particle_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; }
        body { background: #000; overflow: hidden; }
        canvas { display: block; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const particles = [];
        const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#f9ca24', '#6c5ce7'];
        
        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 5 + 1;
                this.speedX = Math.random() * 3 - 1.5;
                this.speedY = Math.random() * 3 - 1.5;
                this.color = colors[Math.floor(Math.random() * colors.length)];
            }
            update() {
                this.x += this.speedX;
                this.y += this.speedY;
                if (this.x < 0 || this.x > canvas.width) this.speedX *= -1;
                if (this.y < 0 || this.y > canvas.height) this.speedY *= -1;
            }
            draw() {
                ctx.fillStyle = this.color;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
            }
        }
        
        for (let i = 0; i < 100; i++) {
            particles.push(new Particle());
        }
        
        function animate() {
            ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.update();
                p.draw();
            });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>
HTMLEOF
}

# 星空效果页面
generate_starry_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; }
        body { background: radial-gradient(ellipse at bottom, #1b2735 0%, #090a0f 100%); overflow: hidden; height: 100vh; }
        .star { position: fixed; background: #fff; border-radius: 50%; animation: twinkle ease-in-out infinite; }
        @keyframes twinkle { 0%, 100% { opacity: 0.3; } 50% { opacity: 1; } }
        .title { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #fff; font-size: 2em; text-shadow: 0 0 20px #fff; }
    </style>
</head>
<body>
    <div class="title">✨ THEME_PLACEHOLDER ✨</div>
    <script>
        for (let i = 0; i < 200; i++) {
            const star = document.createElement('div');
            star.className = 'star';
            star.style.left = Math.random() * 100 + 'vw';
            star.style.top = Math.random() * 100 + 'vh';
            star.style.width = star.style.height = Math.random() * 3 + 'px';
            star.style.animationDuration = (Math.random() * 3 + 2) + 's';
            document.body.appendChild(star);
        }
    </script>
</body>
</html>
HTMLEOF
}

# 时钟页面
generate_clock_page() {
    cat << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>THEME_PLACEHOLDER</title>
    <style>
        * { margin: 0; padding: 0; }
        body {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: monospace;
        }
        .clock {
            font-size: 5em;
            color: #00ff88;
            text-shadow: 0 0 20px #00ff88;
        }
        .date {
            font-size: 1.5em;
            color: #fff;
            margin-top: 20px;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div style="text-align: center;">
        <div class="clock" id="clock">00:00:00</div>
        <div class="date" id="date"></div>
    </div>
    <script>
        function update() {
            const now = new Date();
            document.getElementById('clock').textContent = now.toLocaleTimeString('zh-CN');
            document.getElementById('date').textContent = now.toLocaleDateString('zh-CN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
        }
        setInterval(update, 1000);
        update();
    </script>
</body>
</html>
HTMLEOF
}

# 主流程
log "开始生成新页面..."

cd "$WORKSPACE"

# 确保在 main 分支
git checkout main 2>/dev/null || log "已在 main 分支或切换失败"

# 选择主题（避免重复）
THEME=$(select_theme)
THEME_ID=${THEME_POOL[$THEME]}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="auto-gen-${TIMESTAMP}.html"
FILEPATH="$OUTPUT_DIR/$FILENAME"

log "选择主题: $THEME (ID: $THEME_ID)"

# 生成页面
generate_page_content "$THEME" "$TIMESTAMP" | sed "s/THEME_PLACEHOLDER/$THEME/g" > "$FILEPATH"

log "页面已生成: $FILENAME"

# 更新历史
update_history "$THEME"

# Git 提交
git add "$FILEPATH"
git commit -m "feat: 自动生成页面 - $THEME ($TIMESTAMP)" || {
    log "没有需要提交的更改"
    exit 0
}

# 确保在 main 分支
git checkout main 2>/dev/null || true

git push origin main

log "页面已提交并推送到 GitHub"
echo "✅ 完成: $FILENAME (主题: $THEME)"
