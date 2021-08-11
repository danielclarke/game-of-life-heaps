class Main extends hxd.App {
    var worldDim : Int;
    var world : Array<Array<h2d.Anim>>;
    var cellSize : Int;
    var fateBuffer : Array<Array<Int>>;
    var frameRateLabel : h2d.Text;
    var updateRate : Float;
    var elapsedTime : Float;

    function initCell(tiles : Array<h2d.Tile>, x : Int, y : Int) {
        var anim = new h2d.Anim(tiles, updateRate, s2d);
        anim.x = x * (cellSize + 1);
        anim.y = y * (cellSize + 1);
        anim.alpha = 0;
        world[x][y] = anim;
    }

    function drawCreature(creature: Array<Array<Int>>, x, y) {
        for (i in 0...creature.length) {
            for (j in 0...creature[i].length) {
                if (creature[i][j] == 1) {
                    world[x + i][y + j].alpha = 1;
                }
            }
        }
    }

    function determineFate(x : Int, y : Int) {
        var alive = Std.int(world[x][y].alpha);
        var population = -alive;

        for (i in [-1, 0, 1]) {
            for (j in [-1, 0, 1]) {
                if (0 <= x + i && x + i < worldDim) {
                    if (0 <= y + j && y + j < worldDim) {
                        population += Std.int(world[x + i][y + j].alpha);
                    }
                }
            }
        }

        fateBuffer[x][y] = switch [alive, population] {
            case [_, 3]: 1;
            case [1, 2]: 1;
            case _: 0;
        }
    }

    function updateCell(x : Int, y : Int) {
        world[x][y].alpha = fateBuffer[x][y];
    }

    override function init() {
        updateRate = 6;
        worldDim = 50;
        elapsedTime = 0;
        cellSize = 10;
        var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        var tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        world = [for(i in 0...worldDim) [for(j in 0...worldDim) null]];
        fateBuffer = [for(i in 0...worldDim) [for(j in 0...worldDim) 0]];

        for (i in 0...worldDim) {
            for (j in 0...worldDim) {
                initCell(tiles, i, j);
            }
        }

        drawCreature([[1, 0, 1], [0, 1, 1], [0, 1, 0]], 10, 10);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 10);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 15);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 20);
            
        frameRateLabel = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
    }

    override function update(dt : Float) {
        frameRateLabel.text = Std.string(1.0 / dt);
        elapsedTime += dt;
        if (elapsedTime >= 1.0 / updateRate) {
            elapsedTime = 0;
            for (i in 0...worldDim) {
                for (j in 0...worldDim) {
                    determineFate(i, j);
                }
            }
            for (i in 0...worldDim) {
                for (j in 0...worldDim) {
                    updateCell(i, j);
                }
            }
        }
    }

    static function main() {
        new Main();
    }
}