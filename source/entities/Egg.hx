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

class Egg extends Item
{
    public static inline var BREAK_SPEED = 200;

    private var isBlessed:Bool;
    private var pulse:ColorTween;
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        type = "egg";
        mask = new Hitbox(20, 15);
        sprite = new Image("graphics/egg.png");
        graphic = sprite;
        isBlessed = false;
        pulse = new ColorTween(TweenType.PingPong);
        addTween(pulse);
    }

    private function bless() {
        isBlessed = true;
        pulse.tween(0.5, 0xEDF7FA, 0xADD8E6, 0.5, 0.5, Ease.sineInOut);
    }

    override public function update() {
        if(collide("steam", x, y) != null) {
            hatch();
        }
        if(collide("angel", x, y) != null && !isBlessed) {
            bless();
        }
        if(isBlessed) {
            sprite.color = pulse.color;
        }
        super.update();
    }

    private function crack() {
        HXP.scene.remove(this);
        if(Player.carrying == this) {
            getPlayer().destroyCarriedItem();
        }
    }

    private function hatch() {
        var chicken = new Mount(0, 0);
        chicken.moveTo(centerX - chicken.width / 2, bottom - chicken.height);
        HXP.scene.add(chicken);
        crack();
    }

    override public function moveCollideX(e:Entity) {
        if(Math.abs(velocity.x) > BREAK_SPEED) {
            crack();
        }
        return super.moveCollideX(e);
    }

    override public function moveCollideY(e:Entity) {
        if(Math.abs(velocity.y) > BREAK_SPEED) {
            crack();
        }
        return super.moveCollideY(e);
    }
}

