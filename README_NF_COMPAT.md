# NovaFlare compatibility

Adds CNE/Origin utilities, shared FlxSoundData caches, effects and source adapters, draw-item color/depth/wrap controls, input helpers, and UI/debugger compatibility around NF's existing Flixel classes.

NF loadEmbedded(asset, looped, autoDestroy, onComplete) is retained because Origin's FlxStreamSound overrides that signature. Use loadStreamed/loadFromURL/prepare for the additional CNE parameters. An instance FlxSound.load is intentionally not introduced because Origin's FunkinSound declares a static load with a different contract. The library build macro removes only FunkinSound's redundant paused getter/property, allowing it to inherit the identical _paused-backed API; no engine source edit is required.

scrollAngle applies a canvas rotation. shakeMatrixFix is retained as a compatibility flag with NF's default behavior; the Origin-specific matrix correction is not implemented. Existing NF audio playback (including optional hxvlc) remains in place.

Upstream licenses and contributor notices are preserved.
