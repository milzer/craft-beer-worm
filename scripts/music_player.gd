extends AudioStreamPlayer

@export var music_files: Array[AudioStream] = []

var playlist: Array[int]
var last_played_index: int = -1

func _ready():
    if len(music_files) == 0:
        print('No music files specified')
    else:
        # shuffle the songs starting from second
        if len(music_files) > 1:
            for i in range(1, len(music_files)):
                playlist.append(i)
            playlist.shuffle()
        # always start with the first defined song
        playlist.push_front(0)
        play_next()

func play_next():
    last_played_index = playlist.pop_front()
    stream = music_files[last_played_index]
    play()

    if len(playlist) == 0:
        for i in range(0, len(music_files)):
            playlist.append(i)

        if len(playlist) > 2:
            playlist.shuffle()
            # prevent same song from being played twice in a row
            if playlist[0] == last_played_index:
                playlist.push_back(playlist.pop_front())

func _on_finished() -> void:
    await get_tree().create_timer(1.0).timeout
    play_next()
