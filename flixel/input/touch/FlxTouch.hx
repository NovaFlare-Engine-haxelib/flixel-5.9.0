package flixel.input.touch;

#if FLX_TOUCH
import openfl.geom.Point;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxSwipe;
import flixel.input.IFlxInput;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

/**
 * Helper class, contains and tracks touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.input.touch.FlxTouchManager)
class FlxTouch extends FlxPointer implements IFlxDestroyable implements IFlxInput
{
	/**
	 * The _unique_ ID of this touch. You should not make not any further assumptions
	 * about this value - IDs are not guaranteed to start from 0 or ascend in order.
	 * The behavior may vary from device to device.
	 */
	public var touchPointID(get, never):Int;

	/**
	 * A value between 0.0 and 1.0 indicating force of the contact with the device. If the device does not support detecting the pressure, the value is 1.0.
	 */
	public var pressure(default, null):Float;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	var input:FlxInput<Int>;
	var flashPoint = new Point();

	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Int = -1;

	public function destroy():Void
	{
		input = null;
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
		flashPoint = null;
	}

	/**
	 * Resets the justPressed/justReleased flags, sets touch to not pressed and sets touch pressure to 0.
	 */
	public function recycle(x:Int, y:Int, pointID:Int, pressure:Float):Void
	{
		setXY(x, y);
		input.ID = pointID;
		input.reset();
		this.pressure = pressure;
	}

	/**
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 * @param	pressure	A value between 0.0 and 1.0 indicating force of the contact with the device. If the device does not support detecting the pressure, the value is 1.0.
	 */
	function new(x:Int = 0, y:Int = 0, pointID:Int = 0, pressure:Float = 0)
	{
		super();

		input = new FlxInput(pointID);
		setXY(x, y);
		this.pressure = pressure;
	}

	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	function handleInput():Void
	{
		input.handleInput();

		if (justPressed)
		{
			justPressedPosition.set(viewX, viewY);
			justPressedTimeInTicks = FlxG.game.ticks;
 _startX=viewX;_startY=viewY;
		}
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, justPressedPosition.copyTo(), getViewPosition(), justPressedTimeInTicks));
		}
		#end
	}

	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 *
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	function setXY(X:Int, Y:Int):Void
	{
 _prevX=x;_prevY=y;_prevViewX=viewX;_prevViewY=viewY;
		flashPoint.setTo(X, Y);
		flashPoint = FlxG.game.globalToLocal(flashPoint);

		setRawPositionUnsafe(flashPoint.x, flashPoint.y);
 velocity.set(deltaViewX,deltaViewY);
	}

	inline function get_touchPointID():Int
	{
		return input.ID;
	}

	inline function get_justReleased():Bool
	{
		return input.justReleased;
	}

	inline function get_released():Bool
	{
		return input.released;
	}

	inline function get_pressed():Bool
	{
		return input.pressed;
	}

	inline function get_justPressed():Bool
	{
		return input.justPressed;
	}

#if FLX_TOUCH
	public var justMovedUp(get, never):Bool;
#end

#if FLX_TOUCH
	public var justMovedDown(get, never):Bool;
#end

#if FLX_TOUCH
	public var justMovedLeft(get, never):Bool;
#end

#if FLX_TOUCH
	public var justMovedRight(get, never):Bool;
#end

#if FLX_TOUCH
	public var justMoved(get, never):Bool;
#end

#if FLX_TOUCH
	public var deltaX(get, default):Float;
#end

#if FLX_TOUCH
	public var deltaY(get, default):Float;
#end

#if FLX_TOUCH
	public var deltaViewX(get, default):Float;
#end

#if FLX_TOUCH
	public var deltaViewY(get, default):Float;
#end

#if FLX_TOUCH
	public var ticksDeltaSincePress(get, default):Float;
#end

#if FLX_TOUCH
	public var velocity(default, null):FlxPoint = FlxPoint.get();
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_justMovedUp():Bool
	{
		var swiped:Bool = _swipeDeltaY > FlxG.touches.swipeThreshold.y;
		if (swiped)
			_startY = viewY;
		return swiped;
	}
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_justMovedDown():Bool
	{
		var swiped:Bool = _swipeDeltaY < -FlxG.touches.swipeThreshold.y;
		if (swiped)
			_startY = viewY;
		return swiped;
	}
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_justMovedLeft():Bool
	{
		var swiped:Bool = _swipeDeltaX > FlxG.touches.swipeThreshold.x;
		if (swiped)
			_startX = viewX;
		return swiped;
	}
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_justMovedRight():Bool
	{
		var swiped:Bool = _swipeDeltaX < -FlxG.touches.swipeThreshold.x;
		if (swiped)
			_startX = viewX;
		return swiped;
	}
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_justMoved():Bool
		return x != _prevX || y != _prevY;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_deltaX():Float
		return x - _prevX;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_deltaY():Float
		return y - _prevY;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_deltaViewX():Float
		return viewX - _prevViewX;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_deltaViewY():Float
		return viewY - _prevViewY;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get_ticksDeltaSincePress():Float
		return FlxG.game.ticks - justPressedTimeInTicks;
#end

#if FLX_TOUCH
	var _startY:Float = 0;
#end

#if FLX_TOUCH
	var _swipeDeltaY(get, never):Float;
#end

#if FLX_TOUCH
	var _startX:Float = 0;
#end

#if FLX_TOUCH
	var _swipeDeltaX(get, never):Float;
#end

#if FLX_TOUCH
	var _prevX:Float = 0;
#end

#if FLX_TOUCH
	var _prevY:Float = 0;
#end

#if FLX_TOUCH
	var _prevViewX:Float = 0;
#end

#if FLX_TOUCH
	var _prevViewY:Float = 0;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get__swipeDeltaY():Float
		return viewY - _startY;
#end

#if FLX_TOUCH
	@:noCompletion
	inline function get__swipeDeltaX():Float
		return viewX - _startX;
#end
}
#else
class FlxTouch {}
#end
