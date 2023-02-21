extends ColorRect

# A list of lists of PoolVector2Arrays. Holds the sets of lines of all the turns.
var allLines = []
# A list of PoolVector2Arrays. Holds the lines for the current turn
var lines = []

#var drawColor = Color(0, 0, 0)
var width = 1.0
var antialiased = true
var fade_rate = .1 # 1 / turns_visible

var players = ['Player 1', 'Player 2']
var playerColors = [Color(), Color()]
var turn = 0

var _dragging = false
#var _gradient = Gradient.new()
var _player = '../../StartupMenu/VBoxContainer/Player%d/'

# The additional drawing in the back (like a bridge)
var background = null
var _background_width = 1.0
var _background_color = Color(0, 0, 0)

func _ready():
    pass
#    _gradient.colors = PoolColorArray([drawColor, self.color])

func _lines2json(all_lines):
    Cope.todo('lines2json()')
    
func _json2lines(json):
    var rtn = []
    for lines in json:
        var line = []
        for point in lines:
            line.append(Vector2(point[0], point[1]))
        rtn.append(line)
    return rtn

func _draw():
    # Draw the background first
    if background:
        for i in background:
            draw_polyline(i, _background_color, _background_width, antialiased)

    # Draw all the lines for all the turns
    for turns in allLines.size():
        for line in allLines[turns]:
            # draw_polyline(line, _gradient.interpolate((allLines.size() - turns) * fade_rate), width, antialiased)
            var c = playerColors[turns % 2]
            c.a = 1 - ((allLines.size() - turns) * fade_rate)
            draw_polyline(line, c, width, antialiased)
            
    # Draw the lines for the current turn
    for line in lines:
        draw_polyline(line, playerColors[turn], width, antialiased)

func _process(_delta):
    update()
    
func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
        _dragging = event.pressed
        if event.pressed:
            # Before we make a new one, check if the last one is too small
            if len(lines) and len(lines.back()) < 2:
                lines.pop_back()
            lines.append(PoolVector2Array())
            
    if event is InputEventMouseMotion and _dragging:
#		WHAT THE HECK IS THIS???
#		lines[-1].append(event.position)
        var v = lines.pop_back()
        v.append(event.position)
        lines.append(v)
    
    # For debugging
    if event.is_action_pressed("Undo"):
        self.lines.pop_back()

func submitted():
    # Add the lines for this turn
    self.allLines.append(self.lines)
    self.lines = []
    # Update the turn label
    turn = int(not bool(turn))
    get_node('../../PlayerLabel').text = players[turn] + "'s turn"

func setPlayers():
    players = [get_node(_player % 1 + 'Name').text, get_node(_player % 2 + 'Name').text]
    playerColors = [get_node(_player % 1 + 'Color').color, get_node(_player % 2 + 'Color').color]
    # Set the appropriate defaults
    if players[0] == '':
        players[0] = 'Destroyer'
    if players[1] == '':
        players[1] = 'Defender'
    get_node('../../PlayerLabel').text = players[turn] + "'s turn"

    if get_node('../../StartupMenu/VBoxContainer/HBoxContainer/Bridge').pressed:
        self.background = _json2lines(Cope.getJSON('res://bridge.json'))

func eraseAllLines(index):
    self.allLines = []
    self.lines = []
    self.background = null
    get_node('../../StartupMenu').popup_centered()
