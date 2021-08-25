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
// typedef Cell = {alive: Int, population: Int};

class Game {
    var world:Array<Array<h2d.Anim>>;
    var fateBuffer:Array<Array<Int>>;

    var aliveMap:Map<Int, Map<Int, Int>>;
    var populationMap:Map<Int, Map<Int, Array<Int>>>;
    
    var cellSize:Int;
    var updateRate:Float;
    var worldDim:Int;
    var s2d:h2d.Scene;

    public function new(s2d:h2d.Scene, worldDim:Int, startingCellPoints:Array<Point>) {
        aliveMap = new Map();
        populationMap = new Map();

        cellSize = 5;
        updateRate = 6;
        this.worldDim = worldDim;
        this.s2d = s2d;

        var colors = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF];
        var tiles = [for (color in colors) h2d.Tile.fromColor(color, cellSize, cellSize)];

        world = [for(i in 0...worldDim) [for(j in 0...worldDim) initCell(tiles, i, j)]];
        fateBuffer = [for(i in 0...worldDim) [for(j in 0...worldDim) 0]];

        for (point in startingCellPoints) {
            world[point.x][point.y].alpha = 1;
            if (aliveMap.get(point.x) == null) {
                aliveMap[point.x] = new Map();
            }
            aliveMap[point.x][point.y] = 1;
        }
    }

    public function update() {
        updatePopulation();
        updateAlive();
    }

    function initCell(tiles:Array<h2d.Tile>, x:Int, y:Int) {
        var anim = new h2d.Anim(tiles, updateRate, s2d);
        anim.x = x * (cellSize + 1);
        anim.y = y * (cellSize + 1);
        anim.alpha = 0;
        return anim;
    }

    function updatePopulation() {
        populationMap.clear();
        for (x in aliveMap.keys()) {
            for (y in aliveMap[x].keys()) {
                world[x][y].alpha = 0;
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
    }

    function updateAlive() {
        aliveMap.clear();
        for (x in populationMap.keys()) {
            for (y in populationMap[x].keys()) {
                var alive = switch populationMap[x][y] {
                    case [_, 3]: true;
                    case [1, 2]: true;
                    case _: false;
                }
                if (alive) {
                    if (aliveMap.get(x) == null) {
                        aliveMap[x] = new Map();
                    }
                    aliveMap[x][y] = 1;
                    world[x][y].alpha = 1;
                }
            }
        }
    }
}

class Main extends hxd.App {
    var frameRateLabel : h2d.Text;
    var updateRate : Float;
    var elapsedTime : Float;
    var game : Game;

    override function init() {
        updateRate = 12;
        elapsedTime = 0;

        var startingCells = [
            {x:0, y:0},
            {x:2, y:0},
            {x:1, y:1},
            {x:2, y:1},
            {x:1, y:2},
        ];
        game = new Game(s2d, 500, startingCells);
            
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
        }
    }

    static function main() {
        new Main();
    }
}