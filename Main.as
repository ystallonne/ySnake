package {
	import com.blackberry.playbook.Snake;
	import com.blackberry.playbook.DBSnake;
	import com.blackberry.playbook.DBOptions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;

	public class Main extends MovieClip {

		private var ySnake:Snake;
		private var yDBSnake:DBSnake;

		private var options:DBOptions;
		private var optionsSound:String;
		private var optionsControl:String;
		private var optionsLevels:String;
		
		public function Main() {
			options = new DBOptions();
			Home();
		}

		public function Home(event:Event = null):void {
			ySnakeHome();
		}

		public function ySnakeHome():void {
			SoundMixer.soundTransform = new SoundTransform(0);		
			if (ySnake != null) {
				ySnake.visible = false;
				ySnake.removeEventListener("GameOver",Records);
			}
			if (yDBSnake != null) {
				yDBSnake.visible = false;
			}
			this.ySnakeInterface.gotoAndStop("Home");
			this.ySnakeInterface.btnClose.addEventListener(MouseEvent.CLICK, Close);
			this.ySnakeInterface.btnPlay.addEventListener(MouseEvent.CLICK, Play);
			this.ySnakeInterface.btnOptions.addEventListener(MouseEvent.CLICK, Options);
			this.ySnakeInterface.btnHelp.addEventListener(MouseEvent.CLICK, Help);
			this.ySnakeInterface.btnLogo.addEventListener(MouseEvent.MOUSE_DOWN, Drag);
		}

		public function Play(event:Event = null):void {
			SoundMixer.soundTransform = new SoundTransform(1);			
			ySnakePlay();
		}

		public function ySnakePlay():void {
			this.ySnakeInterface.gotoAndStop("Play");
			this.ySnakeInterface.btnHome.addEventListener(MouseEvent.CLICK, Home);
			this.ySnakeInterface.txtScore.text = "0";
			this.ySnakeInterface.txtScore.visible = false;
			this.ySnakeInterface.txtTime.text = "0:00:00";
			this.ySnakeInterface.txtTime.visible = false;
			this.ySnakeInterface.mcControl.visible = false;

			ySnake = new Snake(options.getSound(), options.getControl(), options.getLevels());
			ySnake.x = 124;
			ySnake.y = 12;
			ySnake.name = "ySnake";
			stage.addChild(ySnake);
			ySnake.addEventListener("GameOver",Records);
			trace(options.getSound(), options.getControl(), options.getLevels());
		}

		public function Options(event:Event = null):void {
			ySnakeOptions();
		}

		public function ySnakeOptions():void {
			this.ySnakeInterface.gotoAndStop("Options");
			this.ySnakeInterface.btnHome.addEventListener(MouseEvent.CLICK, Home);
			
			var noData:Boolean = false;
			this.ySnakeInterface.btnSound.enabled = false;
			
			/* SOUND */
			if (options.getSound() == "Active"){
				this.ySnakeInterface.btnSound.btnActive.visible = true;
				this.ySnakeInterface.btnSound.btnInactive.visible = false;
			} else if (options.getSound() == "Inactive"){
				this.ySnakeInterface.btnSound.btnActive.visible = false;
				this.ySnakeInterface.btnSound.btnInactive.visible = true;
			} else {
				this.ySnakeInterface.btnSound.btnActive.visible = true;
				this.ySnakeInterface.btnSound.btnInactive.visible = false;
				noData = true;
			}
			
			/* CONTROL */
			if (options.getControl() == "Single"){
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = true;
				this.ySnakeInterface.btnControl.btnGesture.visible = false;
				this.ySnakeInterface.btnControl.btnControl.visible = false;
			} else if (options.getControl() == "Gesture"){
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = false;
				this.ySnakeInterface.btnControl.btnGesture.visible = true;
				this.ySnakeInterface.btnControl.btnControl.visible = false;
			} else if (options.getControl() == "Control"){
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = false;
				this.ySnakeInterface.btnControl.btnGesture.visible = false;
				this.ySnakeInterface.btnControl.btnControl.visible = true;
			} else {
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = true;
				this.ySnakeInterface.btnControl.btnGesture.visible = false;
				this.ySnakeInterface.btnControl.btnControl.visible = false;
				noData = true;
			}
			
			/* LEVEL */
			if (options.getLevels() == "Active"){
				this.ySnakeInterface.btnLevels.btnActive.visible = true;
				this.ySnakeInterface.btnLevels.btnInactive.visible = false;
			} else if (options.getLevels() == "Inactive"){
				this.ySnakeInterface.btnLevels.btnActive.visible = false;
				this.ySnakeInterface.btnLevels.btnInactive.visible = true;
			} else {
				this.ySnakeInterface.btnLevels.btnActive.visible = true;
				this.ySnakeInterface.btnLevels.btnInactive.visible = false;
				noData = true;
			}
			
			if (noData){
				options.setSound("Active");
				options.setControl("Single");
				options.setLevels("Active");
				options.insertToDatabase();
				noData = false;
			}

			this.ySnakeInterface.btnSound.addEventListener(MouseEvent.CLICK, ySnakeOptionsSound);
			this.ySnakeInterface.btnControl.addEventListener(MouseEvent.CLICK, ySnakeOptionsControl);
			this.ySnakeInterface.btnLevels.addEventListener(MouseEvent.CLICK, ySnakeOptionsLevels);
		}

		public function ySnakeOptionsSound(Event:MouseEvent):void {
			trace("Sound");
			if (options.getSound() == "Active"){
				this.ySnakeInterface.btnSound.btnActive.visible = false;
				this.ySnakeInterface.btnSound.btnInactive.visible = true;
				options.setSound("Inactive");
			}else {
				this.ySnakeInterface.btnSound.btnActive.visible = true;
				this.ySnakeInterface.btnSound.btnInactive.visible = false;
				options.setSound("Active");
			}
			options.updateToDatabase();
		}

		public function ySnakeOptionsControl(Event:MouseEvent):void {
			trace("Control");
			if (options.getControl() == "Single"){
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = false;
				this.ySnakeInterface.btnControl.btnGesture.visible = true;
				this.ySnakeInterface.btnControl.btnControl.visible = false;
				options.setControl("Gesture");
			} else if (options.getControl() == "Gesture"){
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = false;
				this.ySnakeInterface.btnControl.btnGesture.visible = false;
				this.ySnakeInterface.btnControl.btnControl.visible = true;
				options.setControl("Control");
			} else {
				this.ySnakeInterface.btnControl.btnSingleTouch.visible = true;
				this.ySnakeInterface.btnControl.btnGesture.visible = false;
				this.ySnakeInterface.btnControl.btnControl.visible = false;
				options.setControl("Single");
			}
			trace(options.getControl());
			options.updateToDatabase();
		}

		public function ySnakeOptionsLevels(Event:MouseEvent):void {
			trace("Levels");
			if (options.getLevels() == "Active"){
				this.ySnakeInterface.btnLevels.btnActive.visible = false;
				this.ySnakeInterface.btnLevels.btnInactive.visible = true;
				options.setLevels("Inactive");
			} else {
				this.ySnakeInterface.btnLevels.btnActive.visible = true;
				this.ySnakeInterface.btnLevels.btnInactive.visible = false;
				options.setLevels("Active");
			}
			options.updateToDatabase();
		}

		public function Help(Event:MouseEvent = null):void {
			ySnakeHelp();
		}

		public function ySnakeHelp():void {
			this.ySnakeInterface.gotoAndStop("Help");
			this.ySnakeInterface.btnHome.addEventListener(MouseEvent.CLICK, Home);
		}

		public function Records(event:Event = null) {
			ySnakeRecords();
		}

		public function ySnakeRecords():void {
			var Score:Number = ySnake.getScore();
			var Time:String = ySnake.getTime();
			stage.removeChild(ySnake);

			//Records
			yDBSnake = new DBSnake();
			yDBSnake.x = 0;
			yDBSnake.y = 119.95;
			yDBSnake.name = "yDBSnake";
			stage.addChild(yDBSnake);
			yDBSnake.readScore(Score, Time);
			
			this.ySnakeInterface.gotoAndStop("Records");
			this.ySnakeInterface.btnHome.addEventListener(MouseEvent.CLICK, Home);
		}

		public function Close(Event:MouseEvent):void {
			NativeApplication.nativeApplication.exit();
		}

		public function Drag(Event:MouseEvent):void {
			this.stage.nativeWindow.startMove();
		}
		
		public function Minimize(Event:MouseEvent):void {
			this.stage.nativeWindow.minimize();
		}
	}
}