package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends MiniEntity
{
    public var entities(default, null):Array<Entity>;
    public var playerStart(default, null):Vector2;
    public var eggStart(default, null):Vector2;
    private var walls:Grid;
    private var tiles:Tilemap;

    public function new(levelName:String) {
        super(0, 0);
        type = "walls";
        loadLevel(levelName);
        updateGraphic(levelName);
    }

    override public function update() {
        super.update();
    }

    private function loadLevel(levelName:String) {
        var levelData = haxe.Json.parse(Assets.getText('levels/${levelName}.json'));
        for(layerIndex in 0...levelData.layers.length) {
            var layer = levelData.layers[layerIndex];
            if(layer.name == "walls") {
                // Load solid geometry
                walls = new Grid(levelData.width, levelData.height, layer.gridCellWidth, layer.gridCellHeight);
                for(tileY in 0...layer.grid2D.length) {
                    for(tileX in 0...layer.grid2D[0].length) {
                        walls.setTile(tileX, tileY, layer.grid2D[tileY][tileX] == "1");
                    }
                }
                mask = walls;
            }
            else if(layer.name == "entities") {
                // Load entities
                entities = new Array<Entity>();
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        entities.push(new Player(entity.x, entity.y));
                        playerStart = new Vector2(entity.x, entity.y);
                    }
                    if(entity.name == "item") {
                        entities.push(new Item(entity.x, entity.y));
                    }
                    if(entity.name == "mount") {
                        entities.push(new Mount(entity.x, entity.y));
                    }
                    if(entity.name == "pot") {
                        entities.push(new Pot(entity.x, entity.y));
                    }
                    if(entity.name == "bed") {
                        entities.push(new Bed(entity.x, entity.y));
                    }
                    if(entity.name == "enemy") {
                        entities.push(new Enemy(entity.x, entity.y));
                    }
                    if(entity.name == "egg") {
                        entities.push(new Egg(entity.x, entity.y));
                        eggStart = new Vector2(entity.x, entity.y);
                    }
                    if(entity.name == "nest") {
                        entities.push(new Nest(entity.x, entity.y, entity.width, entity.height));
                    }
                    if(entity.name == "kettle") {
                        entities.push(new Kettle(entity.x, entity.y));
                    }
                    if(entity.name == "ogre") {
                        entities.push(new Ogre(entity.x, entity.y));
                    }
                    if(entity.name == "lava") {
                        entities.push(new Lava(entity.x, entity.y, entity.width, entity.height));
                    }
                    if(entity.name == "optionalSolid") {
                        if(Random.random < 0.5) {
                            for(tileY in 0...Std.int(entity.height / walls.tileHeight)) {
                                for(tileX in 0...Std.int(entity.width / walls.tileWidth)) {
                                    walls.setTile(
                                        tileX + Std.int(entity.x / walls.tileHeight),
                                        tileY + Std.int(entity.y / walls.tileWidth),
                                        true
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public function offsetEntities() {
        for(entity in entities) {
            entity.x += x;
            entity.y += y;
        }
    }

    public function updateGraphic(levelName:String) {
        var allTilesets = [
            "bedroom" => "bedroom",
            "earth" => "earth",
            "earth_nest" => "earth",
            "heaven" => "heaven",
            "hell" => "hell"
        ];
        var tileset = allTilesets.exists(levelName) ? allTilesets[levelName] : "default";
        tiles = new Tilemap(
            'graphics/tiles_${tileset}.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, 0);
                }
            }
        }
        graphic = tiles;
    }
}

