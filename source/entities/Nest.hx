package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Nest extends MiniEntity
{
    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -10;
        type = "nest";
        mask = new Hitbox(60, 20);
        var sprite = new Image("graphics/nest.png");
        graphic = sprite;
    }
}
