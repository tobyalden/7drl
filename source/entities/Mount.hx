package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Mount extends Item
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

    private var timeOffGround:Float;
    private var timeJumpHeld:Float;

    public function new(x:Float, y:Float) {
        super(x, y - 10);
        weightModifier = 1.25;
        type = "mount";
        mask = new Hitbox(20, 20);
        graphic = new ColoredRect(width, height, 0x00FACC);
        timeOffGround = 0;
        timeJumpHeld = 0;
    }

    override public function update() {
        if(getPlayer().riding == this) {
            if(Input.pressed("jump") && (Input.check("up") || Input.check("down"))) {
                getPlayer().stopRiding();
            }
            else {
                mountedMovement();
                getPlayer().moveTo(
                    Math.floor(centerX - getPlayer().width / 2),
                    y - getPlayer().height,
                    ["walls"]
                );
                getPlayer().moveCarriedItemToHands();
            }
        }
        super.update();
    }

    private function mountedMovement() {
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

        var potUnder = collide("pot", x, y + 1);
        if(isOnGround() || timeOffGround <= COYOTE_TIME || potUnder != null) {
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
            ["walls", "pot"]
        );
        x = Math.max(x, HXP.scene.camera.x);

        if(Input.check("jump")) {
            timeJumpHeld += HXP.elapsed;
        }
        else {
            timeJumpHeld = 0;
        }
    }

    override public function moveCollideX(e:Entity) {
        if(e.type == "pot") {
            return false;
        }
        return super.moveCollideX(e);
    }

    override public function moveCollideY(e:Entity) {
        if(e.type == "pot" && bottom > e.y) {
            return false;
        }
        if(getPlayer().riding == this) {
            velocity.y = 0;
            return true;
        }
        return super.moveCollideY(e);
    }
}
