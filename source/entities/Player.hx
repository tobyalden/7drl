package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends MiniEntity
{
    public static inline var MAX_RUN_SPEED = 100;
    public static inline var MAX_AIR_SPEED = 150;
    public static inline var RUN_ACCEL = 1300;
    public static inline var AIR_ACCEL = 800;
    public static inline var GRAVITY = 800;
    public static inline var JUMP_POWER = 300;
    public static inline var JUMP_CANCEL = 50;
    public static inline var MAX_FALL_SPEED = 400;
    public static inline var COYOTE_TIME = 1 / 60 * 5;
    public static inline var JUMP_BUFFER_TIME = 1 / 60 * 5;
    public static inline var TOSS_VELOCITY_X = 150;
    public static inline var TOSS_VELOCITY_Y = 150;
    public static inline var DETACH_DISTANCE = 10;
    public static inline var RIDE_COOLDOWN = 0.5;

    public var carrying(default, null):Item;
    public var riding(default, null):Mount;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var timeOffGround:Float;
    private var timeJumpHeld:Float;
    private var rideCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        carrying = null;
        riding = null;
        name = "player";
        mask = new Hitbox(10, 15);
        sprite = new Spritemap("graphics/player.png", 10, 15);
        sprite.add("idle", [0]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2();
        timeOffGround = 0;
        timeJumpHeld = 0;
        rideCooldown = new Alarm(RIDE_COOLDOWN);
        addTween(rideCooldown);
    }

    override public function update() {
        if(Input.pressed("action")) {
            if(carrying != null) {
                if(Input.check("down")) {
                    carrying.moveTo(
                        sprite.flipX ? x - carrying.width : right,
                        top,
                        ["walls"]
                    );
                }
                else {
                    var tossInfluence = riding != null ? riding.velocity : velocity;
                    var tossVelocity = new Vector2(
                        TOSS_VELOCITY_X * (sprite.flipX ? -1 : 1) + tossInfluence.x / 2,
                        -TOSS_VELOCITY_Y + tossInfluence.y / 2
                    );
                    tossVelocity.scale(1 / carrying.weightModifier);
                    carrying.toss(tossVelocity.x, tossVelocity.y);
                    if(carrying.type == "mount") {
                        rideCooldown.start();
                    }
                }
                carrying = null;
            }
            else if(riding == null) {
                // You can't pick up items while riding
                var item = collide("item", x, y);
                if(item != null) {
                    carrying = cast(item, Item);
                }
                else {
                    item = collide("mount", x, y);
                    if(item != null) {
                        carrying = cast(item, Item);
                    }
                }
            }
        }
        if(riding == null) {
            movement();
        }
        collisions();
        animation();
        if(carrying != null) {
            carrying.moveTo(
                centerX - carrying.width / 2,
                y - carrying.height,
                ["walls"]
            );
            if(distanceFrom(carrying, true) > DETACH_DISTANCE) {
                carrying = null;
            }
        }
        super.update();
    }

    public function stopRiding() {
        riding = null;
        rideCooldown.start();
        velocity.y = -JUMP_POWER;
    }

    private function movement() {
        if(isOnGround()) {
            timeOffGround = 0;
            if(Input.check("left") && !isOnLeftWall()) {
                velocity.x -= RUN_ACCEL * HXP.elapsed;
            }
            else if(Input.check("right") && !isOnRightWall()) {
                velocity.x += RUN_ACCEL * HXP.elapsed;
            }
            else {
                velocity.x = MathUtil.approach(
                    velocity.x, 0, RUN_ACCEL * HXP.elapsed
                );
            }
        }
        else {
            timeOffGround += HXP.elapsed;
            if(Input.check("left") && !isOnLeftWall()) {
                velocity.x -= AIR_ACCEL * HXP.elapsed;
            }
            else if(Input.check("right") && !isOnRightWall()) {
                velocity.x += AIR_ACCEL * HXP.elapsed;
            }
            else {
                velocity.x = MathUtil.approach(
                    velocity.x, 0, AIR_ACCEL * HXP.elapsed
                );
            }
        }

        var maxSpeed = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            velocity.y = 0;
        }
        else {
            if(Input.released("jump") && velocity.y < -JUMP_CANCEL) {
                velocity.y = -JUMP_CANCEL;
            }
        }

        if(isOnGround() || timeOffGround <= COYOTE_TIME) {
            if(
                Input.pressed("jump")
                || Input.check("jump") && timeJumpHeld <= JUMP_BUFFER_TIME
            ) {
                velocity.y = -JUMP_POWER;
            }
        }

        var gravity:Float = GRAVITY;
        if(Math.abs(velocity.y) < JUMP_CANCEL) {
            gravity *= 0.5;
        }
        velocity.y += gravity * HXP.elapsed;

        velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);

        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"]
        );
        x = Math.max(x, HXP.scene.camera.x);

        if(Input.check("jump")) {
            timeJumpHeld += HXP.elapsed;
        }
        else {
            timeJumpHeld = 0;
        }
    }

    private function collisions() {
        var mount = collide("mount", x, y);
        if(
            mount != null
            && bottom < mount.centerY
            && velocity.y > 0
            && !rideCooldown.active
            && carrying != mount
        ) {
            riding = cast(mount, Mount);
        }
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(Input.check("left")) {
            sprite.flipX = true;
        }
        else if(Input.check("right")) {
            sprite.flipX = false;
        }
    }
}
