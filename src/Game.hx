import hxd.Rand;

typedef Point = {x: Int, y: Int};

class Game {
    var fateBuffer:Array<Array<Int>>;

    var populationMap:Map<Int, Map<Int, Array<Int>>>;
    var cellCache:Array<h2d.Anim>;
    
    var tiles:Array<h2d.Tile>;
    var cellSize:Int;
    var updateRate:Float;
    var worldDim:Int;
    var s2d:h2d.Scene;

    public function new(s2d:h2d.Scene, worldDim:Int, startingCellPoints:Array<Point>) {
        populationMap = new Map();
        cellCache = [];

        cellSize = 5;
        updateRate = 6;
        this.worldDim = worldDim;
        this.s2d = s2d;

        var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        fateBuffer = [for(i in 0...worldDim) [for(j in 0...worldDim) 0]];

        for (point in startingCellPoints) {
            cellCache.push(initCell(point.x, point.y));
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

    function updatePopulation() {
        populationMap.clear();
        for (cell in cellCache) {
            var x = Std.int(cell.x / (cellSize + 1));
            var y = Std.int(cell.y / (cellSize + 1));
            for (i in [-1, 0, 1]) {
                for (j in [-1, 0, 1]) {
                    if (0 <= x + i && x + i < worldDim) {
                        if (0 <= y + j && y + j < worldDim) {
                            if (populationMap.get(x + i) == null) {
                                populationMap[x + i] = new Map();
                            }
                            if (populationMap[x + i].get(y + j) == null) {
                                populationMap[x + i][y + j] = [0, 0]; // {alive: 0, population: 0};
                            }
                            if (i == 0 && j == 0) {
                                populationMap[x + i][y + j][0] = 1;
                            } else {
                                populationMap[x + i][y + j][1] += 1;
                            }
                        }
                    }
                }
            }
        }
    }

    function updateAlive() {
        var cellCount = 0;
        for (x in populationMap.keys()) {
            for (y in populationMap[x].keys()) {
                var alive = switch populationMap[x][y] {
                    case [_, 3]: true;
                    case [1, 2]: true;
                    case _: false;
                }
                if (alive) {
                    if (cellCount > cellCache.length) {
                        cellCache.push(initCell(x, y));
                    } else {
                        var cell = cellCache[cellCount];
                        cell.x = x * (cellSize + 1);
                        cell.y = y * (cellSize + 1);
                    }
                    cellCount += 1;
                }
            }
        }
    }
}