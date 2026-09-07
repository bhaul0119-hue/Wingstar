from pathlib import Path

root = Path(__file__).resolve().parents[1]

manifest = root / 'android/app/src/main/AndroidManifest.xml'
if manifest.exists():
    text = manifest.read_text(encoding='utf-8')
    perms = [
        '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />',
        '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />',
    ]
    marker = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
    if marker in text:
        missing = [p for p in perms if p not in text]
        if missing:
            text = text.replace(marker, marker + '\n    ' + '\n    '.join(missing), 1)
    manifest.write_text(text, encoding='utf-8')


def add_plist_key(text: str, key: str, value: str) -> str:
    if f'<key>{key}</key>' in text:
        return text
    insert = f'\n\t<key>{key}</key>\n\t<string>{value}</string>'
    return text.replace('</dict>', insert + '\n</dict>', 1)


plist = root / 'ios/Runner/Info.plist'
if plist.exists():
    text = plist.read_text(encoding='utf-8')
    text = add_plist_key(text, 'NSMotionUsageDescription',
                         'Wingstar가 걷기 움직임을 측정하기 위해 모션 센서를 사용합니다.')
    text = add_plist_key(text, 'NSLocationWhenInUseUsageDescription',
                         'Wingstar가 FLOW 중 이동 거리를 계산하기 위해 위치를 사용합니다.')
    plist.write_text(text, encoding='utf-8')

print('Native permission patch complete.')
