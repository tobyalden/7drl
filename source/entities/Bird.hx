package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Bird extends Enemy
{
    public static inline var HORIZONTAL_SPEED = 75;

    private var sprite:Spritemap;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -5;
        type = "hazard";
        sprite = new Spritemap("graphics/bird.png", 15, 15);
        sprite.add("idle", [0, 1, 2, 3], 8);
        sprite.play("idle");
        graphic = sprite;
        mask = new Hitbox(15, 15);
    }

    override public function update() {
        moveBy(-HORIZONTAL_SPEED * HXP.elapsed, 0);
        if(right < HXP.scene.camera.x) {
            HXP.scene.remove(this);
        }
        super.update();
    }
}



