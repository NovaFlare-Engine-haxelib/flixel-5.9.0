# NovaFlare additive compatibility interfaces

Restores original camera updates, mouse/touch updates, sound playback/loading/reset, sound frontend initialization and ordinary quad/triangle rendering. Compatibility flags do not intercept legacy updates or draws. Original color-transform methods remain ordinary reflective functions. Added sound source forms convert to OpenFL Sound before entering the unchanged original loader. No automatic device event registration or new mute setter is installed.

The earlier broad integration changed existing behavior and is superseded by this repair. Compatibility additions must preserve existing NF calls, defaults and update/render/audio paths. Unsupported additions may return a neutral result instead of replacing a legacy implementation.

Windows x64 and Android ARMv7/ARM64/x86_64 native Lime binaries have been rebuilt. The full game targets Windows x64 and Android ARM64. Visual gameplay acceptance is performed manually by the project owner.
