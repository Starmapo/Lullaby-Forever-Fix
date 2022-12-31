package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flxanimate.data.SpriteMapData.AnimateAtlas;
import haxe.Json;
import haxe.io.Path;
import haxe.xml.Access;
import meta.data.*;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
	This class is used as an extension to many other forever engine stuffs, please don't delete it as it is not only exclusively used in forever engine
	custom stuffs, and is instead used globally.
**/
class ForeverTools
{
	// set up maps and stuffs
	public static function resetMenuMusic(resetVolume:Bool = false)
	{
		// make sure the music is playing
		if (((FlxG.sound.music != null) && (!FlxG.sound.music.playing)) || (FlxG.sound.music == null))
		{
			var song = Paths.music('HYPNO_MENU');
			FlxG.sound.playMusic(song, (resetVolume) ? 0 : 0.7);
			if (resetVolume)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			// placeholder bpm
			Conductor.changeBPM(102);
		}
		//
	}

	public static function returnSkinAsset(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String,
			?defaultChangeableSkin:String = 'default', ?defaultBaseAsset:String = 'base'):String
	{
		var realAsset = '$baseLibrary/$assetModifier/$asset';
		if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
		{
			realAsset = '$baseLibrary/$assetModifier/$asset';
			if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
				realAsset = '$baseLibrary/$defaultBaseAsset/$asset';
		}

		return realAsset;
	}

	public static function killMusic(songsArray:Array<FlxSound>)
	{
		// neat function thing for songs
		for (i in 0...songsArray.length)
		{
			// stop
			songsArray[i].stop();
			songsArray[i].destroy();
		}
	}

	public static function optimizeImages()
	{
		var parent = '';
		var directories = [
			"assets/images/menus",
			"assets/images/shop",
			"assets/images/UI",
			"assets/stages",
			"shitpost/images"
		];
		for (directory in directories)
		{
			optimizeFolder(Path.join([parent, directory]));
		}
	}

	static function optimizeFolder(folder:String)
	{
		var count = 0;
		for (file in FileSystem.readDirectory(folder))
		{
			var fullPath = Path.join([folder, file]);
			if (FileSystem.isDirectory(fullPath))
			{
				optimizeFolder(fullPath);
			}
			else if (file.endsWith('.png'))
			{
				var fileName = Path.withoutExtension(fullPath);
				if (FileSystem.exists('$fileName.xml'))
				{
					var graphic = FlxG.bitmap.add(BitmapData.fromFile(fullPath), false, fullPath);
					optimizeImage(fullPath, FlxAtlasFrames.fromSparrow(graphic, File.getContent('$fileName.xml')));
					count++;
				}
				else if (FileSystem.exists('$fileName.json'))
				{
					var graphic = FlxG.bitmap.add(BitmapData.fromFile(fullPath), false, fullPath);
					var frames = new FlxAtlasFrames(graphic);
					var curJson:AnimateAtlas = Json.parse(File.getContent('$fileName.json').replace(String.fromCharCode(0xFEFF), ""));
					if (curJson != null && curJson.ATLAS != null && curJson.ATLAS.SPRITES != null)
					{
						for (curSprite in curJson.ATLAS.SPRITES)
						{
							var sprite = curSprite.SPRITE;

							var rect = FlxRect.get(sprite.x, sprite.y, sprite.w, sprite.h);

							var size = new Rectangle(0, 0, rect.width, rect.height);
							var sourceSize = FlxPoint.get(size.width, size.height);
							if (sprite.rotated)
								sourceSize.set(size.height, size.width);

							var offset = FlxPoint.get();

							var angle = sprite.rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

							frames.addAtlasFrame(rect, sourceSize, offset, sprite.name, angle);
						}
						optimizeImage(fullPath, frames);
						count++;
					}
					else
					{
						FlxG.bitmap.remove(graphic);
						frames.destroy();
					}
				}
			}
		}
		if (count > 0)
		{
			trace('Optimized $count images in $folder');
		}
	}

	static function optimizeImage(path:String, frames:FlxAtlasFrames)
	{
		var maxX:Float = 0;
		var maxY:Float = 0;
		for (frame in frames.frames)
		{
			var maxMemberX:Float = frame.frame.x + frame.frame.width;
			var maxMemberY:Float = frame.frame.y + frame.frame.height;

			if (maxMemberX > maxX)
				maxX = maxMemberX;
			if (maxMemberY > maxY)
				maxY = maxMemberY;
		}

		var newWidth = Math.ceil(maxX);
		var newHeight = Math.ceil(maxY);

		File.saveBytes(path, frames.parent.bitmap.encode(new Rectangle(0, 0, newWidth, newHeight), new PNGEncoderOptions(false)));

		FlxG.bitmap.remove(frames.parent);
		frames.destroy();
	}
}
