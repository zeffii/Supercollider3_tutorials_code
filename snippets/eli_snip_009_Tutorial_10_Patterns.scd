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

*/



