package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class MiniEntity extends Entity
{
    public function new(x:Float, y:Float) {
        super(x, y);
    }

    private function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnWall() {
        return isOnLeftWall() || isOnRightWall();
    }

    private function isOnLeftWall() {
        return collide("walls", x - 1, y) != null;
    }

    private function isOnRightWall() {
        return collide("walls", x + 1, y) != null;
    }

	private function collideAny(collideTypes:Array<String>, collideX:Float, collideY:Float) {
        for(collideType in collideTypes) {
            var collision = collide(collideType, collideX, collideY);
            if(collision != null) {
                return collision;
            }
        }
        return null;
    }

    private function getPlayer() {
        return cast(HXP.scene.getInstance("player"), Player);
    }
}
