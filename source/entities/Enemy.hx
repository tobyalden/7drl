package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Enemy extends MiniEntity
{
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        mask = new Hitbox(10, 10);
        var sprite = Image.createRect(width, height, 0x32a852);
        sprite.alpha = 0.5;
        graphic = sprite;
        velocity = new Vector2();
    }

    override public function update() {
        var item = collideAny(Item.itemTypes, x, y);
        if(item != null) {
            if(item.type == "mount" && Player.riding == item) {
                // No effect
            }
            else if(type == "angel" || type == "ogre") {
                // No effect
            }
            else if(cast(item, Item).velocity.length > 50) {
                die();
                if(item.type == "egg") {
                    cast(item, Egg).crack();
                }
            }
        }
        super.update();
    }

    private function die() {
        explode(3);
        GameScene.sfx["enemydie"].play();
        HXP.scene.remove(this);
    }

    override public function moveCollideX(e:Entity) {
        if(MiniEntity.semiSolids.contains(e.type)) {
            return false;
        }
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        if(MiniEntity.semiSolids.contains(e.type) && bottom > e.y) {
            return false;
        }
        velocity.y = 0;
        return true;
    }
}

