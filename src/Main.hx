import format.abc.Data.ABCData;

class MyShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var texture : Sampler2D;

        function fragment() {
            // var pop = texture.get(vec2(-1, -1)).g +
            // texture.get(vec2(0, -1)).g +
            // texture.get(vec2(1, -1)).g +
            // texture.get(vec2(-1, 0)).g +
            // texture.get(vec2(1, 0)).g +
            // texture.get(vec2(-1, 1)).g +
            // texture.get(vec2(0, 1)).g +
            // texture.get(vec2(1, 1)).g;

            // if (pop == 3) {
            //     pixelColor = vec4(1, 1, 1, 1);
            // } else if (pop == 2) {
            //     var val = texture.get(vec2(0, 0)).r;
            //     pixelColor = vec4(val, val, val, val);
            // } else {
            //     pixelColor = vec4(0, 0, 0, 0);
            // }

            // if (pop == 8) {
            //     pixelColor = vec4(1, 0, 0, 1);
            // } else {
            //     pixelColor = vec4(0, 0, 0, 0);
            // }

            // pixelColor = vec4(1, 0, 0, 1);

            // pixelColor = vec4(sin(time / 2), sin(time / 3), sin(time / 5), 1.0);

            pixelColor = texture.get(vec2(calculatedUV.x, calculatedUV.y));
        }
    }
}

class SineDeformShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;
        
        @param var texture : Sampler2D;
        @param var speed : Float;
        @param var frequency : Float;
        @param var amplitude : Float;
        
        function fragment() {
            calculatedUV.y += sin(calculatedUV.y * frequency + time * speed) * amplitude; // wave deform
            pixelColor = texture.get(calculatedUV);
        }
    }
}

typedef Point = {x: Int, y: Int};

class Game {
    var world:Array<Array<h2d.Anim>>;
    var fateBuffer:Array<Array<Int>>;
    
    var cellSize:Int;
    var updateRate:Float;
    var worldDim:Int;
    var s2d:h2d.Scene;

    public function new(s2d:h2d.Scene, worldDim:Int, startingCellPoints:Array<Point>) {
        this.cellSize = 10;
        this.updateRate = 6;
        this.worldDim = worldDim;
        this.s2d = s2d;

        var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        var tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        this.world = [for(i in 0...worldDim) [for(j in 0...worldDim) initCell(tiles, i, j)]];
        this.fateBuffer = [for(i in 0...worldDim) [for(j in 0...worldDim) 0]];

        for (point in startingCellPoints) {
            this.world[point.x][point.y].alpha = 1;
        }
    }

    public function update() {
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

    function initCell(tiles:Array<h2d.Tile>, x:Int, y:Int) {
        var anim = new h2d.Anim(tiles, updateRate, s2d);
        anim.x = x * (cellSize + 1);
        anim.y = y * (cellSize + 1);
        anim.alpha = 0;
        return anim;
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
}

class Main extends hxd.App {
    var worldDim : Int;
    var world : Array<Array<h2d.Anim>>;
    var cellSize : Int;
    var fateBuffer : Array<Array<Int>>;
    var frameRateLabel : h2d.Text;
    var updateRate : Float;
    var elapsedTime : Float;
    var game : Game;

    function initCell(tiles : Array<h2d.Tile>, x : Int, y : Int) {
        var anim = new h2d.Anim(tiles, updateRate, s2d);
        anim.x = x * (cellSize + 1);
        anim.y = y * (cellSize + 1);
        anim.alpha = 0;
        return anim;
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
        // var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        // var tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        // world = [for(i in 0...worldDim) [for(j in 0...worldDim) initCell(tiles, i, j)]];
        // fateBuffer = [for(i in 0...worldDim) [for(j in 0...worldDim) 0]];

        var startingCells = [
            {x:0, y:0},
            {x:2, y:0},
            {x:1, y:1},
            {x:2, y:1},
            {x:1, y:2},
        ];
        game = new Game(s2d, 50, startingCells);

        // drawCreature([[1, 0, 1], [0, 1, 1], [0, 1, 0]], 10, 10);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 10);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 15);
        // drawCreature([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], 10, 20);
            
        frameRateLabel = new h2d.Text(hxd.res.DefaultFont.get(), s2d);

        // var shader = new MyShader();
        // var g = new h2d.Graphics(s2d);

        // var b = new hxd.BitmapData(500, 500);
        // b.clear(0xFFFF0000);
        // for (i in 0...500) {
        //     for (j in 0...500) {
        //         b.setPixel(i, j, 0xFFFF0000);
        //     }
        // }
        // var t = h3d.mat.Texture.fromBitmap(b);
        // b.dispose();
        // var tile = h2d.Tile.fromTexture(t);
        // var bmp = new h2d.Bitmap(tile, s2d);

        // g.beginFill(0x00FF00);
        // g.drawRect(0, 0, 500, 500);
        // g.endFill();

        // g.beginFill(0xFFFFFFFF);

        // g.drawRect(0, 0, 1, 1);
        // g.drawRect(500, 500, 1, 1);
        
        // g.drawRect(0 + 100, 0 + 100, 1, 1);
        // g.drawRect(2 + 100, 0 + 100, 1, 1);
        // g.drawRect(1 + 100, 1 + 100, 1, 1);
        // g.drawRect(2 + 100, 1 + 100, 1, 1);
        // g.drawRect(1 + 100, 2 + 100, 1, 1);
        
        // g.endFill();

        // shader.texture = g.tile.getTexture();
        // g.addShader(shader);

        // hxd.Res.initEmbed();
        // var img = hxd.Res.my_image.toTile();
        // var bmp = new h2d.Bitmap(img, s2d);

        // var shader = new SineDeformShader();
        // shader.speed = 1;
        // shader.amplitude = .1;
        // shader.frequency = .5;

        // shader.texture = bmp.tile.getTexture();
        // bmp.addShader(shader);

        // var tile = h2d.Tile.fromColor(0xFFFFFF, 100, 100);
        // var bmp = new h2d.Bitmap(g.tile, s2d);

        // bmp.x = 100;
        // bmp.y = 100;
        // bmp.addShader(shader);
    }

    override function update(dt : Float) {
        frameRateLabel.text = Std.string(1.0 / dt);
        elapsedTime += dt;
        if (elapsedTime >= 1.0 / updateRate) {
            elapsedTime = 0;
            game.update();
        //     for (i in 0...worldDim) {
        //         for (j in 0...worldDim) {
        //             determineFate(i, j);
        //         }
        //     }
        //     for (i in 0...worldDim) {
        //         for (j in 0...worldDim) {
        //             updateCell(i, j);
        //         }
        //     }
        }
    }

    static function main() {
        new Main();
    }
}