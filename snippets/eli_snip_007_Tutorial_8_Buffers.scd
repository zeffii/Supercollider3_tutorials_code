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


