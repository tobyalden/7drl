import haxepunk.*;
import haxepunk.debug.Console;
import haxepunk.input.*;
import haxepunk.input.gamepads.*;
import haxepunk.math.*;
import haxepunk.screen.UniformScaleMode;
import haxepunk.utils.*;
import openfl.Lib;
import scenes.*;


class Main extends Engine
{
    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.fullscreen = false;

        Key.define("up", [Key.W, Key.UP]);
        Key.define("down", [Key.S, Key.DOWN]);
        Key.define("left", [Key.A, Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.D, Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("jump", [Key.Z, Key.SPACE]);
        Key.define("action", [Key.X]);

        if(Gamepad.gamepad(0) != null) {
            defineGamepadInputs(Gamepad.gamepad(0));
        }

        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            defineGamepadInputs(newGamepad);
        });

        //HXP.scene = new GameScene("bedroom");
        //HXP.scene = new GameScene("heaven");
        HXP.scene = new GameScene("earth");
    }

    private function defineGamepadInputs(gamepad) {
        gamepad.defineButton("up", [XboxGamepad.DPAD_UP]);
        gamepad.defineButton("down", [XboxGamepad.DPAD_DOWN]);
        gamepad.defineButton("left", [XboxGamepad.DPAD_LEFT]);
        gamepad.defineButton("right", [XboxGamepad.DPAD_RIGHT]);
        gamepad.defineAxis("up", XboxGamepad.LEFT_ANALOGUE_Y, -0.5, -1);
        gamepad.defineAxis("down", XboxGamepad.LEFT_ANALOGUE_Y, 0.5, 1);
        gamepad.defineAxis("left", XboxGamepad.LEFT_ANALOGUE_X, -0.5, -1);
        gamepad.defineAxis("right", XboxGamepad.LEFT_ANALOGUE_X, 0.5, 1);
        gamepad.defineButton("jump", [XboxGamepad.A_BUTTON]);
        gamepad.defineButton("action", [XboxGamepad.X_BUTTON]);
    }

    override public function popScene():Scene {
        GameScene.dreamDepth -= 1;
        return super.popScene();
    }

    override public function pushScene(value:Scene):Void {
        GameScene.dreamDepth += 1;
        super.pushScene(value);
    }

    override public function update() {
#if desktop
        if(Key.pressed(Key.ESCAPE)) {
            Sys.exit(0);
        }
        if(Key.pressed(Key.F)) {
            HXP.fullscreen = !HXP.fullscreen;
        }
#end
        super.update();
    }
}
