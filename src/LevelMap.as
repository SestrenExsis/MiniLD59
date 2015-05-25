package
{
	public class LevelMap
	{
		protected var _tiles:Vector.<VoxelCube>;
		protected var _sprites:Vector.<SpriteBillboard>;
		protected var _camera:ViewpointCamera;
		
		public function LevelMap(Width:uint = 16, Height:uint = 16, Depth:uint = 3)
		{
			_tiles = new Vector.<VoxelCube>();
			_sprites = new Vector.<SpriteBillboard>();
			
			var _seed:Number;
			var _textureIndex:int;
			var _voxelCube:VoxelCube;
			for (var y:int = 0; y < Depth; y++) // y is the "floor number" of each layer on the map
			{
				for (var x:int = 0; x < Width; x++)
				{
					for (var z:int = 0; z < Height; z++)
					{
						if (y == 0)
							_textureIndex = Entity.TEX_BLUE_WALL;
						else if (y == Depth - 1)
							_textureIndex = Entity.TEX_GREEN_WALL;
						else
						{
							if (x == 0 || x == Width - 1 || z == 0 || z == Height - 1)
								_textureIndex = Entity.TEX_FLOOR;
							else
							{
								_seed = Math.random();
								if (_seed < 0.01)
									_textureIndex = Entity.TEX_PILLAR;
								else 
								{
									_textureIndex = Entity.TEX_NONE;
									if (_seed < 0.1)
										_sprites.push(new SpriteBillboard(Entity.TEX_PLAYER_WALK[0], x, y, z));
								}
							}
						}
						if (_textureIndex >= 0)
						{
							_voxelCube = new VoxelCube(_textureIndex, x, y, z);
							_tiles.push(_voxelCube);
						}
					}
				}
			}
		}
		
		private function sortingFunction(EntityA:Entity, EntityB:Entity):Number
		{
			var distA:Number = EntityA.getCameraDistance(_camera);
			var distB:Number = EntityB.getCameraDistance(_camera);
			if (distA < distB) return 1;
			else if (distA > distB) return -1;
			else return 0;
		}
		
		public function update():void
		{
			var i:int;
			var _voxelCube:VoxelCube;
			for (i = 0; i < _tiles.length; i++)
			{
				_voxelCube = _tiles[i];
				_voxelCube.update();
			}
			
			var _sprite:SpriteBillboard;
			for (i = 0; i < _sprites.length; i++)
			{
				_sprite = _sprites[i];
				_sprite.update();
			}
		}
		
		public function render(Camera:ViewpointCamera):void
		{
			Entity.preRender();
			
			_camera = Camera;
			_sprites.sort(sortingFunction);
			
			var i:int;
			var _voxelCube:VoxelCube;
			for (i = 0; i < _tiles.length; i++)
			{
				_voxelCube = _tiles[i];
				_voxelCube.renderScene(Camera);
			}
			
			var _sprite:SpriteBillboard;
			for (i = 0; i < _sprites.length; i++)
			{
				_sprite = _sprites[i];
				_sprite.renderScene(Camera);
			}
			
			Entity.postRender();
		}
	}
}