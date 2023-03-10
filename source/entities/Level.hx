package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;
import scenes.GameScene;

class Level extends MiniEntity
{
    public static inline var TILE_SIZE = 10;
    public static inline var DEFAULT_MAX_ENEMIES = 3;

    public var entities(default, null):Array<Entity>;
    public var playerStart(default, null):Vector2;
    public var eggStart(default, null):Vector2;
    private var walls:Grid;
    private var tiles:Tilemap;
    private var levelName:String;

    public function new(levelName:String) {
        super(0, 0);
        this.levelName = levelName;
        type = "walls";
        loadLevel(levelName);
        updateGraphic(levelName);
    }

    public function addEnemies() {
        var totalEnemies = 0;
        var allTiles = [];
        var maxEnemies = DEFAULT_MAX_ENEMIES;

        if(levelName.indexOf("hell") != -1) {
            maxEnemies += 1;
            if(Random.random < 0.33) {
                var buffer = Medusa.SINE_WAVE_SIZE + 5;
                var medusaY = buffer + (GameScene.GAME_HEIGHT - buffer * 2) * Random.random;
                var upOrDown = HXP.choose(1, -1);
                var age = Random.random * Math.PI * 2;
                for(i in 0...3) {
                    var medusa = new Medusa(width + i * 20, medusaY, age - Math.PI / 32 * i);
                    entities.push(medusa);
                }
                totalEnemies += 2;
            }
        }
        else if(levelName.indexOf("heaven") != -1) {
            maxEnemies -= 1;
        }

        for(tileX in 1...walls.columns - 1) {
            for(tileY in 2...walls.rows - 1) {
                allTiles.push({tileX: tileX, tileY: tileY});
            }
        }
        HXP.shuffle(allTiles);
        for(tile in allTiles) {
            var tileX = tile.tileX;
            var tileY = tile.tileY;
            if(totalEnemies >= maxEnemies) {
                continue;
            }
            else if(levelName.indexOf("earth") != -1) {
                if(
                    !getTile(tileX, tileY)
                    && !getTile(tileX - 1, tileY)
                    && !getTile(tileX + 1, tileY)
                    && getTile(tileX, tileY + 1)
                    && Random.random < 0.1
                ) {
                    var enemySpawn = new Vector2(
                        tileX * TILE_SIZE + TILE_SIZE / 2,
                        (tileY + 1) * TILE_SIZE
                    );
                    var enemy:Entity = HXP.choose(
                        new Human(enemySpawn.x, enemySpawn.y),
                        new JumpingHuman(enemySpawn.x, enemySpawn.y)
                    );
                    enemy.x -= enemy.width / 2;
                    enemy.y -= enemy.height;
                    entities.push(enemy);
                    totalEnemies += 1;
                }
            }
            else if(levelName.indexOf("hell") != -1) {
                if(
                    getTile(tileX, tileY)
                    && !getTile(tileX, tileY - 1)
                    && Random.random < 0.5
                ) {
                    var enemySpawn = new Vector2(
                        tileX * TILE_SIZE,
                        tileY * TILE_SIZE
                    );
                    var enemy = new SpikeTrap(enemySpawn.x, enemySpawn.y);
                    entities.push(enemy);
                    if(
                        getTile(tileX + 1, tileY)
                        && !getTile(tileX + 1, tileY - 1)
                    ) {
                        enemy = new SpikeTrap(enemySpawn.x + TILE_SIZE, enemySpawn.y);
                        entities.push(enemy);
                    }
                    if(
                        getTile(tileX - 1, tileY)
                        && !getTile(tileX - 1, tileY - 1)
                    ) {
                        enemy = new SpikeTrap(enemySpawn.x - TILE_SIZE, enemySpawn.y);
                        entities.push(enemy);
                    }
                    totalEnemies += 1;
                }
                if(
                    !getTile(tileX, tileY)
                    && getTile(tileX, tileY - 1)
                ) {
                    var enemySpawn = new Vector2(
                        tileX * TILE_SIZE,
                        tileY * TILE_SIZE
                    );
                    var enemy = new FallingSpike(enemySpawn.x, enemySpawn.y);
                    entities.push(enemy);
                    if(
                        !getTile(tileX + 1, tileY)
                        && getTile(tileX + 1, tileY - 1)
                    ) {
                        enemy = new FallingSpike(enemySpawn.x + TILE_SIZE, enemySpawn.y);
                        entities.push(enemy);
                    }
                    if(
                        !getTile(tileX - 1, tileY)
                        && getTile(tileX - 1, tileY - 1)
                    ) {
                        enemy = new FallingSpike(enemySpawn.x - TILE_SIZE, enemySpawn.y);
                        entities.push(enemy);
                    }
                    totalEnemies += 1;
                }
                if(
                    getTile(tileX, tileY)
                    && (
                        !getTile(tileX, tileY + 1)
                        || !getTile(tileX, tileY - 1)
                    )
                    && Random.random < 0.2
                ) {
                    var enemySpawn = new Vector2(
                        tileX * TILE_SIZE + TILE_SIZE / 2,
                        tileY * TILE_SIZE + TILE_SIZE / 2
                    );
                    var enemy = new SpikeBall(enemySpawn.x, enemySpawn.y);
                    entities.push(enemy);
                    totalEnemies += 2;
                }
            }
            else if(levelName.indexOf("heaven") != -1) {
                if(
                    !getTile(tileX + 1, tileY)
                    && !getTile(tileX, tileY)
                    && !getTile(tileX - 1, tileY)
                    && !getTile(tileX + 1, tileY - 1)
                    && !getTile(tileX, tileY - 1)
                    && !getTile(tileX - 1, tileY - 1)
                    && !getTile(tileX + 1, tileY + 1)
                    && !getTile(tileX, tileY + 1)
                    && !getTile(tileX - 1, tileY + 1)
                ) {
                    var enemySpawn = new Vector2(
                        tileX * TILE_SIZE + TILE_SIZE / 2,
                        tileY * TILE_SIZE + TILE_SIZE / 2
                    );
                    var enemy = new Angel(enemySpawn.x, enemySpawn.y);
                    enemy.x -= enemy.width / 2;
                    enemy.y -= enemy.height / 2;
                    entities.push(enemy);
                    totalEnemies += 1;
                }
            }
        }
    }

    public function getTile(tileX:Int, tileY:Int) {
        if(tileX < 0 || tileY < 0 || tileX >= walls.columns || tileY >= walls.rows) {
            return false;
        }
        return walls.getTile(tileX, tileY);
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
                        entities.push(new Mount(entity.x, entity.y, entity.values.isDragon));
                    }
                    if(entity.name == "pot") {
                        entities.push(new Pot(entity.x, entity.y));
                    }
                    if(entity.name == "bed") {
                        entities.push(new Bed(entity.x, entity.y));
                    }
                    if(entity.name == "enemy") {
                        //entities.push(new Enemy(entity.x, entity.y));
                        //entities.push(new Medusa(entity.x, entity.y));
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
                    if(entity.name == "water") {
                        entities.push(new Water(entity.x, entity.y, entity.width, entity.height));
                    }
                    if(entity.name == "angel") {
                        entities.push(new Angel(entity.x, entity.y));
                    }
                    if(entity.name == "satan") {
                        entities.push(new Satan(entity.x, entity.y));
                    }
                    if(entity.name == "sword") {
                        entities.push(new Sword(entity.x, entity.y));
                    }
                    if(entity.name == "human") {
                        entities.push(HXP.choose(
                            new JumpingHuman(entity.x, entity.y),
                            new Human(entity.x, entity.y)
                        ));
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
            if(Type.getClass(entity) == SpikeBall) {
                cast(entity, SpikeBall).startPoint.add(new Vector2(x, y));
            }
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

