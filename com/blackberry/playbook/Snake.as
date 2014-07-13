package com.blackberry.playbook{

	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.display.SimpleButton;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.geom.Rectangle;
	import com.blackberry.playbook.Chronometer;
	import flash.sampler.StackFrame;

	public class Snake extends MovieClip {

		public static var UP:int = 1;
		public static var RIGHT:int = 2;
		public static var DOWN:int = -1;
		public static var LEFT:int = -2;
		private static var APP_WIDTH:Number = 864;
		private static var APP_HEIGHT:Number = 552;
		private static var GRID_LENGTH:int = 24;
		private var SPEED:uint = 100;//lower = faster

		private var snakes : Array = new Array();
		private var snakeHead:GridDirection;
		private var food:GridDirection;

		private var inicialPointX:int;
		private var inicialPointY:int;
		private var finalPointX:int;
		private var finalPointY:int;

		private var timer:Timer;

		private var Score:Number = 0;
		private var Bonus:Number = 0;
		private var myFont = new MyriadProBold();
		private var myFormat:TextFormat = new TextFormat();
		private var txtScore:TextField = null;
		private var txtTime:TextField = null;
		private var chronometer:Chronometer;

		private var size:Number;
		private var grid:Array;

		private var gameStarted:Boolean = false;
		
		private var optionsSound:String;
		private var optionsControl:String;
		private var optionsLevels:String;
		
		private var eatingSound:SoundChannel;
		private var bitingSound:SoundChannel;
		private var stepSound:SoundChannel;
		
		private var dragging:Boolean = false;

		public function Snake(OptionsSound:String, OptionsControl:String, OptionsLevels:String) {
			optionsSound = OptionsSound;
			optionsControl = OptionsControl;
			optionsLevels = OptionsLevels;
			this.addEventListener(Event.ADDED_TO_STAGE, openGame);
		}

		private function openGame(event: Event):void {
			timer = new Timer(SPEED);
			startGame();
		}

		private function startGame():void {
			gameStarted = true;
			holder.visible = true;
			
			if (optionsControl == "Control"){
				mcControl.x = (APP_WIDTH - (mcControl.width));
				mcControl.y = ((APP_HEIGHT/2) - (mcControl.width/2));
				mcControl.visible = true;
				mcControl.btnDrag.addEventListener(MouseEvent.MOUSE_DOWN, controlerStartDrag);
				mcControl.btnDrag.addEventListener(MouseEvent.MOUSE_UP, controlerStopDrag);
				mcControl.btnUp.addEventListener(MouseEvent.CLICK, controlerUp);
				mcControl.btnRight.addEventListener(MouseEvent.CLICK, controlerRight);
				mcControl.btnDown.addEventListener(MouseEvent.CLICK, controlerDown);
				mcControl.btnLeft.addEventListener(MouseEvent.CLICK, controlerLeft);
			} else {
				mcControl.visible = false;
			}
			
			//Create all objects
			while (holder.numChildren > 0) {
				holder.removeChildAt(0);
			}
			snakes = new Array();
			food = null;

			// Create snake
			createSnake();
			createFood();
		}

		private function createSnake():void {
			snakeHead = new Head();
			snakeHead.direction = UP;
			snakeHead.x = 360;
			snakeHead.y = 360;
			holder.addChild(snakeHead);

			snakes.push(snakeHead);

			// Create a snake
			for (var i:int = 0; i < 5; i++) {
				var lastSnakeGridDirection:GridDirection = snakes[snakes.length - 1] as GridDirection;
				var snakeBody:GridDirection = new SnakeBody();
				var point:Point = nextPoint(lastSnakeGridDirection.x,lastSnakeGridDirection.y, -  lastSnakeGridDirection.direction);
				snakeBody.direction = lastSnakeGridDirection.direction;
				snakeBody.x = point.x;
				snakeBody.y = point.y;

				holder.addChildAt(snakeBody, 0);
				snakes.push(snakeBody);
			}

			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, inicialPoint);
			stage.addEventListener(MouseEvent.MOUSE_UP, finalPoint);

			//fillGrid();

			Score = 0;
			updateScore(Score);
			timer.addEventListener(TimerEvent.TIMER, move);
			timer.start();
		}

		// Update the image according to the position
		private function move(event:TimerEvent):void {
			if (! gameStarted) {
				return;
			}
			for (var i:int = snakes.length - 1; i >= 0; i--) {
				var snakeGridDirection:GridDirection = snakes[i];
				var point:Point = nextPoint(snakeGridDirection.x,snakeGridDirection.y,snakeGridDirection.direction);
				snakeGridDirection.x = point.x;
				snakeGridDirection.y = point.y;

				if (i > 0) {
					snakeGridDirection.direction = (snakes[i - 1] as GridDirection).direction;
				}
			}
			checkHeadCollision();
		}

		// Check if it is out of the screen
		private function checkHeadCollision():void {
			if (snakeHead.x > APP_WIDTH || snakeHead.x < 0 || snakeHead.y > APP_HEIGHT || snakeHead.y < 0) {
				showGameOver();
			} else if (snakeHead.x == food.x && snakeHead.y == food.y) {
				Score += (10 + Bonus);
				if (optionsSound == "Active"){
					var song:StepSound = new StepSound();
					stepSound = song.play();
				}
				updateScore(Score);
				createFood();// If collided with food

				var lastSnakeGridDirection:GridDirection = snakes[snakes.length - 1] as GridDirection;
				var snakeBody:GridDirection = new SnakeBody();
				var point:Point = nextPoint(lastSnakeGridDirection.x,lastSnakeGridDirection.y, -  lastSnakeGridDirection.direction);
				snakeBody.direction = lastSnakeGridDirection.direction;
				snakeBody.x = point.x;
				snakeBody.y = point.y;

				holder.addChildAt(snakeBody, 0);
				snakes.push(snakeBody);
			} else {
				for (var i:int = 1; i < snakes.length; i++) {
					var snakeGridDirection:GridDirection = snakes[i] as GridDirection;
					if (snakeGridDirection.x == snakeHead.x && snakeGridDirection.y == snakeHead.y) {
						showGameOver();
						break;
					}
				}
			}
		}

		// Show game over
		private function showGameOver():void {
			if (optionsSound == "Active"){
				var song:BitingSound = new BitingSound();
				bitingSound = song.play();
				trace("biting");
			}
			gameStarted = false;
			chronometer.stopTimer();
			dispatchEvent(new Event("GameOver"));
		}

		// Create food with a random position and not on the snake
		private function createFood():void {
			if (food == null) {
				food = new Food();
				holder.addChild(food);
			}

			var randomColor:Number = Math.ceil(Math.random() * 5);
			switch (randomColor) {
				case 1 :
					food.gotoAndPlay("Green");
					Bonus = 0;
					break;
				case 2 :
					food.gotoAndPlay("Blue");
					Bonus = 0;
					break;
				case 3 :
					food.gotoAndPlay("Purple");
					break;
				case 4 :
					food.gotoAndPlay("Black");
					Bonus = 10;
					break;
				case 5 :
					food.gotoAndPlay("Red");
					Bonus = 0;
					break;
				default :
					food.gotoAndPlay("Green");
					Bonus = 0;
					break;
			}

			var column:int = (int)(APP_WIDTH / GRID_LENGTH);
			var row:int = (int)(APP_HEIGHT / GRID_LENGTH);
			var index:int = (int) (Math.random() * column * row);

			while (true) {
				var collide:Boolean = false;
				for (var i:int = 0; i < snakes.length; i++) {
					if (index == (int)((snakes[i] as GridDirection).x / GRID_LENGTH + (snakes[i] as GridDirection).y / GRID_LENGTH * column)) {
						collide = true;
						break;
					}
				}
				if (collide) {
					index = (index + 11) % (column * row);
				} else {
					break;
				}
			}

			food.x = (index % column) * GRID_LENGTH;
			food.y = ((int)(index / column)) * GRID_LENGTH;
		}

		// Get the next position by a given direction
		private function nextPoint(newX:Number, newY:Number, direction:int):Point {
			if (direction == UP) {
				newY -=  GRID_LENGTH;
			} else if (direction == RIGHT) {
				newX +=  GRID_LENGTH;
			} else if (direction == DOWN) {
				newY +=  GRID_LENGTH;
			} else if (direction == LEFT) {
				newX -=  GRID_LENGTH;
			}
			return new Point(newX, newY);
		}

		private function updateScore(Score:int):void {
			if (txtScore == null) {
				myFormat.size = 30;
				myFormat.bold = true;
				myFormat.align = TextFormatAlign.RIGHT;
				myFormat.color = "0x000F7F";
				myFormat.font = myFont.fontName;

					
				txtScore = new TextField();
				txtScore.visible = true;
				txtScore.defaultTextFormat = myFormat;
				txtScore.embedFonts = true;
				txtScore.antiAliasType = AntiAliasType.ADVANCED;
				txtScore.text = (int)(Score);
				txtScore.width = 108.4;
				txtScore.height = 30;
				txtScore.x = -115.5;
				txtScore.y = 237;
				addChild(txtScore);
				
				txtTime = new TextField();
				txtTime.visible = true;
				txtTime.defaultTextFormat = myFormat;
				txtTime.embedFonts = true;
				txtTime.antiAliasType = AntiAliasType.ADVANCED;
				txtTime.text = (int)(Score);
				txtTime.width = 108.4;
				txtTime.height = 30;
				txtTime.x = -115.5;
				txtTime.y = 285;
				addChild(txtTime);
				chronometer = new Chronometer(txtTime);
			} else {
				txtScore.visible = true;
				txtScore.text = (int)(Score);
			}
		}

		private function changeDirection(direction:int):void {
			if (direction !=  -  snakeHead.direction) {
				snakeHead.direction = direction;
			}
		}

		// Keyboard control
		private function KeyDown(event:KeyboardEvent):void {
			var direction:int = RIGHT;

			if (event.keyCode == Keyboard.RIGHT) {
				direction = RIGHT;
			} else if (event.keyCode == Keyboard.DOWN) {
				direction = DOWN;
			} else if (event.keyCode == Keyboard.LEFT) {
				direction = LEFT;
			} else if (event.keyCode == Keyboard.UP) {
				direction = UP;
			}
			changeDirection(direction);
		}
		
		private var dragArea:Rectangle = new Rectangle(0, 0, 733.3, 421.25);
		
		private function controlerStartDrag(event:MouseEvent):void{
			dragging = true;
			mcControl.startDrag(false, dragArea);
		}
 
		private function controlerStopDrag(event:MouseEvent):void{
			mcControl.stopDrag();
		}
		
		private function controlerUp(event:MouseEvent):void{
			dragging = true;
			changeDirection(UP);
		}
		
		private function controlerRight(event:MouseEvent):void{
			dragging = true;
			changeDirection(RIGHT);
		}
		
		private function controlerDown(event:MouseEvent):void{
			dragging = true;
			changeDirection(DOWN);
		}
		
		private function controlerLeft(event:MouseEvent):void{
			dragging = true;
			changeDirection(LEFT);
		}

		//Mouse control
		public function inicialPoint(event:MouseEvent) {
			inicialPointX = event.localX;
			inicialPointY = event.localY;
		}

		public function finalPoint(event:MouseEvent) {
			finalPointX = event.localX;
			finalPointY = event.localY;
			if (!dragging){
				definedDirection(inicialPointX, inicialPointY, finalPointX, finalPointY);
			} else {
				dragging = false;
			}
		}

		private function definedDirection(Xinicial:int, Yinicial:int, Xfinal:int, Yfinal:int):void {

			//(Yc)
			//O        O(Xf,Yf)
			//|       /
			//|      /
			//|     /
			//|    /
			//|   /
			//|  /
			//| /
			//|/_ _ _ _O(Xc)
			//O
			//(Xi,Yi)

			var Xc:Number = Xinicial - Xfinal;
			var Yc:Number = Yinicial - Yfinal;

			//XAumento-YDiminui
			if ((Xinicial < Xfinal) && (Yinicial > Yfinal)) {
				Xc = (Xfinal - Xinicial);
				Yc = (Yinicial - Yfinal);
			}
			//XDiminui-YDiminui
			if ((Xinicial > Xfinal) &&(Yinicial > Yfinal)) {
				Xc = -(Xinicial - Xfinal);
				Yc = (Yinicial - Yfinal);
			}
			//XAumenta-YAumenta
			if ((Xinicial < Xfinal) && (Yinicial < Yfinal)) {
				Xc = (Xfinal - Xinicial);
				Yc = -(Yfinal - Yinicial);
			}
			//XDiminui-YAumenta
			if ((Xinicial > Xfinal) && (Yinicial < Yfinal)) {
				Xc = (Xfinal - Xinicial);
				Yc = -(Yfinal - Yinicial);
			}

			var Angle:Number = (Math.atan(Yc/Xc)*(180/Math.PI));

			if (Xc < 0) {
				Angle +=  180;
			}
			if ((Xc >= 0) && (Yc < 0)) {
				Angle +=  360;
			}

			var newDirection:int = RIGHT;

			if ((Angle > 315) || (Angle <= 45)) {
				newDirection = RIGHT;
			} else if ((Angle > 45) && (Angle <= 135)) {
				newDirection = UP;
			} else if ((Angle > 135) && (Angle <= 225)) {
				newDirection = LEFT;
			} else if ((Angle > 225) && (Angle <= 315)) {
				newDirection = DOWN;
			}

			changeDirection(newDirection);
		}

		public function fillGrid():void {
			size = GRID_LENGTH;
			var matrizWIDTH:int = ((int)(APP_WIDTH / GRID_LENGTH))+1;
			var matrizHEIGHT:int = ((int)(APP_HEIGHT / GRID_LENGTH));
			grid = MakeGridArray(matrizWIDTH);

			for (var i:uint = 0; i < matrizWIDTH; i++) {
				for (var j:uint = 0; j < matrizHEIGHT; j++) {
					var sp:Sprite = new Sprite();
					sp.graphics.beginFill(0xF0F0F0);
					sp.graphics.lineStyle(1,0xF5F5F5);
					sp.graphics.drawRect(0, 0, size  - 1, size - 1);
					sp.x = i * size;
					sp.y = j * size;
					addChildAt(sp,0);
					grid[i][j] = sp;
				}
			}
		}

		private function MakeGridArray(matriz):Array {
			var a:Array = new Array(matriz);
			for (var i:uint = 0; i < a.length; i++) {
				a[i] = new Array(matriz);
			}
			return a;
		}

		public function getScore():int {
			return Score;
		}
		public function getTime():String{
			return (txtTime.text);
		}

	public function traceDL(container:DisplayObjectContainer, options:* = undefined, indentString:String = "", depth:int = 0, childAt:int = 0):void
	{
		if (typeof options == "undefined") options = Number.POSITIVE_INFINITY;
		
		if (depth > options) return;

		const INDENT:String = "   ";
		var i:int = container.numChildren;

		while (i--)
		{
			var child:DisplayObject = container.getChildAt(i);
			var output:String = indentString + (childAt++) + ": " + child.name + " ➔ " + child;

			// debug alpha/visible properties
			output += "\t\talpha: " + child.alpha.toFixed(2) + "/" + child.visible;

			// debug x and y position
			output += ", @: (" + child.x + ", " + child.y + ")";

			// debug transform properties
			output += ", w: " + child.width + "px (" + child.scaleX.toFixed(2) + ")";
			output += ", h: " + child.height + "px (" + child.scaleY.toFixed(2) + ")"; 
			output += ", r: " + child.rotation.toFixed(1) + "°";

			if (typeof options == "number") trace(output);
				else if (typeof options == "string" && output.match(new RegExp(options, "gi")).length != 0)
				{
					trace(output, "in", container.name, "➔", container);
				}

			if (child is DisplayObjectContainer) traceDL(DisplayObjectContainer(child), options, indentString + INDENT, depth + 1);
		}
	}

	}
}