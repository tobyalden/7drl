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

    static public var carrying(default, null):Item = null;

    public var riding(default, null):Mount;
    public var velocity(default, null):Vector2;
    private var sprite:Spritemap;
    private var timeOffGround:Float;
    private var timeJumpHeld:Float;
    private var rideCooldown:Alarm;
    private var canMove:Bool;
    private var lastUsedPot:Pot;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        layer = -10;
        riding = null;
        name = "player";
        mask = new Hitbox(10, 15);
        sprite = new Spritemap("graphics/player.png", 10, 15);
        sprite.add("idle", [0]);
        sprite.add("asleep", [1]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2();
        timeOffGround = 999;
        timeJumpHeld = 999;
        rideCooldown = new Alarm(RIDE_COOLDOWN);
        addTween(rideCooldown);
        canMove = true;
        lastUsedPot = null;
    }

    private function enterPot(pot:Pot) {
        velocity.setTo(0, 0);
        HXP.alarm(1, function() {
            removeCarriedItem();
            if(getScene().zone == "pot") {
                HXP.engine.pushScene(new GameScene("hell"));
            }
            else {
                if(pot.interior == null) {
                    pot.createInterior();
                }
                HXP.engine.pushScene(pot.interior);
            }
        }, this);
    }

    public function destroyCarriedItem() {
        Player.carrying = null;
    }

    public function removeCarriedItem() {
        if(Player.carrying == null) {
            return;
        }
        HXP.scene.remove(Player.carrying);
    }

    public function addCarriedItem(itemPosition:Vector2) {
        if(Player.carrying == null) {
            return;
        }
        HXP.scene.add(Player.carrying);
        Player.carrying.moveTo(itemPosition.x, itemPosition.y);
    }

    public function exitPot() {
        HXP.tween(
            this,
            {
                x: Math.floor(lastUsedPot.centerX - width / 2),
                y: lastUsedPot.y - height
            },
            1,
            {complete: function() {
                canMove = true;
                layer = -10;
                //if(lastUsedPot != null) {
                    //lastUsedPot.crack();
                //}
            }}
        );
        if(carrying != null) {
            HXP.tween(
                carrying,
                {
                    x: Math.floor(lastUsedPot.centerX - carrying.width / 2),
                    y: lastUsedPot.y - height - carrying.height
                },
                1
            );
        }
    }

    public function wakeUp() {
        canMove = true;
        sprite.play("idle");
        trace('waking up: ${getScene().zone}');
    }

    override public function update() {
        if(canMove) {
            handlePots();
            handleBeds();
            action();
            if(riding == null) {
                movement();
            }
            animation();
            moveCarriedItemToHands();
        }
        collisions();
        super.update();
    }

    private function handlePots() {
        var potUnder = collide("pot", x, y + 1);
        if(
            Input.pressed("down")
            && potUnder != null
            && !cast(potUnder, Pot).isCracked
            && collide("pot", x, y) == null
            && riding == null
            && centerX >= potUnder.x
            && centerX <= potUnder.right
        ) {
            trace('entering pot');
            canMove = false;
            layer = potUnder.layer + 1;
            lastUsedPot = cast(potUnder, Pot);
            HXP.tween(
                this,
                {x: Math.floor(potUnder.centerX - width / 2), y: potUnder.y},
                1,
                {complete: function() { enterPot(cast(potUnder, Pot)); }}
            );
            if(Player.carrying != null) {
                HXP.tween(
                    Player.carrying,
                    {x: Math.floor(potUnder.centerX - Player.carrying.width / 2), y: potUnder.y},
                    1
                );
            }
        }
    }

    private function handleBeds() {
        var bedUnder = collide("bed", x, y + 1);
        if(
            Input.pressed("down")
            && bedUnder != null
            && collide("bed", x, y) == null
            && riding == null
            && centerX >= bedUnder.x
            && centerX <= bedUnder.right
        ) {
            canMove = false;
            moveTo(
                Math.floor(bedUnder.centerX - width / 2),
                bedUnder.y - height,
                ["walls"]
            );
            sprite.play("asleep");
            HXP.alarm(1, function() {
                removeCarriedItem();
                GameScene.bedDepths.push(GameScene.dreamDepth);
                HXP.engine.pushScene(new GameScene("earth"));
            }, this);
        }
    }

    private function action() {
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
                var item = collideAny(Item.itemTypes, x, y + 1);
                if(item != null) {
                    carrying = cast(item, Item);
                }
            }
        }
    }

    public function moveCarriedItemToHands() {
        if(carrying == null) {
            return;
        }
        carrying.moveTo(
            centerX - Math.floor(carrying.width / 2),
            y - carrying.height,
            ["walls"]
        );
        if(distanceFrom(carrying, true) > DETACH_DISTANCE) {
            carrying = null;
        }
    }

    public function stopRiding() {
        rideCooldown.start();
        if(Input.check("up")) {
            velocity.y = -JUMP_POWER;
        }
        else {
            velocity.y = 0;
            moveTo(
                Math.floor(riding.centerX - width / 2),
                riding.bottom - height - 5,
                ["walls"]
            );
        }
        riding = null;
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

        var semiSolidUnder = collideAny(MiniEntity.semiSolids, x, y + 1);
        if(isOnGround() || timeOffGround <= COYOTE_TIME || semiSolidUnder != null) {
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
            ["walls"].concat(MiniEntity.semiSolids)
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
        if(collide("hazard", x, y) != null) {
            die();
        }
    }

    private function die() {
        canMove = false;
        visible = false;
        collidable = false;
        getScene().onDeath();
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

    private function animation() {
        if(Input.check("left")) {
            sprite.flipX = true;
        }
        else if(Input.check("right")) {
            sprite.flipX = false;
        }
    }
}
