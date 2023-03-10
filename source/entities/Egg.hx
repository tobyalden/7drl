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
    public static inline var BREAK_SPEED = 50;
    public static inline var BROODING_TIME_TO_HATCH = 5;

    private var isBlessed:Bool;
    private var pulse:ColorTween;
    private var sprite:Image;
    private var broodingTime:Float;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        type = "egg";
        mask = new Hitbox(20, 15);
        sprite = new Image("graphics/egg.png");
        graphic = sprite;
        isBlessed = false;
        pulse = new ColorTween(TweenType.PingPong);
        addTween(pulse);
        broodingTime = 0;

        //bless(); // TODO: for testing
    }

    private function bless() {
        if(!isBlessed) {
            GameScene.sfx["bless"].play();
        }
        pulse.tween(0.5, 0xEDF7FA, 0xADD8E6, 0.5, 0.5, Ease.sineInOut);
        isBlessed = true;
    }

    override public function update() {
        if(collide("nest", x, y) != null) {
            var collidedMount = collide("mount", x, y);
            if(collide("steam", x, y) != null) {
                hatch();
            }
            else if(collidedMount != null) {
                if(!cast(collidedMount, Mount).isDragon) {
                    broodingTime += HXP.elapsed;
                    if(broodingTime > BROODING_TIME_TO_HATCH) {
                        hatch();
                    }
                }
            }
            else {
                broodingTime = 0;
            }
        }
        var water = collide("water", x, y);
        if(water != null && cast(water, Water).isBlessed && !isBlessed) {
            bless();
        }
        if(isBlessed) {
            sprite.color = pulse.color;
        }
        super.update();
    }

    public function crack() {
        HXP.scene.remove(this);
        explode(10);
        GameScene.sfx["shatter"].play();
        if(Player.carrying == this) {
            getPlayer().destroyCarriedItem();
        }
    }

    private function hatch() {
        if(!isOnGround() || Player.carrying == this) {
            return;
        }
        var newborn = new Mount(0, 0, isBlessed);
        newborn.moveTo(centerX - newborn.width / 2, bottom - newborn.height);
        HXP.scene.add(newborn);
        if(isBlessed) {
            GameScene.sfx["dragonhatch"].play();
        }
        else {
            GameScene.sfx["chicken_alert"].play();
        }
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

