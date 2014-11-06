/*

       SuperCollider Tutorial: 9. MIDI
       https://www.youtube.com/watch?v=Oz4KYZ9KLc0

       the basics of getting SC to interpret MIDI
       read guides: 'Using MIDI' and 'MIDI'

*/

s.boot;

// ask your OS, see postwindow, what midi devices are connected to your HW.
MIDIClient.init;

// Easiest way to connect, connects to all available devices
MIDIIn.connectAll;

// but you can connect explicitely
MIDIClient.sources;  //gets array of available
MIDIIn.connect(index in above array);

// just like with Synths we can use a class to register an action to be taken
// when a certain type of midi message is received. MIDIdef and MIDIfunc.
// MIDIdef is a subclass of MIDIFunc, they both expose very similar functionality.
// We'll focus on MIDIdef only.


/*
       1. Create a MIDIDef to respond to noteOn.
*/

MIDIClient.init;
MIDIIn.connectAll;

// print the message 'key down' on each new .noteOn
MIDIdef.noteOn(\noteOnTest, {'key down'.postln});

// MIDIdefs are destroyed by pressing ctrl+. / cmd+. (by default)
// to add some permanency set the permanent_ attribute
MIDIdef.noteOn(\noteOnTest, {'key down'.postln}).permanent_(true);

// remove permanency later, by setting the attr to false
MIDIdef(\noteOnTest).permanent_(false);

// to free a named MIDIdef
MIDIdef(\noteOnTest).free;

// to free all MIDIdefs at once
MIDIdef.freeAll;


/*
       1.1 Get SC to print MIDI note number, velocity, midichannel.

*/

// it's good to first inspect what kind of data you are getting when you hit the midi device key/pad
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn, chan, src].postln
});
)

/*
  for every single key I press I get two messages in sequence.
  [ 78, 50, 0, 1 ]
  [ 78, 50, 0, 2 ]

  Eli shows in the video that this is not the case for him, but he does have a similar issue
  lateron with pitchbend being sent 3 times for each event. (coming from different channels but the
  same source).

  We can filter, or we can connect to the device by index.

  MIDIClient.init;
  MIDIClient.sources;
  MIDIIn.connect(1);

  now if i hit 5 keys: 5 unique messages
  [ 25, 62, 0, 1 ]
  [ 36, 59, 0, 1 ]
  [ 21, 57, 0, 1 ]
  [ 16, 59, 0, 1 ]
  [ 21, 62, 0, 1 ]

*/

// we only need velocity and note.. for now
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
});
)

// let's trigger a SinOsc Ugen from inside the MIDIdef to get our first sounds

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;      // optional for showing, handy for debug
	{
		var sig, env;
		sig = SinOsc.ar(nn.midicps)!2;                    // two channel SinOsc with freq nn converted
		env = EnvGen.kr(Env.perc, doneAction:2);          // let go once done
		sig = sig * env * vel.linexp(1, 127, 0.01, 0.3);  // vel remapped to sane signal values
	}.play;
});
)

// how about a Triangle wave
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	{
		var sig, env;
		sig = LFTri.ar(nn.midicps)!2;
		env = EnvGen.kr(Env.perc, doneAction:2);
		sig = sig * env * vel.linexp(1, 127, 0.01, 0.3);
	}.play;
});
)


/*
       2. Create a Synthdef and trigger that via MIDI

*/

// simplify the MIDIdef function. now instantiate a synth with the correct params
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	Synth.new(\tone, [\freq, nn.midicps, \amp, vel.linexp(1, 127, 0.01, 0.3)
	]);
});
)

(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.perc, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

// to test \tone a simple .new
x = Synth.new(\tone, [\freq, 500, \amp, 0.3]);


/*
       2.1 Do away with perc env and use adsr.
       - to sustain with a note on
       - and release with a note off
       using adsr's gate arg. when get==1 sustain, when gate==0, goes into release .

*/

(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

// quick test to see if gate works, it should.
x = Synth.new(\tone, [\gate, 1]);
x.set(\gate, 0);

/*
      2.2 MIDI Polyphony << elaboration and continuation >>

      we set up an array of 128 to hold each possible note,
      because inside the MIDIdef.noteOn we can't usefully do:

      x = Synth.new( )
      x.set(\gate, 0)

      if you make a new synth you have no way of communicating
      with the old one, and no way of releasing the note. Meaning
      we get a hole bunch of stuck notes.

      > create an empty array of size 128, one for each possible note number (nn)
      > when I play a note I create a synth, store that synth in the array, at an
      > index equal to the incoming note number. When I release a note, I free the
      > synth at the index equal to the incoming nn.

      This visualizes the keyboard as an array of possible notes.
*/

~notes = Array.newClear(128); // init the array

// modify the mididef for .noteOn messages
// and store the created synth in the array of notes.

// This also requires a second MIDIdef to handle the noteOff (see below)
// else all notes get stuff because gate never gets set to 0.
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	["note on", vel, nn].postln;
	~notes[nn] = Synth.new(\tone, [
		\freq, nn.midicps,
		\amp, vel.linexp(1, 127, 0.01, 0.3),
		\gate, 1,
	]);
});
)

// set the gate to 0 on .noteOff and replace the synth in the array with nil.
(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	["note off", vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});
)

// sound generator
(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)


/*
       3. Finishing touch: Pitchbend!
       - pitch bend on all current notes
       - pitch bend to be a global state, so current pitch position is used by new notes.

       we need a third MIDIdef

*/


~notes = Array.newClear(128);

// keep track of the pitchwheel position
// MIDIdef will update this value every time the pitchwheel is moved
~bend = 8192;

// at rest 8192, full 16383, bottom 0.
// In the video Eli's Yamaha sends pitch bend message on three channels,
// if that happens to you filter the channels by adding `chan: 0` to the MIDIdef, seen below.
(
MIDIdef.bend(\bendTest, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);
)

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	["note on", vel, nn].postln;
	~notes[nn] = Synth.new(\tone, [
		\freq, nn.midicps,
		\amp, vel.linexp(1, 127, 0.01, 0.3),
		\gate, 1,
		// new notew, check current bent position first, remap.
		\bend, ~bend.linlin(0, 16383, -2, 2),
	]);
});
)

(
MIDIdef.noteOff(\noteOffTest, {
	arg vel, nn;
	["note off", vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
});
)

// sound generator, adjust for bend
(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0, bend=0;
	var sig, env;
	sig = LFTri.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;
)

