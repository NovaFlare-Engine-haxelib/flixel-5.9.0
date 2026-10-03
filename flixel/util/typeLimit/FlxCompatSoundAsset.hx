package flixel.util.typeLimit;

import openfl.media.Sound;
import lime.media.AudioBuffer;
import flixel.sound.FlxSoundData;
import haxe.io.Bytes;

/** New source forms are converted before entering the unchanged NF sound loader. */
abstract FlxCompatSoundAsset(Dynamic) from String from Sound from Class<Sound> to Dynamic
{
    @:from public static inline function fromBuffer(buffer:AudioBuffer):FlxCompatSoundAsset
        return cast Sound.fromAudioBuffer(buffer);

    @:from public static inline function fromData(data:FlxSoundData):FlxCompatSoundAsset
        return cast Sound.fromAudioBuffer(data == null ? null : data.buffer);

    @:from public static inline function fromBytes(bytes:Bytes):FlxCompatSoundAsset
        return cast Sound.fromAudioBuffer(bytes == null ? null : AudioBuffer.fromBytes(bytes));
}
