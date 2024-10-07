extends Node2D
class_name SoundManager

static var SOUND_MANAGER: SoundManager = null

const VOL_CHANGE_RATE = 0.2

class VolumeRequest:
	var track_name: String
	var target_volume: float

@onready var soundtrack_players = {
	"strum": $soundtrack_strum, 
	"pluck": $soundtrack_pluck, 
	"chuck": $soundtrack_chuck, 
	"viola": $soundtrack_viola, 
	"flute": $soundtrack_flute, 
	"bells": $soundtrack_bells,
	"crickets": null, 
	"roadnoise": null, 
	"frogs": null, 
	"river": null, 
	"radio": null
}

var looping_tracks: Array[VolumeRequest] = []
var buffered_requests: Array[VolumeRequest] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("sound manager")
	
	SOUND_MANAGER = self
	
	for k in soundtrack_players.keys():
		if soundtrack_players[k] != null:
			var _r = VolumeRequest.new()
			_r.track_name = k
			_r.target_volume = soundtrack_players[k].volume_db
			looping_tracks.append(_r)
			
	#print("% looping tracks" % looping_tracks.size())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bufferlog = ""
	
	for _i in range(buffered_requests.size()-1, -1, -1):
		var _tt = looping_tracks.filter(func(__t): return __t.track_name == buffered_requests[_i].track_name)
		var track:VolumeRequest = null if _tt == null or _tt.size() < 1 else _tt[0]
		
		if track != null:
			#track.target_volume = get_request_vol(looping_tracks[_i].track_name)
			track.target_volume = buffered_requests[_i].target_volume
			var player = soundtrack_players[track.track_name]
			player.volume_db = move_float(player.volume_db, track.target_volume, VOL_CHANGE_RATE)
			
			bufferlog += "{n}({c}) -> {v}\t".format({
				"n":buffered_requests[_i].track_name,
				"c":player.volume_db,
				"v":buffered_requests[_i].target_volume})
			
			if abs(player.volume_db - track.target_volume) < 2:
				buffered_requests.remove_at(_i)
	
	if bufferlog.length() > 0: print(bufferlog)
	
	#for track in looping_tracks:
		#track.target_volume = get_request_vol(track.track_name)
		#var player = soundtrack_players[track.track_name]
		#player.volume_db = move_float(player.volume_db, track.target_volume, VOL_CHANGE_RATE)
		#
		#if player.volume_db == track.target_volume:
			#buffered_requests.remove_at(buffered_requests.find(track))
		#print(player.volume_db)

func get_request_vol(track_name:String) -> float:
	var _rr = buffered_requests.filter(func(__r): return __r.track_name == track_name)
	if _rr.size() <= 0: return soundtrack_players[track_name].volume_db
	
	var _vol = 0
	for _r in _rr:
		_vol += _r.target_volume
	
	_vol /= _rr.size()
	return _vol

func move_float(from:float, to:float, delta:float) -> float:
	var _s = sign(to-from)
	var _d = abs(to-from)
	_d = min(_d, delta)
	return from + (_s * _d)

func change_soundtrack_volume(track_name:String, volume:float):
	if soundtrack_players.has(track_name) and soundtrack_players[track_name] != null:
		if abs(soundtrack_players[track_name].volume_db - volume) < 2:
			return
		
		var _vol = volume
		var _c = 1
		
		for _i in range(buffered_requests.size()-1, -1, -1):
			if(buffered_requests[_i].track_name == track_name):
				_vol += buffered_requests[_i].target_volume
				buffered_requests.remove_at(_i)
				_c += 1
		
		_vol /= _c
		
		var _r = VolumeRequest.new()
		_r.track_name = track_name
		_r.target_volume = _vol
		buffered_requests.append(_r)
		#print("Filed soundtrack({t}) volume change request({v}). buffersize: {b}".format(
		#	{"t":track_name, "v":volume, "b":buffered_requests.size()}))
		
