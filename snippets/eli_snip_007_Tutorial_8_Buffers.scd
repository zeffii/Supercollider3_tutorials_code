// tut8 Buffers

s.boot;

/*
        1. Basics of Adding and Removing Buffers

        - files can be aiff or wav
        - drag a folder or file to sc editor window to get the correct path
*/

// watch the post window to see if the file was found.
~b0 = Buffer.read(s, "/full/path/to/sound.extention");

// simple way to verify file was loaded
~b0.play;


/*
        1.1 To clear or remove a buffer
*/

// clear
~b0.zero;    // makes the buffer empty
             // the allocated buffer is still on the server

// to fill the buffer object with sound again
~b0.read("/full/path/to/sound.extention");
~b0.play;

// remove
~b0.free;    // won't allow ~b0.read() anymore as ~b0 will be dereferenced

// to free all Buffers, use the classmethod.
Buffer.freeAll;

////////////////////////////////////////////////////////////////////////////////////////

/*
        2. Fundamental attributes of Buffers

        - Every Buffer has certain number of frames, channels and samples
        - Buffers can have any number of channels
        - numSamples = numframes * numChannels
*/

// Frames, Channels
~b0.numFrames;
~b0.numChannels;

// make monochannel buffer from a multichannel soundfile.
// "left" [0]
~b4 = Buffer.readChannel(s, "/full/path/to/sound.extention", channels:[0]);
// "right" [1]
~b4 = Buffer.readChannel(s, "/full/path/to/sound.extention", channels:[1]);

// show channels
s.meter;
~b0.play;  // will play two channels if sound file had 2 channels when loading
~b4.play;  // will play sound on channel one. ~b4 is a single channel buffer.
           // because readChannel function argument specified channels:[index]

// Length of Buffer in seconds
~b0.duration;

// Buffer Numbers
// Each buffer on the server has a unique integer associated with it
// 'bufnums'  0...n , automatically assigned in ascending order
~b0.bufnum;

// Buffer Sample Rate
~b0.sampleRate;
s.sampleRate;

// Summary
~b0.query;


/*
        2.1 Loading parts of a soundfile.

*/

~b0.play;
~b1_part0 = Buffer.read(
	s,
	"/full/path/to/sound.extention",
	0,                           // start at frame 0
    numFrames: s.sampleRate/2);  // half a second

~b1_part0.play;
~b1_part0.numFrames;

// reading a set number of frames, starting with offset and loading to the end.
~b1_part1 = Buffer.read(
	s,
	"/full/path/to/sound.extention",
	222000,
	numFrames: ~b0.numFrames - (222000+1)); // avoids off by one, explicitely.


////////////////////////////////////////////////////////////////////////////////////////

/*
        2.2 Loading many sound files at once

        - lots of ways to do this, most involve iteration
        - store buffer in array

*/

~bells = Array.new;

// hold a reference to a folder
~folder = PathName.new("/full/path/to/");

// return a list of filenames of all files in that folder (inclucing non sound)
~folder.entries;

// this is my folder with sounds..store a reference to the string (optional)
~rawfolder = "C:/Users/dealga/Desktop/code/supercollider/sounds"
// iterate over the entires
~folder = PathName.new(~rawfolder);
~folder.entries;

//using parens here just to be able to execute the whole thing in one go.
(
~folder.entries.do{
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));  //this concatenates ~folder + path
}
)

// I have 3 sounds in this directory, so prove that the above code loaded them into the Array.
~bells;  // will show the array in the postwindow

~bells.at(0).play;
~bells.at(1).play;
~bells.at(2).play;

// this also works, square bracket.
~bells[0].play;
~bells[1].play;
~bells[2].play;

// the limit to the number of buffers you can load onto the server is found by
s.options.numBuffers;   // 1024

// to change
s.options.numBuffers = 2000;   // requires a reboot of the server.

////////////////////////////////////////////////////////////////////////////////////////

/*
        3. Manipulation Buffers with Ugens.

        two ugens
        - PlayBuf: will read automatically through a buffer at a given playback rate
        - BufRd  : doesn't have a rate argument. relies on an audio rate pointer into the buffer
                   for sample playback

*/

// PlayBuf,  needs to know at minimum 1) channels and 2) Buffer number
// ||||||| num channels in the playbuf can not be modulated ||||||||| but you can switch out
// which buffer you want to play.
(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf;  // making buf allows the SynthDef to play different samples.
	var sig;
	sig = PlayBuf.ar(2, buf);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// i'm loading from array, but it could be a `~b0` too
Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum]);
Synth.new(\playbuf_test, [\buf, ~bells[1].bufnum]);

// the default behaviour is doneAction:0  sit on the last frame of the sample when done playing,
// this doesn't let the synth free itself after playing, we might want to specify a specific doneAction
// notice in the above example that the last output sample is what is shows in the s.meter, like frozen.

// fresh start, might do a s.reboot first..
s.reboot;
~bells = Array.new;
~rawfolder = "C:/Users/dealga/Desktop/code/supercollider/sounds"
~folder = PathName.new(~rawfolder);
(
~folder.entries.do{
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));  //this concatenates ~folder + path
}
)

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, da=2;  // da = done action, will default to 2 now. and let go of the buffer
	var sig;
	sig = PlayBuf.ar(2, buf, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum]);
Synth.new(\playbuf_test, [\buf, ~bells[1].bufnum]);

// /////////

// rate!!!
(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, rate, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, 2]);
Synth.new(\playbuf_test, [\buf, ~bells[1].bufnum, \rate, 1.2]);

// warning: specify rate with number is not foolproof if bufsamprate is
// different from serversamprate. It will be resampled, and you'll get
// the same played back at a pitch that you might not expect for rate==1.
// (sample with higher sample rate that serverrate will sound like its
// playing back slower) - reasons obvious.

// luckly there are Ugens that do this converting for us. Buffer->Info
// one ugen called 'BufRateScale' outputs a ratio based on server
// and buffer sample rate

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, da=2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, 2]);
Synth.new(\playbuf_test, [\buf, ~bells[1].bufnum, \rate, 1.2]);

// this synth will start half second into the sample and won't free itself at the end

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, da=2;
	var sig;
	sig = PlayBuf.ar(
		2,
		buf,
		BufRateScale.kr(buf) * rate,
		t_trig,
		start,
		doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// note how s.meter is frozen on the last output sample
x = Synth.new(\playbuf_test, [\buf, ~bells[2].bufnum, \start, s.sampleRate/2, \da, 0]);

// jump to start position like
x.set(\t_trig, 1);

////
///  looop!  will play through the buffer and ignore the doneAction.
////

// make sure all buffs you are about to reference are loaded

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, loop=0, da=2;
	var sig;
	sig = PlayBuf.ar(
		2,
		buf,
		BufRateScale.kr(buf) * rate,
		t_trig,
		start,
		loop,
		doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// note how s.meter is frozen on the last output sample
x = Synth.new(\playbuf_test, [\buf, ~bells[2].bufnum, \loop, 1]);

// jump to start position like
x.set(\t_trig, 1);
x.free;

// playing backward... negative rate, \start at the end
(
x = Synth.new(\playbuf_test, [
	\buf, ~bells[2].bufnum,
	\rate, -1,
	\start, ~bells[2].numFrames -2   // else doneAction is called. if -1
]);
)
x.free;


////////////////////////////////////////////////////////////////////////////////////////

/*
       4 Rate, declared as semitones instead of ratio.

       - using a Ugen again to calculate ratio in just intonation relative to the buffer sample rate.

       12.midiratio //   = 1.9999999999
       5.midiratio //  1.33

*/
(
x = Synth.new(\playbuf_test, [
	\buf, ~bells[2].bufnum,
	\rate, 12.midiratio,  // or could code the SynthDef to take 12 directly so we don't have
	                      // to specify the extra .midiratio every time.
]);
)

// elaborate example

~bells = Array.new;
~rawfolder = "C:/Users/dealga/Desktop/code/supercollider/sounds3";   // actual bells
~folder = PathName.new(~rawfolder);
(
~folder.entries.do{
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));  //this concatenates ~folder + path
}
)

(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, t_trig=1, start=0, loop=0, da=2;
	var sig;
	sig = PlayBuf.ar(
		2,
		buf,
		BufRateScale.kr(buf) * rate,
		t_trig,
		start,
		loop,
		doneAction:da);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

s.plotTree;
g = Group.new;

(
// 3 synths with different buffers and different playback rates
// target --> g
x = Synth.new(\playbuf_test, [\buf, ~bells[0].bufnum, \rate, 1.5, \loop, 1, \amp, 0.5], g);
y = Synth.new(\playbuf_test, [\buf, ~bells[1].bufnum, \rate, 1.9, \loop, 1, \amp, 0.5], g);
z = Synth.new(\playbuf_test, [\buf, ~bells[2].bufnum, \rate, 1.23, \loop, 1, \amp, 0.5], g);

)

// one can change the \rate of all synths in the group
g.set(\rate, 0.6);
// could also set all three synths to play the same buffer
g.set(\buf, ~bells[2].bufnum);

// or send individual rates, picked from exprand
g.set(\rate, exprand(0.2, 2.0));

// the individual nodes can still be accessed using x,y and z
z.set(\rate, 0.2);

// lastly turn off looping for all three synths
g.set(\loop, 0);

g.free; // if you need


////////////////////////////////////////////////////////////////////////////////////////


/*
         5 BufRd

         - starts with the same two arguments as PlayBuf (numChannels, bufNum)
         - 3rd argument must be an audio rate signal `.ar`

*/

// just load one sound
~fullpath = "C:/Users/dealga/Desktop/code/supercollider/sounds/snap_miller.wav"; // pd
~b5 = Buffer.read(s, ~fullpath);

(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf;
	var sig, ptr;
	ptr = Line.ar(
		0,
		BufFrames.kr(buf)-1,
		BufDur.kr(buf),
		doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_test, [\buf, ~b5.bufnum]);

// but maybe we want some flexibility where line starts and ends!
// so..declare some arguments!

~fullpath = "C:/Users/dealga/Desktop/code/supercollider/sounds/snap_miller.wav"; // pd
~b5 = Buffer.read(s, ~fullpath);

(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start, end;
	var sig, ptr;
	ptr = Line.ar(
		start,
		end,
		BufDur.kr(buf),
		doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// now can play forward (select all 5 lines and execute)
Synth.new(\bufrd_test, [
	\buf, ~b5.bufnum,
	\start, 0,
	\end, ~b5.numFrames-1
]);

// or backward
Synth.new(\bufrd_test, [
	\buf, ~b5.bufnum,
	\start, ~b5.numFrames-1,
	\end, 0
]);

// what if we want to loop? we choose phaser.
// it's a linear ramp oscillator with inputs for [start, end, rate]

~fullpath = "C:/Users/dealga/Desktop/code/supercollider/sounds/snap_miller.wav"; // pd
~b5 = Buffer.read(s, ~fullpath);

(
SynthDef.new(\bufrd_loop, {
	arg amp=1, out=0, buf, start, end, rate=1;
	var sig, ptr;
	ptr = Phasor.ar(
		0, //trig
		BufRateScale.kr(buf) * rate,
		start,
		end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\bufrd_loop, [\buf, ~b5.bufnum, \start, 0, \end, ~b5.numFrames-1]);

x.set(\start, ~b5.numFrames/2, \end, ~b5.numFrames-1); // relative to the sample
x.set(\start, 200, \end, 2000);                        // exact into the sample
x.set(\rate, -7.midiratio);                            // rate via midi ratio

x.free;

///// There are other ways to get through a Buf   `Sweep and LFSaw`

// or SinOsc :) as long as the ugen outputs the appropriate range

~fullpath = "C:/Users/dealga/Desktop/code/supercollider/sounds/original_ride.wav"; // pd
~b5 = Buffer.read(s, ~fullpath);

(
SynthDef.new(\bufrd_sine, {
	arg amp=1, out=0, buf, start, end, freq=1;
	var sig, ptr;
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// like a turntable finger release.
x = Synth.new(\bufrd_sine, [\buf, ~b5.bufnum, \start, 0, \end, ~b5.numFrames-1, \freq, 0.2]);
x.free;

///////// or use Noise to select sections to play and different frequencies and rate (neg or pos)

(
SynthDef.new(\bufrd_noise, {
	arg amp=1, out=0, buf, start, end, freq=1;
	var sig, ptr;
	ptr = LFDNoise1.ar(freq).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// every second it will play at different location and rate of rate=1,  2=double change etc.
x = Synth.new(\bufrd_noise, [\buf, ~b5.bufnum, \start, 0, \end, ~b5.numFrames-1, \freq, 1]);
x.free;

// with different samples + synths one might layer these effects for a rich texture
// higher \freq will mean the playback head will jump sooner and create a more glitchy sound.
w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.7, \amp. 0.9]);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 1.1, \amp. 0.8]);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 1.3, \amp. 0.7]);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 0.9, \amp. 0.5]);

// or add to group, to set all \freq simultaneously
g = Group.new;
w = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 3.7, \amp. 0.9], g);
x = Synth.new(\bufrd_noise, [\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 4.1, \amp. 0.8], g);
y = Synth.new(\bufrd_noise, [\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 5.3, \amp. 0.7], g);
z = Synth.new(\bufrd_noise, [\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 3.9, \amp. 0.5], g);

g.set(\freq, 200);

// Experiment with RecordBuf and BufWr (write)


