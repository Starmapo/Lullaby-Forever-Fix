package meta.data.dependency;

import flixel.math.FlxPoint;

class RealPoint
{
	public static inline function weak(x:Float = 0, y:Float = 0):FlxPoint
	{
		return FlxPoint.weak(x, y);
	}

	public var x(get, set):Float;
	public var y(get, set):Float;

	public function new(x:Float = 0, y:Float = 0)
	{
		real = new FlxPoint(x, y);
	}

	public inline function copyFrom(p:FlxPoint):FlxPoint
	{
		return real.copyFrom(p);
	}

	var real:FlxPoint;

	function get_x()
	{
		return real.x;
	}

	function get_y()
	{
		return real.y;
	}

	function set_x(value:Float)
	{
		return real.x = value;
	}

	function set_y(value:Float)
	{
		return real.y = value;
	}
}
