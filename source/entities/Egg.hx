package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Egg extends Item
{
    public static inline var BREAK_SPEED = 100;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        type = "egg";
        mask = new Hitbox(20, 15);
        graphic = new Image("graphics/egg.png");
    }

    override public function update() {
        if(collide("steam", x, y) != null) {
            hatch();
        }
        super.update();
    }

    private function crack() {
        HXP.scene.remove(this);
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

