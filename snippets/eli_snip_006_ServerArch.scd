// eli_snip_006 (Tut 7)

s.boot
s.plotTree;
s.meter;   // levels

// 3 concepts: nodes, busses, Order of Execution
// - node subclasses we use (Synth and Group)
// - busses are used to send signals between Synths (Ugens?)
// - ordering, like a dependency graph.

(
SynthDef.new(\blip, {
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(0, sig);

}).add;
)

x = Synth.new(\blip);
x.free;

// instead of sending this to the speakers, send it to a bus
// declare the out buss indices, so you can reroute later
(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);

}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);  // 1, here monophonic
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;  // !2 for 2 channels
	Out.ar(out, sig);
}).add;
)

// number of bus channels default 128 get from
// s.options.numAudioBusChannels;
// by default busses 0..7 are reserved for hardware outputs
// s.options.numOutputBusChannels;
// by default busses 8..15 are reserved for hardware inputs
// s.options.numInputBusChannels;
// changing these is done by assigning values , and then s.reboot;

s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 2;
s.reboot;

y = Synth.new(\reverb, [\in, 6]);
x = Synth.new(\blip, [\out, 6]);
x.free;
y.free;

// changing busses, allows dismantle of chain ..removing sources from
// the effects so effects can decay naturally.
x.set(\out, 6)

// Using bus indices explicitly is problematic when you change hardware,
// or run code on other hardware. The solution is to use the Bus object.
// and store the reference as a global
// let supercollider do the index picking for you. it will always pick
// the lowest available bus that doesnt conflict with hardware busses.
~reverbBus = Bus.audio(s, 1);  //mono. belongs to local server s
~reverbBus.index;  // lets us know which SC chose.

// allowing one to write ~reverbBus.index instead of hardcoding the index
y = Synth.new(\reverb, [\in, ~reverbBus.index]);
x = Synth.new(\blip, [\out, ~reverbBus.index]);

//.index doesn't even need to be specified (it is translated automagically)
// passing a Bus object implies you want the index
y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);

//
// Multi Channel ////////////////////
//

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);

}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);  // duo channel now!
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);  // no need to dup
	Out.ar(out, sig);
}).add;
)

// allocating a multi channel bus object, reserves adjacent bus indices.
// but does not 'create' a multichannel bus. nor will .index return an array
// it will instead return the lowest index it references.

// See help->Bus object |||| this is a big topic ||||
s.plotTree;

~reverbBus = Bus.audio(s, 2);  //stereo. belongs to local server s

// the default behaviour called 'addAction' of Synth.new
// is to add new nodes to the head.
y = Synth.new(\reverb, [\in, ~reverbBus]);   // do first
x = Synth.new(\blip, [\out, ~reverbBus]);    // do second.
x.free;
y.free;


///////// Groups
Tut7 14:00

// whenever you boot a server you get a default node group.
// adding a group node, looks at the node tree with s.plotTree;
g = Group.new;
g.free;

// also specify which group (s, default group)
// in this example it doesn't make a different which line is run first.
// because reverb is added to tail, it will always have audio incoming.
y = Synth.new(\reverb, [\in, ~reverbBus], s, \addToTail);
x = Synth.new(\blip, [\out, ~reverbBus], s);
x.free;
y.free;

// another way to place these synths in order is to specify which Synth
// we want to place the effect after. we add reverb after blip (x) synth.
x = Synth.new(\blip, [\out, ~reverbBus], s);
y = Synth.new(\reverb, [\in, ~reverbBus], x, \addAfter); // see x

// 5 convenience methods for addAction: (work for Synth and Group)
// \addToHead, \addToTail, \addAfter, \addBefore, \addReplace
// can be written as
Synth.after(\reverb, [\in, ~reverbBus], x);
Synth.before(...);
Synth.head(...);
Synth.tail(\reverb, [\in, ~reverbBus], s,);
Synth.replace(...);

~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);

/////
///// adding arguments to the blip synth, unnamed synths added to group
///// (unnamed instances of \blip synth)

~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);
~reverbBus2 = Bus.audio(s, 2);  //stereo. belongs to local server s
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGroup);

(
SynthDef.new(\blip, {
	arg out, fund=100, dens=2, decay=0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);

}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);  // duo channel now!
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);  // no need to dup
	Out.ar(out, sig);
}).add;
)

(
8.do{
	Synth.new(
		\blip,
		[
			\out, ~reverbBus2,
			\fund, exprand(60, 300).round(30)
		],
		~sourceGroup
	);
}
)

//
// sending messages to all synths in a group
// using ~sourceGroup.set(

~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);
~reverbBus2 = Bus.audio(s, 2);  //stereo. belongs to local server s
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGroup);

(
SynthDef.new(\blip, {
	arg out, fund=100, dens=2, decay=0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);

}).add;

SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 2);  // duo channel now!
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);  // no need to dup
	Out.ar(out, sig);
}).add;
)

(
8.do{
	Synth.new(
		\blip,
		[
			\out, ~reverbBus2,
			\fund, exprand(60, 300).round(30)
		],
		~sourceGroup
	);
}
)

~sourceGroup.set(\decay, 1.2);
~sourceGroup.set(\dens, 0.2);

/// if you want to free all nodes in a group
~sourceGroup.freeAll;

// End. of Tut 7.



