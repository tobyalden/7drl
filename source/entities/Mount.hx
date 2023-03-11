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
    public static inline var MAX_RISE_SPEED = 800;
    public static inline var COYOTE_TIME = 1 / 60 * 5;
    public static inline var JUMP_BUFFER_TIME = 1 / 60 * 5;

    public static inline var FLAP_POWER = 250;
    //public static inline var EGG_SPAWN_DISTANCE = GameScene.GAME_WIDTH * 5;
    public static inline var EGG_SPAWN_DISTANCE = 100;
    public static inline var EGG_SPAWN_TIME = 2;

    public static inline var DRAGON_FLY_SPEED = 175;

    public var isDragon(default, null):Bool;
    private var timeOffGround:Float;
    private var timeJumpHeld:Float;
    private var distanceTraveled:Float;
    private var eggSpawner:Alarm;
    private var sprite:Spritemap;
    private var wasOnGround:Bool;

    public function new(x:Float, y:Float, isDragon:Bool) {
        super(x, y - 10);
        this.isDragon = isDragon;
        weightModifier = 1.25;
        type = "mount";
        mask = new Hitbox(isDragon ? 30 : 20, 20);
        if(isDragon) {
            sprite = new Spritemap("graphics/dragon.png", width, height);
            sprite.add("idle", [0, 1], 8);
            sprite.play("idle");
        }
        else {
            sprite = new Spritemap("graphics/chicken.png", width, height);
            sprite.add("idle", [0]);
            sprite.add("run", [3, 2], 8);
            sprite.add("fly", [5, 4], 8);
            sprite.play("idle");
        }
        graphic = sprite;
        timeOffGround = 999;
        timeJumpHeld = 999;
        eggSpawner = new Alarm(EGG_SPAWN_TIME, function() {
            spawnEgg();
        });
        addTween(eggSpawner);
        distanceTraveled = 0;
        wasOnGround = true;
    }

    private function spawnEgg() {
        HXP.scene.add(new Egg(x, y));
        GameScene.sfx["chicken_lay"].play();
    }

    override public function update() {
        wasOnGround = isOnGround();
        if(Player.riding == this) {
            if(Input.pressed("jump") && (Input.check("up") || Input.check("down"))) {
                getPlayer().stopRiding();
            }
            else {
                var oldX = x;
                if(isDragon) {
                    dragonMovement();
                }
                else {
                    mountedMovement();
                }
                if(oldX < x) {
                    distanceTraveled += x - oldX;
                }
                getPlayer().moveTo(
                    Math.floor(centerX - getPlayer().width / 2),
                    y - getPlayer().height,
                    ["walls"]
                );
                getPlayer().moveCarriedItemToHands();
            }
        }
        if(!isDragon && distanceTraveled > EGG_SPAWN_DISTANCE) {
            distanceTraveled = 0;
            eggSpawner.start();
            GameScene.sfx["chicken_alert"].play();
        }
        if(collide("lava", x, y) != null && !isDragon) {
            die();
        }
        var hazard = collideAny(MiniEntity.hazards, x, y);
        if(hazard != null && hazard.type != "lava" && Player.riding == this) {
            die();
        }
        animation();
        if(!wasOnGround && isOnGround()) {
            GameScene.sfx["land"].play();
        }
        super.update();
    }

    private function animation() {
        if(velocity.x < 0) {
            sprite.flipX = true;
        }
        else if(velocity.x > 0) {
            sprite.flipX = false;
        }

        if(isDragon) {
            sprite.play("idle");
        }
        else {
            if(isOnGround()) {
                if(Math.abs(velocity.x) > 0) {
                    sprite.play("run");
                }
                else {
                    sprite.play("idle");
                }
            }
            else {
                sprite.play("fly");
            }
        }
    }

    private function die() {
        HXP.scene.remove(this);
        if(Player.riding == this) {
            getPlayer().stopRiding();
        }
    }

    private function dragonMovement() {
        var heading = new Vector2();
        if(Input.check("up")) {
            heading.y = -1;
        }
        else if(Input.check("down")) {
            heading.y = 1;
        }
        if(Input.check("left")) {
            heading.x = -1;
        }
        else if(Input.check("right")) {
            heading.x = 1;
        }
        velocity.x = heading.x * DRAGON_FLY_SPEED;
        velocity.y = heading.y * DRAGON_FLY_SPEED;
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"]
        );

        preventBacktracking();
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

        if(isOnGroundOrSemiSolid() || timeOffGround <= COYOTE_TIME) {
            if(
                Input.pressed("jump")
                || Input.check("jump") && timeJumpHeld <= JUMP_BUFFER_TIME
            ) {
                var jumpPower:Float = JUMP_POWER;
                if(collide("water", x, y) != null) {
                    jumpPower *= 0.5;
                }
                velocity.y = -jumpPower;
                GameScene.sfx["jump"].play();
                timeJumpHeld = 999;
                timeOffGround = 999;
            }
        }
        else {
            if(Input.pressed("jump")) {
                velocity.y = Math.min(velocity.y, JUMP_CANCEL);
                velocity.y -= FLAP_POWER;
                GameScene.sfx["flap"].play();
            }
        }

        var gravity:Float = GRAVITY;
        if(Math.abs(velocity.y) < JUMP_CANCEL) {
            gravity *= 0.5;
        }
        if(collide("water", x, y) != null) {
            gravity *= 0.25;
        }
        velocity.y += gravity * HXP.elapsed;

        if(collide("steam", x, y) != null) {
            velocity.y = Math.min(velocity.y, JUMP_CANCEL);
            velocity.y -= Steam.LIFT_POWER * HXP.elapsed;
        }

        var maxRiseSpeed:Float = MAX_RISE_SPEED;
        var maxFallSpeed:Float = MAX_FALL_SPEED;
        if(collide("water", x, y) != null) {
            maxRiseSpeed *= 0.66;
            maxFallSpeed *= 0.33;
        }
        velocity.y = MathUtil.clamp(velocity.y, -maxRiseSpeed, maxFallSpeed);

        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"].concat(MiniEntity.semiSolids)
        );

        preventBacktracking();

        if(Input.check("jump")) {
            timeJumpHeld += HXP.elapsed;
        }
        else {
            timeJumpHeld = 0;
        }
    }

    override public function moveCollideX(e:Entity) {
        if(MiniEntity.semiSolids.contains(e.type)) {
            return false;
        }
        return super.moveCollideX(e);
    }

    override public function moveCollideY(e:Entity) {
        if(MiniEntity.semiSolids.contains(e.type) && bottom > e.y) {
            return false;
        }
        if(Player.riding == this) {
            velocity.y = 0;
            return true;
        }
        return super.moveCollideY(e);
    }
}

