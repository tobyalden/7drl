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
    public static var semiSolids = ["pot", "bed"];
    public static var hazards = ["lava", "enemy", "angel", "hazard"];

    public function new(x:Float, y:Float) {
        super(x, y);
    }

    private function isOnGround() {
        return collideAny(["walls"], x, y + 1) != null;
    }

    private function isOnGroundOrSemiSolid() {
        return collideAny(["walls"].concat(MiniEntity.semiSolids), x, y + 1) != null;
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

    private function getScene() {
        return cast(HXP.scene, GameScene);
    }

    private function preventBacktracking() {
        if(getScene().zone == "lair") {
            clampHorizontal(0, GameScene.GAME_WIDTH);
            clampVertical(getPlayer().height, GameScene.GAME_HEIGHT);
        }
        else if(getScene().zone == "heaven") {
            x = Math.max(x, HXP.scene.camera.x);
            y = Math.max(y, HXP.scene.camera.y);
        }
        else {
            x = Math.max(x, HXP.scene.camera.x);
        }
    }
}
