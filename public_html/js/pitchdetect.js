/*
The MIT License (MIT)

Copyright (c) 2014 Chris Wilson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

window.AudioContext = window.AudioContext || window.webkitAudioContext;

var audioContext = new AudioContext();
var analyser = null;
var detectorElem, 
	canvasElem,
	pitchElem,
	noteElem;


window.onload = function() {
	detectorElem = document.getElementById( "detector" );
	pitchElem = document.getElementById( "pitch" );
	noteElem = document.getElementById( "note" );
}


function error() {
    alert('Stream generation failed.');
}


function getUserMedia(dictionary, callback) {
    try {
        navigator.getUserMedia = 
        	navigator.getUserMedia ||
        	navigator.webkitGetUserMedia ||
        	navigator.mozGetUserMedia;
        navigator.getUserMedia(dictionary, callback, error);
    } catch (e) {
        alert('getUserMedia threw exception :' + e);
    }
}


function gotStream(stream) {
    // Create an AudioNode from the stream.
    var mediaStreamSource = audioContext.createMediaStreamSource(stream);

    // Connect it to the destination.
    analyser = audioContext.createAnalyser();
    analyser.fftSize = 2048;
    mediaStreamSource.connect( analyser );
    updatePitch();
}


function toggleLiveInput() {
    getUserMedia({audio:true}, gotStream);
}


var rafID = null;
var tracks = null;
var buflen = 2048;
var buf = new Uint8Array( buflen );
var MINVAL = 134;  // 128 == zero.  MINVAL is the "minimum detected signal" level.

var noteStrings = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];


function noteFromPitch( frequency ) {
	var noteNum = 12 * (Math.log( frequency / 440 )/Math.log(2) );
	return Math.round( noteNum ) + 69;
}


function autoCorrelate( buf, sampleRate ) {
	var MIN_SAMPLES = 4;	// corresponds to an 11kHz signal
	var MAX_SAMPLES = 1000; // corresponds to a 44Hz signal
	var SIZE = 1000;
	var best_offset = -1;
	var best_correlation = 0;
	var rms = 0;
	var foundGoodCorrelation = false;

	if (buf.length < (SIZE + MAX_SAMPLES - MIN_SAMPLES))
		return -1;  // Not enough data

	for (var i=0;i<SIZE;i++) {
		var val = (buf[i] - 128)/128;
		rms += val*val;
	}
	rms = Math.sqrt(rms/SIZE);
	if (rms<0.01)
		return -1;

	var lastCorrelation=1;
	for (var offset = MIN_SAMPLES; offset <= MAX_SAMPLES; offset++) {
		var correlation = 0;

		for (var i=0; i<SIZE; i++) {
			correlation += Math.abs(((buf[i] - 128)/128)-((buf[i+offset] - 128)/128));
		}
		correlation = 1 - (correlation/SIZE);
		if ((correlation>0.9) && (correlation > lastCorrelation))
			foundGoodCorrelation = true;
		else if (foundGoodCorrelation) {
			// short-circuit - we found a good correlation, then a bad one, so we'd just be seeing copies from here.
			return sampleRate/best_offset;
		}
		lastCorrelation = correlation;
		if (correlation > best_correlation) {
			best_correlation = correlation;
			best_offset = offset;
		}
	}
	if (best_correlation > 0.01) {
		// console.log("f = " + sampleRate/best_offset + "Hz (rms: " + rms + " confidence: " + best_correlation + ")")
		return sampleRate/best_offset;
	}
	return -1;
//	var best_frequency = sampleRate/best_offset;
}


function updatePitch( time ) {
	var cycles = new Array;
	analyser.getByteTimeDomainData( buf );

	var ac = autoCorrelate( buf, audioContext.sampleRate );

 	if (ac == -1) {
	 	pitchElem.innerText = "--";
		noteElem.innerText = "--";
 	} else {
	 	pitch = ac;
	 	pitchElem.innerText = Math.floor( pitch ) ;
	 	var note =  noteFromPitch( pitch );
		noteElem.innerHTML = noteStrings[note%12];
	}
    updateNoteSequence();

	if (!window.requestAnimationFrame)
		window.requestAnimationFrame = window.webkitRequestAnimationFrame;
	rafID = window.requestAnimationFrame( updatePitch );
}
