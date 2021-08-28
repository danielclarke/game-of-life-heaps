import hxd.Rand;
import Game;

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

class Main extends hxd.App {
    var frameRateLabel : h2d.Text;
    var updateRate : Float;
    var elapsedTime : Float;
    var game : Game;

    override function init() {
        updateRate = 24;
        elapsedTime = 0;

        // var startingCells = [
        //     {x:0, y:0},
        //     {x:2, y:0},
        //     {x:1, y:1},
        //     {x:2, y:1},
        //     {x:1, y:2},
        // ];

        var date = Date.now();
        var rand = new Rand(date.getFullYear() + date.getMonth() + date.getDate() + date.getHours() + date.getMinutes() + date.getSeconds());

        var spread = 100;
        var everyCoord = [for (x in 0...spread) for (y in 0...spread) {x: x + 150, y: y + 75}];

        rand.shuffle(everyCoord);
        var startingCells = everyCoord.slice(0, 500);
        game = new Game(s2d, startingCells);
            
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