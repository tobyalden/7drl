package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Steam extends MiniEntity
{
    public static inline var RISE_SPEED = 50;
    public static inline var LIFT_POWER = 600;
    public static inline var LIFE_TIME = 3;

    private var velocity:Vector2;
    private var lifeSpan:Alarm;
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -30;
        type = "steam";
        mask = new Hitbox(20, 15);
        sprite = Image.createRect(width, height, 0x0000FF);
        graphic = sprite;
        velocity = new Vector2(0, -RISE_SPEED);
        lifeSpan = new Alarm(LIFE_TIME, function() {
            HXP.scene.remove(this);
        });
        addTween(lifeSpan, true);
    }

    override public function update() {
        sprite.alpha = 1 - lifeSpan.percent;
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed
        );
        super.update();
    }
}
