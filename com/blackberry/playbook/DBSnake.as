package com.blackberry.playbook{
	import flash.data.SQLConnection;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.ui.Keyboard;
	import flash.display.SimpleButton;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.FocusEvent;
	import com.blackberry.playbook.Snake;

	public class DBSnake extends MovieClip {

		private var conn:SQLConnection = new SQLConnection();
		private var dbFile:File = File.applicationDirectory.resolvePath("ySnake.db");

		private var smallestRecordScoreID:Number = 0;
		private var smallestRecordScore:Number = 0;
		private var pontuationPlayer:Number = 0;
		private var recordsTotal:Number = 0;

		public function DBSnake() {
			conn.addEventListener(SQLEvent.OPEN,openHandler);
			conn.open(dbFile);

			this.recordsTable.visible = false;
			this.recordsBox.visible = true;
			this.recordsBox.txtName.restrict = "^0-9";
			this.recordsBox.txtName.tabEnabled = true;
			this.recordsBox.txtName.focusRect = true;
			this.recordsBox.txtTime.restrict = "0-9 :";
			this.recordsBox.txtScore.restrict = "0-9";
			this.recordsBox.txtName.tabEnabled = true;
			this.recordsBox.txtName.tabIndex = 0;
			this.recordsBox.txtName.text = "Name";

			//this.recordsBox.txtName.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			//this.recordsBox.txtName.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);

			this.recordsBox.btnSubmit.addEventListener(MouseEvent.CLICK, insertToDatabase);
			this.recordsTable.btnClear.addEventListener(MouseEvent.CLICK, clearAllRecords);
		}


		private function onFocusOut(e:FocusEvent):void {
			if (this.recordsBox.txtName.text == '') {
				this.recordsBox.txtName.text = "Name";
			}
		}

		private function onMouseEvent(e:MouseEvent):void {
			if (this.recordsBox.txtName.text != '' && this.recordsBox.txtName.text != "Name") {
				this.recordsBox.txtName.text = this.recordsBox.txtName.text;
			} else {
				this.recordsBox.txtName.text = '';
			}
		}

		public function openHandler(event:SQLEvent):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "CREATE TABLE IF NOT EXISTS records(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, time TEXT, score INTEGER, timescore LONG)";
			sql.addEventListener(SQLEvent.RESULT, retrieveData);
			sql.execute();
		}

		public function retrieveData(event:SQLEvent=null):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT * FROM records ORDER BY score DESC, timescore LIMIT 5";
			sql.addEventListener(SQLEvent.RESULT, populateData);
			sql.execute();
		}

		public function populateData(event:SQLEvent):void {
			clearText();

			var result:SQLResult = event.target.getResult();
			if (result != null && result.data != null) {
				for (var i:Number = 0; i < result.data.length; i++) {
					if (i == 0) {
						this.recordsTable.name01.text = String(result.data[i].name);
						this.recordsTable.time01.text = String(result.data[i].time);
						this.recordsTable.score01.text = String(result.data[i].score);
					}
					if (i == 1) {
						this.recordsTable.name02.text = String(result.data[i].name);
						this.recordsTable.time02.text = String(result.data[i].time);
						this.recordsTable.score02.text = String(result.data[i].score);
					}
					if (i == 2) {
						this.recordsTable.name03.text = String(result.data[i].name);
						this.recordsTable.time03.text = String(result.data[i].time);
						this.recordsTable.score03.text = String(result.data[i].score);
					}
					if (i == 3) {
						this.recordsTable.name04.text = String(result.data[i].name);
						this.recordsTable.time04.text = String(result.data[i].time);
						this.recordsTable.score04.text = String(result.data[i].score);
					}
					if (i == 4) {
						this.recordsTable.name05.text = String(result.data[i].name);
						this.recordsTable.time05.text = String(result.data[i].time);
						this.recordsTable.score05.text = String(result.data[i].score);
					}
				}
			}
		}

		public function readScore(Score:Number, Time:String) {
			pontuationPlayer = Score;
			clearInputText();
			this.recordsBox.txtScore.text = String(Score);
			this.recordsBox.txtTime.text = Time;

			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT id, MIN(score) as SmallestScore FROM (SELECT * FROM records ORDER BY score DESC, timescore LIMIT 5)";
			sql.addEventListener(SQLEvent.RESULT, scoreVerification);
			sql.execute();
		}

		public function scoreVerification(event:SQLEvent):void {
			var result:SQLResult = event.target.getResult();
			if (result != null && result.data != null) {
				for (var i:Number = 0; i < result.data.length; i++) {
					smallestRecordScoreID = Number(result.data[i].id);
					smallestRecordScore = Number(result.data[i].SmallestScore);
				}
			}

			totalRecordsScore();

			trace("total " + recordsTotal);
			trace("small " + smallestRecordScore);
			trace("player " + pontuationPlayer);

			if (pontuationPlayer == 0) {
				this.recordsTable.visible = true;
				this.recordsBox.visible = false;
			} else if (pontuationPlayer <= smallestRecordScore) {
				if (recordsTotal >= 5) {
					this.recordsTable.visible = true;
					this.recordsBox.visible = false;
				} else {
					this.recordsTable.visible = false;
					this.recordsBox.visible = true;
				}
			} else {
				this.recordsTable.visible = false;
				this.recordsBox.visible = true;
			}
		}

		public function totalRecordsScore(event:SQLEvent=null) {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT * FROM records";
			sql.addEventListener(SQLEvent.RESULT, recordsNumber);
			sql.execute();
		}

		public function recordsNumber(event:SQLEvent) {
			var result:SQLResult = event.target.getResult();
			if (result != null && result.data != null) {
				recordsTotal = Number(result.data.length);
				if (recordsTotal > 5) {
					clearDataBase();
				}
			}
		}

		public function insertToDatabase(event:MouseEvent) {
			if (this.recordsBox.txtName.text != "" && this.recordsBox.txtTime.text != "" && this.recordsBox.txtScore.text != "") {
				this.recordsBox.visible = false;
				var timescore:String = (((this.recordsBox.txtTime.text).substr(0,1))+((this.recordsBox.txtTime.text).substr(2,2))+((this.recordsBox.txtTime.text).substr(5,2)));
				var sql:SQLStatement = new SQLStatement();
				sql.sqlConnection = conn;
				sql.text = "INSERT INTO records(name, time, score, timescore) VALUES(@name, @time, @score, @timescore)";
				sql.parameters["@name"] = this.recordsBox.txtName.text;
				sql.parameters["@time"] = this.recordsBox.txtTime.text;
				sql.parameters["@score"] = int(this.recordsBox.txtScore.text);
				sql.parameters["@timescore"] = int(timescore);
				sql.addEventListener(SQLEvent.RESULT, retrieveData);
				sql.execute();

				this.recordsTable.visible = true;
				clearDataBase();
			}
		}

		public function clearDataBase() {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT * FROM records";
			sql.addEventListener(SQLEvent.RESULT, deleteVerification);
			sql.execute();
		}

		public function deleteVerification(event:SQLEvent) {
			var result:SQLResult = event.target.getResult();
			if ((result != null) && (result.data != null)) {
				if (result.data.length > 5) {
					var sql:SQLStatement = new SQLStatement();
					sql.sqlConnection = conn;
					sql.text = "DELETE FROM records WHERE id=(SELECT id FROM records ORDER BY score, id DESC LIMIT 1)";
					sql.execute();
				}
			}
		}

		public function clearAllRecords(event:MouseEvent) {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT * FROM records";
			sql.addEventListener(SQLEvent.RESULT, deleteAllRecords);
			sql.execute();
		}

		public function deleteAllRecords(event:SQLEvent) {
			var result:SQLResult = event.target.getResult();
			if ((result != null) && (result.data != null)) {
				var sql:SQLStatement = new SQLStatement();
				sql.sqlConnection = conn;
				sql.text = "DELETE FROM records";
				sql.addEventListener(SQLEvent.RESULT, retrieveData);
				sql.execute();
			}
		}

		public function clearText() {
			this.recordsTable.name01.text = "";
			this.recordsTable.time01.text = "";
			this.recordsTable.score01.text = "";

			this.recordsTable.name02.text = "";
			this.recordsTable.time02.text = "";
			this.recordsTable.score02.text = "";

			this.recordsTable.name03.text = "";
			this.recordsTable.time03.text = "";
			this.recordsTable.score03.text = "";

			this.recordsTable.name04.text = "";
			this.recordsTable.time04.text = "";
			this.recordsTable.score04.text = "";

			this.recordsTable.name05.text = "";
			this.recordsTable.time05.text = "";
			this.recordsTable.score05.text = "";
		}

		public function clearInputText() {
			this.recordsBox.txtName.text = "";
			this.recordsBox.txtTime.text = "";
			this.recordsBox.txtScore.text = "";
		}
	}
}