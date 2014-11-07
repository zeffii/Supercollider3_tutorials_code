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

