package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

typedef BulletOptions = {
    @:optional var width:Int;
    @:optional var height:Int;
    @:optional var radius:Int;
    var angle:Float;
    var speed:Float;
    @:optional var shotByPlayer:Bool;
    @:optional var collidesWithWalls:Bool;
    @:optional var bulletType:String;
    @:optional var callback:Bullet->Void;
    @:optional var callbackDelay:Float;
    @:optional var color:Int;
    @:optional var gravity:Float;
    @:optional var accel:Float;
    @:optional var tracking:Float;
    @:optional var duration:Float;
    @:optional var isSword:Bool;
}

class Bullet extends MiniEntity
{
    public var velocity:Vector2;
    public var sprite:Image;
    public var angle:Float;
    public var speed:Float;
    public var gravity:Float;
    public var accel:Float;
    public var tracking:Float;
    public var duration:Float;
    public var isSword:Bool;
    // Wait... i should just be checking the bullet options instead of creating redundant variables
    public var bulletOptions:BulletOptions;

    public function new(x:Float, y:Float, bulletOptions:BulletOptions) {
        bulletOptions.shotByPlayer = (
            bulletOptions.shotByPlayer == null ? false : bulletOptions.shotByPlayer
        );
        bulletOptions.collidesWithWalls = (
            bulletOptions.collidesWithWalls == null ? false : bulletOptions.collidesWithWalls
        );
        if(bulletOptions.shotByPlayer) {
            super(x - bulletOptions.width / 2, y - bulletOptions.height / 2);
        }
        else {
            super(x - bulletOptions.radius, y - bulletOptions.radius);
        }
        this.bulletOptions = bulletOptions;
        this.angle = bulletOptions.angle - Math.PI / 2;
        this.speed = bulletOptions.speed;
        var color = bulletOptions.color == null ? 0xFFFFFF : bulletOptions.color;
        gravity = bulletOptions.gravity == null ? 0 : bulletOptions.gravity;
        accel = bulletOptions.accel == null ? 0 : bulletOptions.accel;
        tracking = bulletOptions.tracking == null ? 0 : bulletOptions.tracking;
        duration = bulletOptions.duration == null ? 999 : bulletOptions.duration;
        isSword = bulletOptions.isSword == null ? false : bulletOptions.isSword;
        type = bulletOptions.shotByPlayer ? "playerbullet" : "hazard";
        if(isSword) {
            type = "playersword";
        }
        if(bulletOptions.shotByPlayer) {
            mask = new Hitbox(bulletOptions.width, bulletOptions.height);
            sprite = Image.createRect(width, height, color);
        }
        else {
            mask = new Circle(bulletOptions.radius);
            sprite = Image.createCircle(bulletOptions.radius, color);
        }
        graphic = sprite;
        velocity = new Vector2();
        var callbackDelay = (
            bulletOptions.callbackDelay == null ? 0 : bulletOptions.callbackDelay
        );
        if(bulletOptions.callback != null) {
            addTween(new Alarm(callbackDelay, function() {
                bulletOptions.callback(this);
            }), true);
        }
        velocity.x = Math.cos(angle);
        velocity.y = Math.sin(angle);
        velocity.normalize(speed);
    }

    override public function moveCollideX(_:Entity) {
        onCollision();
        return true;
    }

    override public function moveCollideY(_:Entity) {
        onCollision();
        return true;
    }

    private function onCollision() {
        scene.remove(this);
    }

    override public function update() {
        duration -= HXP.elapsed;
        if(duration <= 0) {
            HXP.scene.remove(this);
        }
        velocity.y += gravity * HXP.elapsed;
        velocity.normalize(velocity.length + accel * HXP.elapsed);
        if(tracking > 0) {
            var towardsPlayer = new Vector2(getPlayer().centerX - centerX, getPlayer().centerY - centerY);
            towardsPlayer.normalize(tracking * HXP.elapsed);
            var speed = velocity.length;
            velocity.add(towardsPlayer);
            velocity.normalize(speed);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        if(bulletOptions.shotByPlayer) {
            var boss = collide("boss", x, y);
            if(boss != null) {
                // could use this if i wanted to
            }
        }
        if(!collideRect(
            x, y, scene.camera.x, scene.camera.y, GameScene.GAME_WIDTH, GameScene.GAME_HEIGHT)
        ) {
            scene.remove(this);
        }
        super.update();
    }
}

