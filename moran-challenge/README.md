# 모란 꽃 챌린지 자동 제작기

`moran-challenge`는 참고 챌린지 영상을 기준으로 **모란 버전 숏폼 영상**을 반복 제작하기 위한 독립적인 Python/FFmpeg 프로젝트입니다.

## 목표

- 세로형 9:16 숏폼
- 질문 → 꽃 이미지 → 분위기 전환 → `모란` 반전 → 본인 사진 엔딩
- 사진만 교체해도 다시 렌더링할 수 있는 구조
- 원본 참고 영상은 저장소에 올리지 않고 로컬에서 `reference/reference.mp4`로 사용

## 로컬 폴더

```text
moran-challenge/
├─ assets/
│  ├─ flowers/
│  │  ├─ 01_rose.jpg
│  │  ├─ 02_black_rose.jpg
│  │  ├─ 03_lily.jpg
│  │  ├─ 04_camelia.jpg
│  │  ├─ 05_peony.jpg
│  │  └─ 06_moran.jpg
│  └─ final/
│     └─ moran.jpg
├─ reference/
│  └─ reference.mp4
├─ output/
├─ config.json
├─ make_challenge.py
└─ requirements.txt
```

## 실행

FFmpeg가 설치되어 있어야 합니다.

```bash
python -m pip install -r requirements.txt
python make_challenge.py
```

완성 영상은 `output/moran_flower_challenge.mp4`에 생성됩니다.

## Codex 작업 지침

1. 먼저 `config.json`의 컷별 텍스트와 시간을 확인합니다.
2. `reference/reference.mp4`가 있으면 참고 영상의 전체 길이와 컷 전환을 분석합니다.
3. `assets/`의 실제 이미지가 없으면 예시 이미지 생성/검색을 임의로 진행하지 말고 필요한 파일명을 안내합니다.
4. 사용자가 제공한 사진의 얼굴을 임의로 변형하지 않습니다.
5. 출력은 H.264 + AAC, 1080x1920, 30fps MP4를 기본으로 합니다.
6. 원본 참고 영상의 음악이나 영상물을 결과물에 복제하지 않습니다. 사용자가 별도로 제공한 오디오만 사용합니다.
7. 사용자가 요청하면 자막 크기, 폰트, 전환, 줌 효과를 `config.json`에서 조절할 수 있게 유지합니다.
