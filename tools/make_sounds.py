"""효과음과 배경 음악을 합성해 assets/sounds/에 WAV로 저장한다 (PRD P1-7).

외부 파일 없이 파이썬 표준 라이브러리만 쓴다. 소리를 바꾸려면 값을 고치고 다시 실행한다:
    python3 tools/make_sounds.py
"""

import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def square(phase):
    return 1.0 if phase % 1.0 < 0.5 else -1.0


def sine(phase):
    return math.sin(2 * math.pi * phase)


def triangle(phase):
    p = phase % 1.0
    return 4.0 * p - 1.0 if p < 0.5 else 3.0 - 4.0 * p


def tone(duration, freq_start, freq_end, wave_fn, volume=1.0, attack=0.005):
    """주파수가 freq_start에서 freq_end로 미끄러지며 사라지는 소리."""
    n = int(duration * RATE)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / n
        phase += (freq_start + (freq_end - freq_start) * t) / RATE
        env = min(i / (attack * RATE), 1.0) * (1.0 - t) ** 2
        out.append(wave_fn(phase) * env * volume)
    return out


def noise(duration, volume=1.0):
    n = int(duration * RATE)
    return [random.uniform(-1, 1) * (1.0 - i / n) ** 3 * volume for i in range(n)]


def mix(*tracks):
    length = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(length)]


def save(name, samples, peak=0.8):
    top = max(abs(s) for s in samples) or 1.0
    scale = peak / top
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(struct.pack("<h", int(s * scale * 32767)) for s in samples))


def note(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def make_music():
    """120 BPM, 8마디(16초) 반복 곡. Am - F - C - G를 두 마디씩."""
    beat = 0.5
    bar = beat * 4
    chords = [(57, 60, 64), (53, 57, 60), (48, 52, 55), (55, 59, 62)]  # Am F C G
    total = int(bar * 8 * RATE)
    track = [0.0] * total

    def add(start_sec, samples):
        start = int(start_sec * RATE)
        for i, s in enumerate(samples):
            if start + i < total:
                track[start + i] += s

    for b in range(8):
        root, third, fifth = chords[b // 2]
        bar_start = b * bar
        for eighth in range(8):  # 베이스: 8분음표 근음
            add(bar_start + eighth * beat / 2, tone(beat / 2 * 0.9, note(root - 24), note(root - 24), square, 0.22))
        arp = [root, third, fifth, third + 12, fifth, third, root + 12, fifth]
        for step in range(16):  # 아르페지오: 16분음표
            add(bar_start + step * beat / 4, tone(beat / 4 * 0.95, note(arp[step % 8] + 12), note(arp[step % 8] + 12), triangle, 0.16))
        for k in range(4):  # 킥은 매 박, 하이햇은 엇박
            add(bar_start + k * beat, tone(0.15, 150, 45, sine, 0.5))
            add(bar_start + k * beat + beat / 2, noise(0.04, 0.12))
    return track


def main():
    random.seed(7)
    save("shoot", tone(0.08, 1100, 500, square, 0.6))
    save("kill", mix(noise(0.1, 0.6), tone(0.12, 320, 110, triangle)))
    save("hurt", mix(tone(0.22, 180, 70, square, 0.8), noise(0.15, 0.4)))
    save("levelup", sum((tone(0.12, note(m), note(m), triangle) for m in (72, 76, 79, 84)), []))
    save("music", make_music(), peak=0.7)
    print("saved to", OUT)


if __name__ == "__main__":
    main()
