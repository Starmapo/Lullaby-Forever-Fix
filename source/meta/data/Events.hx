package meta.data;

import meta.data.ScriptHandler;
import meta.state.PlayState;
import sys.FileSystem;

using StringTools;

typedef PlacedEvent =
{
	var timestamp:Float;
	var params:Array<Dynamic>;
	var eventName:String;
};

class Events
{
	public static var eventList:Array<String> = [];

	// boovb
	public static var loadedModules:Map<String, ForeverModule> = [];

	public static function obtainEvents()
	{
		loadedModules.clear();
		eventList = [];
		var tempEventArray:Array<String> = FileSystem.readDirectory('assets/events');
		//
		var futureEvents:Array<String> = [];
		var futureSubEvents:Array<String> = [];
		for (event in tempEventArray)
		{
			if (event.contains('.'))
			{
				event = event.substring(0, event.indexOf('.', 0));
				loadedModules.set(event, ScriptHandler.loadModule('events/$event'));
				futureEvents.push(event);
			}
			else
			{
				if (PlayState.SONG != null && CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()) == event)
				{
					var internalEvents:Array<String> = FileSystem.readDirectory('assets/events/$event');
					for (subEvent in internalEvents)
					{
						subEvent = subEvent.substring(0, subEvent.indexOf('.', 0));
						loadedModules.set(subEvent, ScriptHandler.loadModule('events/$event/$subEvent'));
						futureSubEvents.push(subEvent);
					}
					//
				}
			}
		}
		futureEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
		futureSubEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));

		for (i in futureSubEvents)
			eventList.push(i);
		futureEvents.insert(0, '');
		for (i in futureEvents)
			eventList.push(i);

		futureEvents = [];
		futureSubEvents = [];

		eventList.insert(0, '');
	}

	public static function returnDescription(event:String):String
	{
		if (loadedModules.get(event) != null)
		{
			var module:ForeverModule = loadedModules.get(event);
			if (module.exists('returnDescription'))
				return module.get('returnDescription')();
		}
		return '';
	}
}
