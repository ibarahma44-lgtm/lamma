# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['sign_language_translator.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('gesture_dict.json', '.'),
        ('gesture_model.h5', '.'),
        ('processed_data', 'processed_data')
    ],
    hiddenimports=[
        'mediapipe',
        'cv2',
        'numpy',
        'pyttsx3',
        'gtts',
        'pyautogui',
        'sklearn',
        'matplotlib',
        'tensorflow.keras',
        'tensorflow.keras.models',
        'tensorflow.keras.layers'
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='VocalHands',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='VocalHands'
) 