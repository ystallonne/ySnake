package com.blackberry.playbook{
	import flash.data.SQLConnection;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Sprite;
	import flash.events.Event;

	public class DBOptions {

		private var conn:SQLConnection = new SQLConnection();
		private var dbFile:File = File.applicationDirectory.resolvePath("ySnakeOptions.db");

		private var sound:String = "";
		private var control:String = "";
		private var levels:String = "";

		public function DBOptions() {
			conn.addEventListener(SQLEvent.OPEN,openHandler);
			conn.open(dbFile);
		}

		public function openHandler(event:SQLEvent):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "CREATE TABLE IF NOT EXISTS options (id INTEGER PRIMARY KEY AUTOINCREMENT, sound TEXT, control TEXT, levels TEXT)";
			sql.addEventListener(SQLEvent.RESULT, retrieveData);
			sql.execute();
		}

		public function retrieveData(event:SQLEvent=null):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "SELECT * FROM options ORDER BY id";
			sql.addEventListener(SQLEvent.RESULT, populateData);
			sql.execute();
		}

		public function populateData(event:SQLEvent):void {
			var result:SQLResult = event.target.getResult();
			if (result != null && result.data != null) {
				this.sound = String(result.data[0].sound);
				this.control = String(result.data[0].control);
				this.levels = String(result.data[0].levels);
			}
		}

		public function insertToDatabase(event:SQLEvent=null):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "INSERT INTO options(sound, control, levels)VALUES(@sound, @control, @levels)";
			sql.parameters["@sound"] = this.getSound();
			sql.parameters["@control"] = this.getControl();
			sql.parameters["@levels"] = this.getLevels();
			sql.addEventListener(SQLEvent.RESULT, retrieveData);
			sql.execute();
		}

		public function updateToDatabase(event:SQLEvent=null):void {
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection = conn;
			sql.text = "UPDATE options SET sound = @sound, control = @control, levels = @levels WHERE id = 1";
			sql.parameters["@sound"] = this.getSound();
			sql.parameters["@control"] = this.getControl();
			sql.parameters["@levels"] = this.getLevels();
			sql.addEventListener(SQLEvent.RESULT, retrieveData);
			sql.execute();
			trace("som " + this.getSound() + " control " + this.getControl() + " level " + this.getLevels()); 
		}

		public function getSound():String {
			return sound;
		}

		public function setSound(OptionsSound:String):void {
			sound = OptionsSound;
		}

		public function getControl():String {
			return control;
		}

		public function setControl(OptionsControl:String):void {
			control = OptionsControl;
		}

		public function getLevels():String {
			return levels;
		}

		public function setLevels(OptionsLevels:String):void {
			levels = OptionsLevels;
		}
	}
}