package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeBall extends MiniEntity
{
    //private var sprite:Image;
    public var startPoint:Vector2;
    private var age:Float;
    private var radius:Int;
    private var orbitRadius:Int;
    private var orbitSpeed:Int;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        layer = -33;
        this.startPoint = new Vector2(startX, startY);
        type = "hazard";
        age = Random.random * Math.PI * 2;
        radius = 7;
        orbitRadius = 60;
        orbitSpeed = HXP.choose(3, -3);
        var hitbox = new Circle(radius);
        mask = hitbox;
        graphic = new Image("graphics/spikeball.png");
    }

    override public function update() {
        age += HXP.elapsed;
        var orbitAxis = new Vector2(
            startPoint.x - radius, startPoint.y - radius
        );
        var orbitArm = new Vector2(orbitRadius, 0);
        orbitArm.rotate(age * orbitSpeed);
        moveTo(orbitAxis.x + orbitArm.x, orbitAxis.y + orbitArm.y);
        super.update();
    }

    override public function render(camera:Camera) {
        Draw.lineThickness = 2 * HXP.screen.scaleX;
        Draw.setColor(0xFFFFFF);
        Draw.line(
            (x + radius - HXP.scene.camera.x) * HXP.screen.scaleX, (y + radius - HXP.scene.camera.y) * HXP.screen.scaleY,
            (startPoint.x - HXP.scene.camera.x) * HXP.screen.scaleX, (startPoint.y - HXP.scene.camera.y) * HXP.screen.scaleY
        );
        super.render(HXP.scene.camera);
        //Draw.setColor(0xFF0000);
        //Draw.circleFilled(x + radius - HXP.scene.camera.x, y + radius - HXP.scene.camera.y, radius);
    }
}

