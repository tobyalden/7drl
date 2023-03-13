package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Sword extends Item
{
    public var isCursed(default, null):Bool;
    private var pulse:ColorTween;
    private var sprite:Spritemap;

    public function new(x:Float, y:Float, startCursed:Bool) {
        super(x, y - 5);
        isCursed = startCursed;
        type = "sword";
        mask = new Hitbox(15, 20);
        sprite = new Spritemap("graphics/sword.png", 15, 20);
        sprite.add("uncursed", [0]);
        sprite.add("cursed", [1]);
        sprite.play(isCursed ? "cursed" : "uncursed");
        graphic = sprite;
        pulse = new ColorTween(TweenType.PingPong);
        addTween(pulse);

        //bless(); // TODO: for testing
    }

    private function bless() {
        GameScene.sfx["bless"].play();
        isCursed = false;
        pulse.tween(0.5, 0xEDF7FA, 0xADD8E6, 0.5, 0.5, Ease.sineInOut);
    }

    override public function update() {
        var water = collide("water", x, y);
        if(water != null && cast(water, Water).isBlessed && isCursed) {
            bless();
        }
        sprite.play(isCursed ? "cursed" : "uncursed");
        super.update();
    }
}
