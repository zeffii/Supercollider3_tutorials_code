/*

             SuperCollider Tutorial: 11. TouchOSC
             https://www.youtube.com/watch?v=ZVTbRNu2BI0

             > In contrast to the MIDI protocol, OSC is faster, more flexible
             > more time accurate, and doesn't include a hardware specification.
             > OSC messages are most commonly sent over a network ( UDP / TCP )

             > The syntax of a OSC message consists of a URL style adress followed by
             > some number of arguments (often numbers, but not always)
             > OSC messages are sent to a specific IP address on a specific Port

             This video discusses OSC through an app called TouchOSC and its editor
             (which allows for custom interfaces, drag n drop sliders, rotaries etc)

             My (not Eli's) main interest in OSC is the formatting of the message and
             how SuperCollider can send/receive messages. Where the messages come
             from is not so relevant, i'll concentrate on what the messages are.

             Help docs: External Control / OSC / guide "OSC Communication"
*/

// start with an OSCdef to respond to some device with a known path
// See OSCdef man pages
// by default SuperCollider listens for input on port 57120
s.boot;
NetAddr.langPort;  // verify

(
OSCdef.new(
	\toggle,               // named OSCdef, this is given by you
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln; // gives a swathe of information.
	},
	'/main/toggle1'        // or whatever OSC address you want to receive from.
))

// picking msg elements
(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		// if the msg is an array then element 0 will give the origin-url '/main/toggle1'
		// msg[1] will give the second element. etc.
		// :: for toggle messages the value will usually be 0 or 1
		// :: for sliders, it can be any range of numbers
		// :: for enumeration, it can either be a named enum member or an index into a known collection.
		// :: etc.
		[msg[1]].postln;
	},
	'/main/toggle1'        // or whatever OSC address you want to receive from.
))

// set up a SynhtDef to be able to handle adsr and frequency
(
SynthDef.new(\tone, {
	arg freq=40, nharm=12, detune=0.2, gate=0,
	pan=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr(0.05, 0.1, 0.5, 3), gate);
	sig = Blip.ar(
		// note the 16 way multichannel expansion, it will be mixed to 2 channel using Splay
		// and becase Pan2 expects a mono channel we must place it in the stereo field using
		// Balance2
		freq *
		LFNoise1.kr(0.2!16).bipolar(detune.neg, detune).midiratio,
		nharm
	);
	sig = sig * LFNoise1.kr(0.5!16).exprange(0.1, 1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add
)

x = Synth.new(\tone, [\gate, 1]);  // test it
x.set(\freq, 120);                 // change other arg variables
x.set(\gate, 0);                   // gate=0 to release


/*
        What about mulitple simultaneous osc events? (or seeminly simulaneous)
        well, one way to work this is to make a whole bunch of OSCdefs

*/

// going with the TouchOSC example from the video, if you want to control multiple parameters
// of the previous \tone SynthDef it might look like this

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		x.set(\gate, msg[1]);   // set to 0 or 1 when presses/depressed
	},
	'/main/toggle1'
))

(
OSCdef.new(
	\fader1,
	{
		arg msg, time, addr, port;
		// this will need to be remapped to a range that \freq can use
		// in the case of the video and TouchOSC this fader produces values between
		// and including 0 .. 1 ,but that's useless for frequency so remap to 20..500.
		x.set(\freq, msg[1].linexp(0, 1, 20, 500));
	},
	'/main/fader1'
))

(
OSCdef.new(
	\fader2,
	{
		arg msg, time, addr, port;
		// nharm has useful input in the range 1..50 (or higher.. if you want)
		x.set(\nharm, msg[1].linexp(0, 1, 1, 50));
	},
	'/main/fader2'
))

(
OSCdef.new(
	\fader3,
	{
		arg msg, time, addr, port;
		// while amp does expect a range of 0..1.
		// it is desirable sometimes to map this range exponentially instead of the
		// linear range received from the slider outputs.
		x.set(\amp, msg[1].linexp(0, 1, 0.001, 1));  // note the use of 0.001 to help the exponent.
	},
	'/main/fader3'
))

(
OSCdef.new(
	\rotary1,
	{
		arg msg, time, addr, port;
		// pan goes from -1 to 1
		x.set(\pan, msg[1].linexp(0, 1, -1, 1));
	},
	'/main/rotary1'
))

(
OSCdef.new(
	\rotary2,
	{
		arg msg, time, addr, port;
		// detune could be anything, but pick something :) here max = 12 semitones
		x.set(\detune, msg[1].linexp(0, 1, 0.001, 12));
	},
	'/main/rotary2'
))
