package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class Victory extends Scene
{
    override public function begin() {
        var text = new Text('VICTORY!\n\nTOTAL TIME:\n  ${timeRound(GameScene.totalTime, 2)} sec');
        text.x = GameScene.GAME_WIDTH / 2 - text.width / 2;
        text.y = GameScene.GAME_HEIGHT / 2 - text.height / 2;
        addGraphic(text);
    }

    override public function update() {
        super.update();
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.floor(number) / Math.pow(10, precision);
    }
}
