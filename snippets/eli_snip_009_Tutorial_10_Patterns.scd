/*
       SuperCollider Tutorial: 10. Patterns
       https://www.youtube.com/watch?v=nB_bVJ1c1Rg

       patterns and sequence can control sound and visuals.
       patterns are documented extensively.
       Search `Streams, Patterns, and Events`.
       Search Pattern helpfile.

*/

// begin with simple synthdef with generates sine wave panned in the stereo field
// and applies simple amplitude envelope.
s.boot;

(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

// test it.
Synth.new(\sine);

// we start with a Pattern called 'Pbind'. It responds to the .play message
// by generating a sequence of events. Events are covered in Harkins' Pattern Guide (ch 8)
// PG_08_Event_Types_and_Parameters
// There are several predefined event typess, most common and default is 'note event'.
// See Pbind helpfile. Pbind expects a specific set of key-value pairs.

(
p = Pbind(
	\type, \note,
	\instrument, \sine,
).play;
)

s.plotTree;  // see it instanciate and destruct the synth.
p.stop;      // stop for now.

// because note is the default event type, technically we don't need to specify it.
(
p = Pbind(
	\instrument, \sine,
).play;
)

p.stop;

// Pbind generates a stream of events, we can control the length
// of time between successive events. This is called 'delta time' . the key is \dur

(
p = Pbind(
	\instrument, \sine,
	\dur, 2                 // one every 2 seconds
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, 0.1               // 10 per second
).play;
)

p.stop;
// if your signal is late or choppy the postwindow will display
// late <some float number>, for me it says "late 4.4564564" or something similar each time.
// you might not get this message. For higher accuracy one might switch to ASIO.


/*
       2. Variable Pattern / Event duration
       fixed duration is not so useful, instead we can control duration over time using Pseq

*/


// this plays only 3 notes
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7])
).play;
)

// this will play until .stop is called
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7], inf)
).play;
)

// to show current Pseq element use .trace
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7], inf).trace,
).play;
)
p.stop;

// we don't need to repeat inifinitely

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7], 4).trace,   // will repeat this pattern 4 times
).play;
)

// let's set different values for \freq and \dur
// look both Pseq, we will hear a total of 12 tones because both Pseq will produce
// the same number of events.
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7], 4).trace,         // \dur  = 3 values * 4 = 12
	\freq, Pseq([340, 247, 370, 226], 3).trace, // \freq = 4 values * 3 = 12
).play;
)

// if one of the Pseqs is Shorter than the other, then Pbind will end according
// to Pseq with the fewest events. Here we will hear only 6 events.
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.2, 1, 0.7], 2).trace,         // \dur  = 3 values * 2 = 6
	\freq, Pseq([540, 247, 670, 726], 4).trace, // \freq = 4 values * 4 = 16
).play;
)

// using \freq is probably not intuitive. there is a default \midinote key in Pbind
// which converts to \freq automatically. ** if your SynthDef has a \freq key! , then it will work**
// read the heirarchy of key notes in Pbind docs. Follow the naming conventions.

// > It is to your advantage to use (in your SynthDefs) the arguments listed in the Pbind
// > help file. such as \freq, \amp, \sustain etc..

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\midinote, Pseq([60, 65, 67, 74], inf).trace,
).play;
)
p.stop;

// regarding the various tiers in the heirarchy, don't pick and mix between them, stay on one tier or
// you will be providing redundant or nonsensical commands to you SynthDef / Pbind.


/*
        3. Random Number patterns

        - lookup Pexprand
*/


(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)


(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\freq, Pexprand(50, 400, inf),    //exponential distribution
).play;
)

p.stop;


(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5).trace,  //linear distribution
	\freq, Pexprand(50, 400, inf),
).play;
)

p.stop;


/*
       4 patterns for controlling a d s r etc.

       for the example many notes at once means it's a good idea to lower the overall amp
*/

(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)


// might be a little loud... turn down first.
(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf)    // staying away from extreme side
).play;
)

s.plotTree;  // to see the event stream generating a whole bunch of nodes.
p.stop;

// > suppose we want the sinewaves to allign with the harmonic series,
// > patterns understand mathematical operations and methods, so we can
// > use the .round method on the frequency pattern

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).round(55).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf)
).play;
)
p.stop;

// The same effect can be got using \midinote and \hardmonic directly

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\midinote, 33,
	\harmonic, Pexprand(1, 80, inf).round.trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf)
).play;
)
p.stop;


// the higher partials become dominant, that can be mitigated by making the amp of a \sine
// a function of its pitch. To do this we must have the amplitude pattern rely on the values
// of the pitch pattern. We use the pattern PKey to copy values from an earlier pattern. in
// this case harmonic

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\midinote, 33,
	\harmonic, Pexprand(1, 80, inf).round.trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pkey(\harmonic).reciprocal * 0.3,
	\pan, Pwhite(-0.8, 0.8, inf)    // staying away from extreme side
).play;
)
p.stop;


/*

        5. Manipulation patterns while they play.
        wrap a Pbind in a Pdef. Symtax os similar to MIDIdef

*/

// inside the Pdef theres no longer need for the global variables
// once playing we can simply change the commands and reevaluate.
// the changes will take effect without interupting the event stream
(
Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([33], inf),        // try changing the fundamental and re-eval
		\harmonic, Pexprand(1, 80, inf).round,  //or cut out the higher partials 80->40 and re-eval
		\atk, Pwhite(2.0, 3.0, inf),            // change these from long to short
		\rel, Pwhite(5.0, 10.0, inf),           // change these from long to short
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf)    // staying away from extreme side
	);
).play;  // .stop;
)


/*
     6. Rhythm!  switching to SndBuf as a sound source.
     get a sample pack of low mid and high percussive sounds.

     "C:/Users/dealga/Desktop/shots"    has three subfolders Low, Mid, High
*/

// using a Dictionary to store the sounds
// each key will point to an array of the appropriate sound files
(
d = Dictionary.new;
d.add(\l -> PathName("C:/Users/dealga/Desktop/shots/Low").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	});
);

d.add(\m -> PathName("C:/Users/dealga/Desktop/shots/Mid").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	});
);

d.add(\h -> PathName("C:/Users/dealga/Desktop/shots/High").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	});
);
)

d[\l].choose.play;  // trigger this a few times to get random low hits
// 17 minutes.
(


// a simple Synth def then to play buffer objects
SynthDef.new(\bufplay, {
	arg buf=0, rate=1, amp=1;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, doneAction:2);
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)

// make a new Pbind and Pdef
(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([0.12], inf),
		\buf, Prand(d[\l]++d[\m]++d[\h], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play; // .stop;
)

Pdef(\rhythm).stop;   // or stop like this.

// If we only  want certain buffers we modify the buf pattern an re-evaluate

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([0.12], inf),
		\buf, Prand(d[\m], inf),    // or d[\l]    or  d[\h]    re-eval while playing
		\rate, 1,
		\amp, 0.5,
	);
).play; // .stop;
)


/*
        BPM ! often it's preferable to think with respect to rhuthm in terms of beats per minute
        rather than some floating point ratio per second

        let's say we want the sounds to roll in as 16 notes at 128 bpm, in time signature 4/4
*/

// first thing to change is the \dur key to be literally 1/16 of our hypothetical 4/4 measure
// see the Pbind helpfile for \stretch
(
m = Pdef(        // assigning to global var m so i can hit stop easily.
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\buf, Prand(d[\l]++d[\m]++d[\h], inf),  //  or Pxrand (never pick the same value in a row)
		// stretch the raw delta times
		\stretch, 1.875, // 60 / 128 * 4
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

m.stop;

// Pwrand is a bit more interesting, it makes selection based on a second array of weights
// Pwrand in this example will pick \l 80% of the time, \w 15% and \h 5%.

(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pwrand([d[\l][0], d[\m][0], d[\h][0]], [0.8, 0.15, 0.05], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

m.stop;

// the send array in Pwrand must sum to 1, and there is a neat method to do that for us
// [8, 2, 1].normalizeSum
// >  [ 0.72727272727273, 0.18181818181818, 0.090909090909091 ]
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pwrand([d[\l][0], d[\m][0], d[\h][0]], [8, 2, 1].normalizeSum, inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

m.stop;

// Also check Pshuf, it takes an array and will pick items from it in a pattern.
// the pattern repeats when all items have been selected once.

/*

     let's constrain the patterns using accents


*/

// tedious way
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\l]++d[\m]++d[\h], inf),
		\rate, 1,
		// accents on beat 1 and 3
		\amp, Pseq([0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1], inf),
	);
).play;
)

m.stop;


// duplication and concatenation is a litle bit faster and cleaner
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\l]++d[\m]++d[\h], inf),
		\rate, 1,
		// accents on beat 1 and 3
		\amp, Pseq([0.8]++(0.1!7), inf),
	);
).play;
)

m.stop;

// but we're ignoring an important feature of patterns, the fact they can be nested

(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\h]++d[\m]++d[\l], inf),
		\rate, 1,
		// accents on beat 1 and 3, but this time using a nested Pexprand!
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

m.stop;


// seen as we;ve bothered to split the sounds, let's make it so we always get a low sound on beat 1
// and always a high sound on beat 3

// will change buf pattern, and this demonstrates nested patterns
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
		    [
				Prand(d[\l], 1),                 // first beat always low
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
				Prand(d[\h], 1),                 // 3rd beat always high
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
		    ], inf                               // repeat indefinitely
		),
		\rate, 1,
		// accents on beat 1 and 3, but this time using a nested Pexprand!
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

m.stop;

// to make things a bit less predictable you might randomize the playback rate a little
// this is not shuffle / swing
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
		    [
				Prand(d[\l], 1),                 // first beat always low
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
				Prand(d[\h], 1),                 // 3rd beat always high
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
		    ], inf                               // repeat indefinitely
		),
		\rate, Pexprand(0.8, 1.25, inf),
		// accents on beat 1 and 3, but this time using a nested Pexprand!
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

m.stop;

// if you notice that the stream has a hickup when you re-evaluate the Pdef, it's because we haven't
// placed it in a grid yet. there is no quantization so far.
// > quantization is the process of locking a patterns onset time to a fixed rhythmic grid

// we can make it so changes won't take effect until the start of the next bar.
// any evaluated changes in for example \rate won't be pushed until the next bar
(
m = Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
		    [
				Prand(d[\l], 1),                 // first beat always low
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
				Prand(d[\h], 1),                 // 3rd beat always high
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
		    ], inf                               // repeat indefinitely
		),
		\rate, Pexprand(0.8, 1.25, inf),
		// accents on beat 1 and 3, but this time using a nested Pexprand!
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play(quant: 1.875);
// while playing replace the abovev line with with
// ).quant_(1.875);
)

m.stop;

/// This means you can quantize multiple patterns to the same grid!

/*

     6 demo of sine + buffer

*/

// this just copied from above so later we can mix a sine with percussion.
// you have already seen how this is constructed, skip to the next SynthDef
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;


(
Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\note, Pxrand([0,3,5,8,10,12], inf),
		\atk, 0.005,
		// \gtranspose, -9,   // try this while playing.
		\rel, Pexprand(0.01, 0.5, inf),
		\amp, Pexprand(0.05, 0.5, inf),
		\pan, Pwhite(-0.8, 0.8, inf)
	);
//).quant_(1.875);     // evaluate with this to edit while playing
).play(quant: 1.875);  // minus this
)

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
		    [
				Prand(d[\l], 1),                 // first beat always low
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
				Prand(d[\h], 1),                 // 3rd beat always high
				Prand(d[\h]++d[\m]++d[\l], 7),   // any
		    ], inf                               // repeat indefinitely
		),
		\rate, Pexprand(0.8, 1.25, inf),
		// accents on beat 1 and 3, but this time using a nested Pexprand!
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
//).quant_(1.875);     // evaluate with this to edit while playing
).play(quant: 1.875);  // minus this
)

// these Pdefs can be stopped so
Pdef(\rhythm).stop;
Pdef(\sinepat).stop;

