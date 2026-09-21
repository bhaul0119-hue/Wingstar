import json
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CONFIG = ROOT / "config.json"
WORK = ROOT / ".render"
OUTPUT = ROOT / "output"


def run(cmd):
    print("$", " ".join(map(str, cmd)))
    subprocess.run(cmd, check=True)


def ffmpeg_path():
    path = shutil.which("ffmpeg")
    if not path:
        raise SystemExit("FFmpeg가 필요합니다. Windows: winget install Gyan.FFmpeg / macOS: brew install ffmpeg")
    return path


def esc_drawtext(text: str) -> str:
    return (text.replace("\\", "\\\\").replace(":", "\\:").replace("'", "\\'").replace("%", "\\%"))


def font_file():
    # Common fallbacks. Users can set FONT_FILE explicitly if desired.
    candidates = [
        os.environ.get("FONT_FILE"),
        r"C:\\Windows\\Fonts\\malgun.ttf",
        "/System/Library/Fonts/AppleSDGothicNeo.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).exists():
            return candidate
    return None


def build_text_filter(text, position, width, height, font_size, color, font):
    if not text:
        return None
    x = "(w-text_w)/2"
    if position == "bottom":
        y = f"h-{font_size * 2.0:.0f}"
    elif position == "top":
        y = f"{font_size * 1.2:.0f}"
    else:
        y = "(h-text_h)/2"
    args = [f"text='{esc_drawtext(text)}'", f"fontsize={font_size}", f"fontcolor={color}", f"x={x}", f"y={y}", "shadowcolor=black@0.35", "shadowx=2", "shadowy=2"]
    if font:
        args.insert(0, f"fontfile='{esc_drawtext(font)}'")
    return "drawtext=" + ":".join(args)


def render_clip(index, clip, cfg, font):
    out = WORK / f"clip_{index:02d}.mp4"
    width = cfg["output"]["width"]
    height = cfg["output"]["height"]
    fps = cfg["output"]["fps"]
    duration = float(clip["duration"])
    vf = [f"scale={width}:{height}:force_original_aspect_ratio=increase", f"crop={width}:{height}"]

    if clip.get("image"):
        image = ROOT / clip["image"]
        if not image.exists():
            raise SystemExit(f"이미지 파일이 없습니다: {image}")
        input_args = ["-loop", "1", "-i", str(image)]
    else:
        input_args = ["-f", "lavfi", "-i", f"color=c={cfg['style']['background']}:s={width}x{height}:r={fps}"]

    text_filter = build_text_filter(
        clip.get("text", ""), clip.get("position", "center"), width, height,
        cfg["style"]["font_size"], cfg["style"]["text_color"], font
    )
    if text_filter:
        vf.append(text_filter)

    vf.append("format=yuv420p")
    run([
        "ffmpeg", "-y", *input_args,
        "-t", str(duration),
        "-vf", ",".join(vf),
        "-r", str(fps),
        "-an",
        "-c:v", "libx264", "-preset", "medium", "-crf", "20",
        str(out),
    ])
    return out


def concat(clips, output):
    concat_file = WORK / "concat.txt"
    concat_file.write_text("".join(f"file '{p.as_posix().replace(chr(39), \"'\\\\''\")}'\n" for p in clips), encoding="utf-8")
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(concat_file), "-c", "copy", str(output)])


def add_audio(video, audio, output, volume):
    if not audio.exists():
        shutil.copy2(video, output)
        print(f"오디오 파일이 없어 무음 영상으로 저장했습니다: {output}")
        return
    run([
        "ffmpeg", "-y", "-i", str(video), "-i", str(audio),
        "-map", "0:v:0", "-map", "1:a:0", "-c:v", "copy",
        "-af", f"volume={volume}", "-shortest", "-c:a", "aac", "-b:a", "192k", str(output)
    ])


def main():
    ffmpeg_path()
    cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    WORK.mkdir(exist_ok=True)
    OUTPUT.mkdir(exist_ok=True)
    font = font_file()
    if not font:
        print("경고: 한글 폰트를 찾지 못했습니다. FONT_FILE 환경변수를 지정하세요.")

    clips = [render_clip(i, clip, cfg, font) for i, clip in enumerate(cfg["clips"], 1)]
    silent = WORK / "silent.mp4"
    concat(clips, silent)
    final = OUTPUT / cfg["output"]["filename"]
    add_audio(silent, ROOT / cfg["audio"]["file"], final, cfg["audio"]["volume"])
    print(f"완료: {final}")


if __name__ == "__main__":
    main()
