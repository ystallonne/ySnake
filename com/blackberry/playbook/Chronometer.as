package com.blackberry.playbook{

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class Chronometer {

		public var txtChronometer:TextField;
		private var timer:Timer;
		private var inicialTime:Date;
		private var timePauseBegin:Date;
		private var pausedTime:int;

		public function Chronometer(text:TextField):void {
			txtChronometer = text;
			startTimer();
		}
		public function startTimer():void {
			txtChronometer.text = "0:00:00";
			inicialTime = new Date();
			pausedTime = 0;

			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, update);
			timer.start();
		}
		public function stopTimer():void {
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer.stop();
		}
		public function pauseTimer():void {
			stopTimer();
			timePauseBegin = new Date();
		}
		public function restartTimer():void {
			var currentTime:Date = new Date();
			pausedTime += (currentTime.getTime() - timePauseBegin.getTime()) / 1000;

			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, update);
			timer.start();
		}
		private function update(event:TimerEvent):void {
			var currentTime:Date = new Date();
			var totalTime:int = ((currentTime.getTime() - inicialTime.getTime()) / 1000);
			totalTime -=  pausedTime;
			var hours:int = totalTime / 3600;
			totalTime -= hours * 3600;
			var minutes:int = (totalTime / 60);
			var seconds:int = totalTime % 60;

			txtChronometer.text = ((String(hours)) + ":" + (((minutes <= 9) ? ("0"+String(minutes)): (String(minutes)))) + ":" +	(((seconds <= 9) ? ("0"+String(seconds)): (String(seconds)))));
		}
	}
}