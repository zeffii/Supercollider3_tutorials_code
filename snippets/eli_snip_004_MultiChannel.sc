// .. multichannel read 'multichannel expansion'
s.meter;

// left
x = {SinOsc.ar}.play;

// left + right
x = {[SinOsc.ar, SinOsc.ar]}.play;

// left + right offset frequencies.
x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play;

// internal array, of 2 sine oscs.
x = {SinOsc.ar([300, 500])}.play;

// no idea, it's neat.
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 1]).range(0,1);
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

x.free;


// wraps around, the shorter array is repeated.
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7]).range(0,1);
	sig = SinOsc.ar([300, 500]);
	sig = sig * amp;
}.play;
)

x.free;
s.freeAll;

// MIX!

(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300, 500, 600, 800, 900]);
	sig = sig * amp;
	Mix.new(sig) * 0.24;  // mixes all to left
}.play;
)

x.free;

// Mix multichannel expansion

(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300, 500, 600, 800, 900]);
	sig = sig * amp;
	[Mix.new(sig), Mix.new(sig)] * 0.24;  // mixes all to left
	// Mix.new(sig).dup(2) * 0.24;  // same as line above
	// Mix.new(sig)!2 * 0.24;  // same as line above ! alias for dup
}.play;
)

x.free;

//
// Splay will mix several signals over stereo field
//
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300, 500, 600, 800, 900]);
	sig = sig * amp;
	Splay.ar(sig) * 0.54;
}.play;
)

x.free;


// Dup in and outside of an argument.

x = {PinkNoise.ar(0.5)!2}.play; // both sides identical
x = {PinkNoise.ar(0.5!2)}.play; // 2 pinknoises, both different refs.

// SynthDef

(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.54;
	Out.ar(0, sig);    // let SC handle outputs!
}).add;
)
x = Synth.new(\multi);
x.free

// RANDOM and DUP

// an array of 4 copies of a randomly generated values
rrand(50, 1200)!4;    // [234, 234, 234, 234]

// an array of 4 different values generated at random on each call
// the {} turns this into a function.
{rrand(50, 1200)}!4;    // [434, 134, 629, 535]

// adding multichannel randomness
// ExpRand (ugen) creates every time the synth is instantiated
// exprand on declaration only.
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.54;
	Out.ar(0, sig);    // let SC handle outputs!
}).add;
)
x = Synth.new(\multi);
x.free

/// hook it up!

(
SynthDef.new(\multi, {
	var sig, amp, env;
	env = EnvGen.kr(
		Env.new([0,1,0],[10,10],[1,-1]),
		doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = sig * amp * env;
	sig = Splay.ar(sig) * 0.54;
	Out.ar(0, sig);    // let SC handle outputs!
}).add;
)
x = Synth.new(\multi);
x.free




