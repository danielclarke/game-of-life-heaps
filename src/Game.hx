typedef Point = {x: Int, y: Int};

class Game {

    var populationMap:Map<String, Array<Int>>;
    var aliveCells:Array<Point>;
    var cellCache:Array<h2d.Anim>;
    
    var worldDim:Null<Int>;
    var tiles:Array<h2d.Tile>;
    var cellSize:Int;
    var updateRate:Float;
    var s2d:h2d.Scene;

    public function new(s2d:h2d.Scene, startingCellPoints:Array<Point>, ?worldDim:Int) {
        populationMap = new Map();
        cellCache = [];
        aliveCells = [];

        this.worldDim = worldDim;
        cellSize = 2;
        updateRate = 6;
        this.s2d = s2d;

        var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        for (point in startingCellPoints) {
            cellCache.push(initCell(point.x, point.y));
            aliveCells.push(point);
        }
    }

    public function update() {
        updatePopulation();
        updateAlive();
    }

    function initCell(x:Int, y:Int) {
        var anim = new h2d.Anim(tiles, updateRate, s2d);
        anim.x = x * (cellSize + 1);
        anim.y = y * (cellSize + 1);
        anim.alpha = 1;
        return anim;
    }

    function getKey(x: Int, y: Int) {
        return '$x, $y';
    }

    function getCoord(i: Int) {
        if (worldDim != null) {
            if (i < 0) {
                i += worldDim;
            }
            if (i > worldDim) {
                i -= worldDim;
            }
        }
        return i;
    }

    function updatePopulation() {
        populationMap.clear();
        for (cell in aliveCells) {
            var x = cell.x;
            var y = cell.y;
            for (i in [-1, 0, 1]) {
                for (j in [-1, 0, 1]) {
                    var u = getCoord(x + i);
                    var v = getCoord(y + j);
                    var key = getKey(u, v);
                    if (populationMap[key] == null) {
                        populationMap[key] = [0, 0, u, v]; // {alive: 0, population: 0, x: u, y: v};
                    }
                    if (i == 0 && j == 0) {
                        populationMap[key][0] = 1;
                    } else {
                        populationMap[key][1] += 1;
                    }
                }
            }
        }
    }

    function updateAlive() {
        var cellCount = 0;
        aliveCells = [];
        for (d in populationMap) {
            var alive = switch d {
                case [_, 3, _, _]: true;
                case [1, 2, _, _]: true;
                case _: false;
            }
            if (alive) {
                var x = d[2];
                var y = d[3];
                if (cellCount >= cellCache.length) {
                    cellCache.push(initCell(x, y));
                } else {
                    var cell = cellCache[cellCount];
                    cell.x = x * (cellSize + 1);
                    cell.y = y * (cellSize + 1);
                    cell.alpha = 1;
                }
                aliveCells.push({x: x, y: y});
                cellCount += 1;
            }
        }
        for (i in cellCount + 1 ... cellCache.length) {
            cellCache[i].alpha = 0;
        }
    }
}