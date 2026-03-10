#!/bin/bash
# 每小时自动生成创意HTML页面的脚本（增强版 - 先设计后生成）

set -e

WORKSPACE="/home/ubuntu/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE"
DATA_DIR="$WORKSPACE/scripts/data"
LOG_FILE="$DATA_DIR/page-generator.log"
HISTORY_FILE="$DATA_DIR/page-history.json"
DESIGN_DIR="$WORKSPACE/scripts/designs"

# 创建目录
mkdir -p "$DATA_DIR" "$DESIGN_DIR"

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 主题池（每个主题包含设计思路）
declare -A THEME_DESIGNS
THEME_DESIGNS["粒子动画"]="
设计思路: 创建一个交互式粒子系统，粒子会跟随鼠标移动并相互连接
配色方案: 深色背景 + 霓虹色粒子（青色、品红、黄色）
动画效果: 1) 粒子漂浮动画 2) 鼠标跟随动画 3) 粒子连线动画
交互功能: 1) 鼠标移动控制粒子 2) 点击产生爆炸效果
技术方案: Canvas + JavaScript
"

THEME_DESIGNS["星空效果"]="
设计思路: 模拟夜空中的星星闪烁和流星效果
配色方案: 深蓝到黑色渐变背景 + 白色/金色星星
动画效果: 1) 星星闪烁动画 2) 流星划过动画 3) 星云旋转动画
交互功能: 1) 鼠标移动产生星光 2) 点击生成流星
技术方案: CSS动画 + Canvas
"

THEME_DESIGNS["波浪动画"]="
设计思路: 多层波浪叠加，创造海洋效果
配色方案: 深蓝到浅蓝渐变 + 白色泡沫
动画效果: 1) 波浪起伏动画 2) 颜色渐变动画 3) 粒子漂浮
交互功能: 1) 鼠标控制波浪高度 2) 点击产生涟漪
技术方案: Canvas + requestAnimationFrame
"

THEME_DESIGNS["几何图形"]="
设计思路: 旋转的几何图形组合，创造万花筒效果
配色方案: 渐变色边框 + 半透明填充
动画效果: 1) 图形旋转动画 2) 缩放动画 3) 颜色循环动画
交互功能: 1) 鼠标控制旋转速度 2) 点击切换图形
技术方案: CSS动画 + JavaScript
"

THEME_DESIGNS["时钟设计"]="
设计思路: 创意模拟时钟，带有动态效果
配色方案: 深色背景 + 霓虹指针
动画效果: 1) 秒针平滑转动 2) 背景粒子动画 3) 数字翻转动画
交互功能: 1) 悬停显示详细信息 2) 点击切换时区
技术方案: CSS动画 + JavaScript
"

THEME_DESIGNS["烟花效果"]="
设计思路: 点击触发烟花爆炸效果
配色方案: 黑色背景 + 多彩烟花
动画效果: 1) 烟花上升动画 2) 爆炸粒子动画 3) 拖尾效果
交互功能: 1) 点击产生烟花 2) 自动随机烟花
技术方案: Canvas + 粒子系统
"

THEME_DESIGNS["矩阵雨"]="
设计思路: 黑客帝国风格的字符雨
配色方案: 黑色背景 + 绿色字符
动画效果: 1) 字符下落动画 2) 闪烁效果 3) 速度变化
交互功能: 1) 鼠标影响下落方向 2) 点击改变颜色
技术方案: Canvas + 字符绘制
"

THEME_DESIGNS["俄罗斯方块"]="
设计思路: 经典俄罗斯方块游戏
配色方案: 深色背景 + 彩色方块
动画效果: 1) 方块下落动画 2) 消行闪光 3) 背景粒子
交互功能: 1) 键盘控制 2) 计分系统
技术方案: Canvas + 游戏逻辑
"

# 读取历史
read_history() {
    [ -f "$HISTORY_FILE" ] && cat "$HISTORY_FILE" || echo '{"recent_themes":[],"all_themes":{}}'
}

# 获取最近使用的主题
get_recent_themes() {
    local history=$(read_history)
    echo "$history" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for theme in data.get('recent_themes', [])[:6]:
    print(theme)
" 2>/dev/null || echo ""
}

# 选择主题
select_theme() {
    local recent=$(get_recent_themes)
    local all_keys=("${!THEME_DESIGNS[@]}")
    local available=()
    
    for key in "${all_keys[@]}"; do
        [ -z "$(echo "$recent" | grep "^$key$")" ] && available+=("$key")
    done
    
    [ ${#available[@]} -eq 0 ] && { log "所有主题已用，重置"; available=("${all_keys[@]}"); }
    
    echo "${available[$RANDOM % ${#available[@]}]}"
}

# 更新历史
update_history() {
    python3 << PYEOF
import json, os
theme, history_file = "$1", "$HISTORY_FILE"
data = {"recent_themes": [], "all_themes": {}}
if os.path.exists(history_file):
    with open(history_file) as f: data = json.load(f)
if theme in data["recent_themes"]: data["recent_themes"].remove(theme)
data["recent_themes"].insert(0, theme)
data["recent_themes"] = data["recent_themes"][:20]
data["all_themes"][theme] = data["all_themes"].get(theme, 0) + 1
with open(history_file, 'w') as f: json.dump(data, f, indent=2)
PYEOF
}

# 生成设计文档
generate_design_doc() {
    local theme=$1
    local design_file=$2
    local design=${THEME_DESIGNS[$theme]}
    
    cat > "$design_file" << EOF
# $theme - 设计文档

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')

$design

## 技术要求
- 使用 HTML5 + CSS3 + JavaScript
- 响应式设计
- 性能优化（60fps）
- 代码注释清晰

## 文件信息
- 文件名: $(basename $design_file)
- 主题: $theme
EOF
    
    log "设计文档已生成: $(basename $design_file)"
}

# 生成 HTML 页面
generate_html_page() {
    local theme=$1
    local output_file=$2
    
    # 这里调用 Python 脚本生成更复杂的页面
    python3 << PYEOF
import random
import os

theme = "$theme"
output_file = "$output_file"

# 根据主题生成不同的HTML
if theme == "粒子动画":
    html = '''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>粒子动画 - 交互式粒子系统</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #0a0e27;
            overflow: hidden;
            font-family: 'Segoe UI', sans-serif;
        }
        canvas { display: block; }
        .info {
            position: fixed;
            top: 20px;
            left: 20px;
            color: #fff;
            font-size: 14px;
            z-index: 100;
            background: rgba(0, 0, 0, 0.5);
            padding: 15px;
            border-radius: 10px;
        }
        h1 {
            font-size: 24px;
            margin-bottom: 10px;
            background: linear-gradient(90deg, #00f5ff, #ff00ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body>
    <div class="info">
        <h1>🎨 粒子动画</h1>
        <p>移动鼠标控制粒子</p>
        <p>点击产生爆炸效果</p>
    </div>
    <canvas id="canvas"></canvas>
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const particles = [];
        const colors = ['#00f5ff', '#ff00ff', '#ffff00', '#00ff00'];
        let mouseX = canvas.width / 2;
        let mouseY = canvas.height / 2;
        
        class Particle {
            constructor(x, y, isExplosion = false) {
                this.x = x || Math.random() * canvas.width;
                this.y = y || Math.random() * canvas.height;
                this.size = Math.random() * 3 + 1;
                this.speedX = (Math.random() - 0.5) * (isExplosion ? 10 : 2);
                this.speedY = (Math.random() - 0.5) * (isExplosion ? 10 : 2);
                this.color = colors[Math.floor(Math.random() * colors.length)];
                this.life = isExplosion ? 100 : Infinity;
            }
            
            update() {
                // 鼠标吸引
                const dx = mouseX - this.x;
                const dy = mouseY - this.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                if (distance < 200 && Number.isFinite(distance)) {
                    this.speedX += dx / distance * 0.5;
                    this.speedY += dy / distance * 0.5;
                }
                
                this.x += this.speedX;
                this.y += this.speedY;
                this.speedX *= 0.99;
                this.speedY *= 0.99;
                
                if (this.life !== Infinity) this.life--;
                
                // 边界反弹
                if (this.x < 0 || this.x > canvas.width) this.speedX *= -1;
                if (this.y < 0 || this.y > canvas.height) this.speedY *= -1;
            }
            
            draw() {
                ctx.save();
                ctx.globalAlpha = this.life === Infinity ? 1 : this.life / 100;
                ctx.fillStyle = this.color;
                ctx.shadowBlur = 15;
                ctx.shadowColor = this.color;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
        }
        
        // 初始化粒子
        for (let i = 0; i < 100; i++) {
            particles.push(new Particle());
        }
        
        // 爆炸效果
        function createExplosion(x, y) {
            for (let i = 0; i < 50; i++) {
                particles.push(new Particle(x, y, true));
            }
        }
        
        // 绘制连线
        function drawLines() {
            for (let i = 0; i < particles.length; i++) {
                for (let j = i + 1; j < particles.length; j++) {
                    const dx = particles[i].x - particles[j].x;
                    const dy = particles[i].y - particles[j].y;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    
                    if (distance < 100) {
                        ctx.save();
                        ctx.globalAlpha = (100 - distance) / 100 * 0.5;
                        ctx.strokeStyle = particles[i].color;
                        ctx.lineWidth = 1;
                        ctx.beginPath();
                        ctx.moveTo(particles[i].x, particles[i].y);
                        ctx.lineTo(particles[j].x, particles[j].y);
                        ctx.stroke();
                        ctx.restore();
                    }
                }
            }
        }
        
        // 动画循环
        function animate() {
            ctx.fillStyle = 'rgba(10, 14, 39, 0.1)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            drawLines();
            
            for (let i = particles.length - 1; i >= 0; i--) {
                particles[i].update();
                particles[i].draw();
                if (particles[i].life !== Infinity && particles[i].life <= 0) {
                    particles.splice(i, 1);
                }
            }
            
            requestAnimationFrame(animate);
        }
        
        // 事件监听
        canvas.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;
        });
        
        canvas.addEventListener('click', (e) => {
            createExplosion(e.clientX, e.clientY);
        });
        
        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        });
        
        animate();
    </script>
</body>
</html>'''
elif theme == "烟花效果":
    html = '''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>烟花效果</title>
    <style>
        * { margin: 0; padding: 0; }
        body { background: #000; overflow: hidden; }
        canvas { display: block; }
        .info {
            position: fixed;
            top: 20px;
            left: 20px;
            color: #fff;
            font-size: 14px;
            z-index: 100;
            background: rgba(0, 0, 0, 0.5);
            padding: 15px;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="info">
        <h2>🎆 烟花效果</h2>
        <p>点击屏幕放烟花</p>
    </div>
    <canvas id="canvas"></canvas>
    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        
        const fireworks = [];
        const particles = [];
        
        class Firework {
            constructor(sx, sy, tx, ty) {
                this.x = sx;
                this.y = sy;
                this.tx = tx;
                this.ty = ty;
                this.distanceToTarget = Math.sqrt(Math.pow(tx - sx, 2) + Math.pow(ty - sy, 2));
                this.distanceTraveled = 0;
                this.coordinates = [];
                this.coordinateCount = 3;
                while (this.coordinateCount--) {
                    this.coordinates.push([this.x, this.y]);
                }
                this.angle = Math.atan2(ty - sy, tx - sx);
                this.speed = 2;
                this.acceleration = 1.05;
                this.brightness = Math.random() * 50 + 50;
                this.hue = Math.random() * 360;
            }
            
            update(index) {
                this.coordinates.pop();
                this.coordinates.unshift([this.x, this.y]);
                this.speed *= this.acceleration;
                const vx = Math.cos(this.angle) * this.speed;
                const vy = Math.sin(this.angle) * this.speed;
                this.distanceTraveled = Math.sqrt(Math.pow(this.x - this.coordinates[this.coordinateCount-1][0], 2) + Math.pow(this.y - this.coordinates[this.coordinateCount-1][1], 2));
                
                if (this.distanceTraveled >= this.distanceToTarget) {
                    createParticles(this.tx, this.ty, this.hue);
                    fireworks.splice(index, 1);
                } else {
                    this.x += vx;
                    this.y += vy;
                }
            }
            
            draw() {
                ctx.beginPath();
                ctx.moveTo(this.coordinates[this.coordinates.length - 1][0], this.coordinates[this.coordinates.length - 1][1]);
                ctx.lineTo(this.x, this.y);
                ctx.strokeStyle = 'hsl(' + this.hue + ', 100%, ' + this.brightness + '%)';
                ctx.stroke();
            }
        }
        
        class Particle {
            constructor(x, y, hue) {
                this.x = x;
                this.y = y;
                this.coordinates = [];
                this.coordinateCount = 5;
                while (this.coordinateCount--) {
                    this.coordinates.push([this.x, this.y]);
                }
                this.angle = Math.random() * Math.PI * 2;
                this.speed = Math.random() * 10 + 1;
                this.friction = 0.95;
                this.gravity = 1;
                this.hue = hue + Math.random() * 30;
                this.brightness = Math.random() * 50 + 50;
                this.alpha = 1;
                this.decay = Math.random() * 0.03 + 0.015;
            }
            
            update(index) {
                this.coordinates.pop();
                this.coordinates.unshift([this.x, this.y]);
                this.speed *= this.friction;
                this.x += Math.cos(this.angle) * this.speed;
                this.y += Math.sin(this.angle) * this.speed + this.gravity;
                this.alpha -= this.decay;
                
                if (this.alpha <= this.decay) {
                    particles.splice(index, 1);
                }
            }
            
            draw() {
                ctx.beginPath();
                ctx.moveTo(this.coordinates[this.coordinates.length - 1][0], this.coordinates[this.coordinates.length - 1][1]);
                ctx.lineTo(this.x, this.y);
                ctx.strokeStyle = 'hsla(' + this.hue + ', 100%, ' + this.brightness + '%, ' + this.alpha + ')';
                ctx.stroke();
            }
        }
        
        function createParticles(x, y, hue) {
            const particleCount = 30;
            for (let i = 0; i < particleCount; i++) {
                particles.push(new Particle(x, y, hue));
            }
        }
        
        let timer = 0;
        function animate() {
            requestAnimationFrame(animate);
            ctx.globalCompositeOperation = 'destination-out';
            ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.globalCompositeOperation = 'lighter';
            
            timer++;
            if (timer % 60 === 0) {
                const sx = canvas.width / 2;
                const sy = canvas.height;
                const tx = Math.random() * canvas.width;
                const ty = Math.random() * canvas.height / 2;
                fireworks.push(new Firework(sx, sy, tx, ty));
            }
            
            for (let i = fireworks.length - 1; i >= 0; i--) {
                fireworks[i].draw();
                fireworks[i].update(i);
            }
            
            for (let i = particles.length - 1; i >= 0; i--) {
                particles[i].draw();
                particles[i].update(i);
            }
        }
        
        canvas.addEventListener('click', (e) => {
            const sx = canvas.width / 2;
            const sy = canvas.height;
            fireworks.push(new Firework(sx, sy, e.clientX, e.clientY));
        });
        
        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        });
        
        animate();
    </script>
</body>
</html>'''
else:
    # 默认模板（其他主题）
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{theme}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', sans-serif;
            overflow: hidden;
        }}
        .container {{
            text-align: center;
            color: white;
            animation: fadeIn 1s ease-out;
        }}
        h1 {{
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        .time {{
            margin-top: 30px;
            font-size: 1.2em;
            opacity: 0.8;
        }}
        @keyframes fadeIn {{
            from {{ opacity: 0; transform: scale(0.9); }}
            to {{ opacity: 1; transform: scale(1); }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 {theme}</h1>
        <p class="time" id="time"></p>
    </div>
    <script>
        setInterval(() => {{
            document.getElementById('time').textContent = 
                new Date().toLocaleString('zh-CN');
        }}, 1000);
    </script>
</body>
</html>'''

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"HTML页面已生成: {output_file}")
PYEOF
}

# 主流程
log "开始生成新页面..."
cd "$WORKSPACE"

# 确保在 main 分支
git checkout main 2>/dev/null || log "已在 main 分支"

# 选择主题
THEME=$(select_theme)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="auto-gen-${TIMESTAMP}.html"
DESIGN_FILE="$DESIGN_DIR/design-${TIMESTAMP}.md"

log "选择主题: $THEME"

# 步骤1: 生成设计文档
generate_design_doc "$THEME" "$DESIGN_FILE"

# 步骤2: 基于设计文档生成HTML
generate_html_page "$THEME" "$OUTPUT_DIR/$FILENAME"

# 更新历史
update_history "$THEME"

log "页面已生成: $FILENAME"

# Git 提交
git add "$OUTPUT_DIR/$FILENAME" "$DESIGN_FILE" 2>/dev/null || true
git commit -m "feat: 自动生成页面 - $THEME ($TIMESTAMP)

- 主题: $THEME
- 设计文档: $(basename $DESIGN_FILE)
- 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

设计思路:
$(cat "$DESIGN_FILE" | grep -A 5 "设计思路" | head -6)" || {
    log "没有需要提交的更改"
    exit 0
}

# 推送
git push origin main

log "页面已提交并推送到 GitHub"
echo "✅ 完成: $FILENAME (主题: $THEME)"
echo "📄 设计文档: $(basename $DESIGN_FILE)"
