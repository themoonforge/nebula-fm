extends Node

const SMF = preload( "res://addons/midi/SMF.gd" )
const Utility = preload( "res://addons/midi/Utility.gd" )

@onready var midi_player:MidiPlayer = $GodotMIDIPlayer
var tempo_changing:bool = false
var updating_seek_bar:bool = false
var ui_channels:Array = []

func _ready( ):
	#self._setup_channel_status_viewers( )
	if self.midi_player.connect("midi_event",Callable(self,"_on_midi_event")) != OK:
		print( "error" )
		breakpoint

	# MIDI input test.
	OS.open_midi_inputs( )
	print( OS.get_connected_midi_inputs( ) )
	for current_midi_input in OS.get_connected_midi_inputs( ):
		print(current_midi_input)

#func _setup_channel_status_viewers( ):
#	for i in range( 0, 16 ):
#		var ci = $ChannelIndicators.get_node( str( i ) )
#		ci.midi_player = self.midi_player
#		ci.channel = self.midi_player.channel_status[i]

func _unhandled_input( event:InputEvent ):
	if event is InputEventMIDI:
		self.midi_player.receive_raw_midi_message( event )

func _process( _delta:float ):
	self.midi_player.volume_db = $TopController/Second/VolumeBar.value

	if self.midi_player.playing:
		self._process_update_apply_ui( )

	# Update polyphony status text
	$TopController/First/PolyphonyStatus.text = (
		( "polyphony %d / %d" % [
			self.midi_player.get_now_playing_polyphony( ),
			self.midi_player.max_polyphony
		] )
	)

func _process_update_apply_ui( ):
	# Update some values
	self.midi_player.play_speed = $TopController/Second/PlaySpeedBar.value
	self.midi_player.loop = $TopController/First/Loop.button_pressed

	# Update seek bar
	self.updating_seek_bar = true
	$TopController/Third/SeekBar.min_value = 0
	$TopController/Third/SeekBar.max_value = self.midi_player.last_position
	$TopController/Third/SeekBar.value = self.midi_player.position
	self.updating_seek_bar = false

	# Update tempo line edit
	if not self.tempo_changing:
		$TopController/First/Tempo.text = str( self.midi_player.tempo )

func _on_SeekBar_value_changed( value:float ):
	if not self.updating_seek_bar:
		if not self.midi_player.playing:
			self.midi_player.play( value )
		else:
			self.midi_player.seek( value )

func _on_ui_tempo_focus_entered( ):
	self.tempo_changing = true

func _on_ui_tempo_focus_exited( ):
	self.tempo_changing = false

func _on_ui_tempo_entered( _o:String ):
	var bpm:int = int( $TopController/First/Tempo.text )
	if 0 <= bpm:
		self.midi_player.tempo = bpm

func _on_OpenButton_pressed( ):
	$FileDialog.popup_centered( )

func _on_FileDialog_file_selected( path ):
	self.updating_seek_bar = true
	self.midi_player.stop( )
	self.midi_player.send_reset( )
	self.midi_player.file = path
	$TopController/Second/PlaySpeedBar.value = 1.0
	$TopController/Third/SeekBar.value = 0.0
	self.midi_player.play( 0.0 )
	self.updating_seek_bar = false

func _on_midi_event( channel, event ):
	# channel is same as $GodotMidiPlayer.channel_status[track_id]
	# event is event parameter. see SMF.gd and MidiPlayer.gd
	# 	-> more information at "MIDIEvent" at https://bitbucket.org/arlez80/godot-midi-player/wiki/struct/SMF

	if not $TopController/First/OutputEvent.button_pressed:
		return

	# Output event data to stdout
	var event_string = ""
	match event.type:
		SMF.MIDIEventType.note_off:
			event_string = "NoteOff %d" % event.note
		SMF.MIDIEventType.note_on:
			event_string = "NoteOn note[%d] velocity[%d]" % [ event.note, event.velocity ]
		SMF.MIDIEventType.polyphonic_key_pressure:
			event_string = "PolyphonicKeyPressure note[%d] value[%d]" % [ event.note, event.value ] 
		SMF.MIDIEventType.control_change:
			event_string = "ControlChange number[%d] value[%d]" % [ event.number, event.value ]
		SMF.MIDIEventType.program_change:
			event_string = "ProgramChange #%d" % event.number
		SMF.MIDIEventType.pitch_bend:
			event_string = "PitchBend %d -> %f" % [ event.value, ( event.value / 8192.0 ) - 1.0 ]
		SMF.MIDIEventType.channel_pressure:
			event_string = "ChannelPressure %d" % event.value
		SMF.MIDIEventType.system_event:
			event_string = "SystemEvent %d" % event.args.type

	print( channel, event, "channel:%d event-type:%s" % [
		channel.number,
		event_string,
	])

func _on_Play_pressed( ):
	$GodotMIDIPlayer.play( )

func _on_Stop_pressed():
	$GodotMIDIPlayer.stop( )
