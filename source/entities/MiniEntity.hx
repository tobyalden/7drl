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
    public static inline var OFFSCREEN_UNLOAD_BUFFER = 0;

    public static var semiSolids = ["pot", "bed"];
    public static var hazards = ["lava", "enemy", "angel", "hazard", "ogre"];

    public function new(x:Float, y:Float) {
        super(x, y);
    }

    override public function update() {
        if(right < HXP.scene.camera.x - OFFSCREEN_UNLOAD_BUFFER) {
            trace("removing offscreen entity");
            HXP.scene.remove(this);
        }
        super.update();
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

    private function isOnScreen() {
        return right > HXP.scene.camera.x && x < (HXP.scene.camera.x + GameScene.GAME_WIDTH);
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

    private function explode(numExplosions:Int = 50) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Random.random);
            direction.normalize(
                Math.max(0.1 + 0.2 * Random.random, direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        //Sys.sleep(0.02);
#end
        //scene.camera.shake(1, 4);
    }
}
