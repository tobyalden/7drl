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
    public static inline var MAX_RISE_SPEED = 800;
    public static inline var COYOTE_TIME = 1 / 60 * 5;
    public static inline var JUMP_BUFFER_TIME = 1 / 60 * 5;
    public static inline var TOSS_VELOCITY_X = 150;
    public static inline var TOSS_VELOCITY_Y = 150;
    public static inline var DETACH_DISTANCE = 10;
    public static inline var RIDE_COOLDOWN = 0.5;
    public static inline var MAX_HEALTH = 3;
    public static inline var INVINCIBLE_TIME = 2;

    static public var carrying(default, null):Item = null;
    static public var riding(default, null):Mount = null;
    static public var health(default, null):Int = 3;

    public var velocity(default, null):Vector2;
    public var heads(default, null):Array<Head>;
    private var sprite:Spritemap;
    private var timeOffGround:Float;
    private var timeJumpHeld:Float;
    private var rideCooldown:Alarm;
    private var canMove:Bool;
    private var lastUsedPot:Pot;
    private var isAsleep:Bool;
    private var wasOnGround:Bool;
    private var invincibilityTimer:Alarm;
    private var healthAppearPause:Alarm;
    private var showHealth:Bool;

    public function new(x:Float, y:Float) {
        super(x, y - 5);
        layer = -10;
        name = "player";
        mask = new Hitbox(10, 15);
        sprite = new Spritemap("graphics/player.png", 10, 15);
        sprite.add("idle", [0]);
        sprite.add("run", [4, 5, 6, 7], 8);
        sprite.add("jump", [8, 9], 8);
        sprite.add("asleep", [12]);
        sprite.add("idle_carrying", [16]);
        sprite.add("run_carrying", [20, 21, 22, 23], 8);
        sprite.add("jump_carrying", [24, 25], 8);
        sprite.add("asleep_carrying", [28]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2();
        timeOffGround = 999;
        timeJumpHeld = 999;
        rideCooldown = new Alarm(RIDE_COOLDOWN);
        addTween(rideCooldown);
        canMove = true;
        lastUsedPot = null;
        isAsleep = false;
        wasOnGround = true;
        heads = [new Head(x, y), new Head(x, y), new Head(x, y)];
        invincibilityTimer = new Alarm(INVINCIBLE_TIME);
        addTween(invincibilityTimer);
        healthAppearPause = new Alarm(1, function() {
            showHealth = true;
        });
        addTween(healthAppearPause);
        showHealth = false;
    }

    private function enterPot(pot:Pot) {
        velocity.setTo(0, 0);
        HXP.alarm(1, function() {
            removeCarriedItem();
            if(getScene().zone == "pot") {
                HXP.engine.pushScene(new GameScene("hell"));
            }
            else if(getScene().zone == "hell") {
                removeCarriedItem();
                GameScene.exitedPot = true;
                HXP.engine.popScene();
            }
            else {
                if(pot.interior == null) {
                    pot.createInterior();
                }
                HXP.engine.pushScene(pot.interior);
            }
        }, this);
    }

    private function updateHeads() {
        for(i in 0...heads.length) {
            var head = heads[i];
            var following:Entity;
            if(i == 0) {
                following = this;
            }
            else {
                following = heads[i - 1];
            }
            var distancer = new Vector2(head.x - following.x, head.y - following.y);
            distancer.normalize(Head.FOLLOW_DISTANCE);
            head.x = following.x + distancer.x;
            head.y = following.y + distancer.y;
        }
        if(velocity.length < 50 && canMove) {
            if(!healthAppearPause.active) {
                healthAppearPause.start();
            }
        }
        else {
            healthAppearPause.active = false;
            showHealth = false;
        }
        for(head in heads) {
            if(getScene().zone == "bedroom") {
                head.sprite.alpha = 0;
            }
            else if(showHealth) {
                head.sprite.alpha = MathUtil.approach(head.sprite.alpha, 1, HXP.elapsed * Head.DISAPPEAR_SPEED);
            }
            else {
                head.sprite.alpha = MathUtil.approach(head.sprite.alpha, 0, HXP.elapsed * Head.APPEAR_SPEED);
            }
            if(head.distanceFrom(this) < Head.FOLLOW_DISTANCE) {
                var distancer = new Vector2(head.x - x, head.y - y);
                distancer.normalize(Head.FOLLOW_DISTANCE);
                head.x = x + distancer.x;
                head.y = y + distancer.y;
            }
            head.sprite.play("dead");
        }
        for(i in 0...health) {
            heads[i].sprite.play("alive");
        }
    }

    public function maxOutHealth() {
        health = MAX_HEALTH;
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

    public function removeRiding() {
        if(Player.riding == null) {
            return;
        }
        HXP.scene.remove(Player.riding);
    }

    public function addCarriedItem(itemPosition:Vector2) {
        if(Player.carrying == null) {
            return;
        }
        HXP.scene.add(Player.carrying);
        Player.carrying.moveTo(itemPosition.x, itemPosition.y);
    }

    public function addRiding() {
        if(Player.riding == null) {
            return;
        }
        HXP.scene.add(Player.riding);
        Player.riding.moveTo(centerX - Player.riding.width / 2, bottom - Player.riding.height);
        moveTo(Player.riding.centerX - width / 2, Player.riding.y - height);
    }

    public function exitPot() {
        // TODO: It's possible for an item to clip into a wall and get stuck when exiting
        GameScene.sfx["exitpot"].play();
        HXP.tween(
            this,
            {
                x: Math.floor(lastUsedPot.centerX - width / 2),
                y: lastUsedPot.y - height
            },
            1,
            {complete: function() {
                canMove = true;
                invincibilityTimer.start();
                layer = -10;
                if(lastUsedPot != null) {
                    lastUsedPot.crack();
                }
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
        isAsleep = false;
        GameScene.sfx["wakeup"].play();
    }

    override public function update() {
        wasOnGround = isOnGround();
        if(canMove) {
            handlePots();
            handleBeds();
            action();
            if(Player.riding == null) {
                movement();
            }
            else {
                if(distanceFrom(Player.riding, true) > DETACH_DISTANCE) {
                    stopRiding();
                }
            }
            preventBacktracking();
            animation();
            moveCarriedItemToHands();
        }
        collisions();
        sound();
        if(!wasOnGround && isOnGround()) {
            GameScene.sfx["land"].play();
        }
        updateHeads();
        super.update();
    }

    private function handlePots() {
        var potUnder = collide("pot", x, y + 1);
        if(
            Input.pressed("down")
            && potUnder != null
            && !cast(potUnder, Pot).isCracked
            && collide("pot", x, y) == null
            && Player.riding == null
            && centerX >= potUnder.x
            && centerX <= potUnder.right
        ) {
            canMove = false;
            layer = potUnder.layer + 1;
            lastUsedPot = cast(potUnder, Pot);
            GameScene.sfx["enterpot"].play();
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
            && Player.riding == null
            && centerX >= bedUnder.x
            && centerX <= bedUnder.right
        ) {
            canMove = false;
            moveTo(
                Math.floor(bedUnder.centerX - width / 2),
                bedUnder.y - height,
                ["walls"]
            );
            isAsleep = true;
            GameScene.sfx["dream"].play(0.5);
            HXP.alarm(3, function() {
                removeCarriedItem();
                GameScene.bedDepths.push(GameScene.dreamDepth);
                HXP.engine.pushScene(new GameScene(GameScene.bedDepths.length >= 4 ? "swordroom" : "earth"));
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
                    if(!isOnGround()) {
                        carrying.toss(0, TOSS_VELOCITY_Y);
                    }
                }
                else {
                    var tossInfluence = Player.riding != null ? Player.riding.velocity : velocity;
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
                GameScene.sfx["toss"].play();
                Player.carrying = null;
            }
            else if(Player.riding == null) {
                // You can't pick up items while Player.riding
                var item = collideAny(Item.itemTypes, x, y + 1);
                if(item != null) {
                    Player.carrying = cast(item, Item);
                    if(item.type == "sword") {
                        GameScene.sfx["pickupsword"].play();
                    }
                    else {
                        GameScene.sfx["pickup"].play();
                    }
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
        if(Player.riding == null) {
            return;
        }
        rideCooldown.start();
        if(Input.check("up")) {
            velocity.y = -JUMP_POWER;
            GameScene.sfx["jump"].play();
        }
        else {
            velocity.y = 0;
            moveTo(
                Math.floor(Player.riding.centerX - width / 2),
                Player.riding.bottom - height - 5,
                ["walls"]
            );
        }
        Player.riding = null;
        GameScene.sfx["dismount"].play();
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
            && Player.riding == null
        ) {
            Player.riding = cast(mount, Mount);
            GameScene.sfx["mount"].play();
        }
        var hazard = collideAny(MiniEntity.hazards, x, y);
        if(
            hazard != null
            && canMove
            && !(hazard.type == "lava" && Player.riding != null && Player.riding.isDragon)) {
            if(hazard.type == "lava") {
                die();
            }
            else {
                takeHit();
            }
        }
    }

    private function takeHit() {
        if(invincibilityTimer.active) {
            return;
        }
        health -= 1;
        if(health <= 0) {
            die();
        }
        else {
            GameScene.sfx["takehit"].play();
            invincibilityTimer.start();
        }
    }

    private function sound() {
        if(isOnGround() && Player.riding == null && Math.abs(velocity.x) > 0 && canMove) {
            if(!GameScene.sfx["run"].playing) {
                GameScene.sfx["run"].loop();
            }
        }
        else {
            GameScene.sfx["run"].stop();
        }
    }

    public function die() {
        if(GameScene.debugMode) {
            return;
        }
        stopRiding();
        canMove = false;
        visible = false;
        collidable = false;
        GameScene.sfx["die"].play();
        explode(50);
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
        if(invincibilityTimer.active && canMove) {
            sprite.alpha = sprite.alpha == 0 ? 1 : 0;
        }
        else {
            sprite.alpha = 1;
        }
        var suffix = carrying != null ? "_carrying" : "";
        var action = "idle";
        if(Player.riding != null) {
            action = "idle";
        }
        else if(isAsleep) {
            action = "asleep";
        }
        else if(!isOnGroundOrSemiSolid()) {
            action = "jump";
        }
        else if(Math.abs(velocity.x) > 0) {
            action = "run";
        }
        var animationName = '${action}${suffix}';
        sprite.play(animationName);

        if(Input.check("left")) {
            sprite.flipX = true;
        }
        else if(Input.check("right")) {
            sprite.flipX = false;
        }
    }
}
