s.boot;
s.meter;
s.plotTree;

Hey everybody, welcome to tutorial 15. In the next three videos, we're gonna have a close look at composing and performing a piece of music in SuperCollider, using excerpted code from one of my own compositions as an example. In the first two of these three videos we'll focus on composition strategies for creating interesting sound, and in the third video, we'll incorporate these sounds into a performance-oriented code structure in which the piece can be performed and modified quickly and easily.

I've chosen this topic because I often see new users pick up the basics of SC very quickly, but it can be much more challenging to make the jump from scattered, unorganized bits of code to a more sophisticated and robust means of performance.

Keep in mind that what you'll see in these videos is my own personal approach that I've been developing over the years, it's an approach I have found useful and reliable, but it's not the absolute correct way to do things. There are lots of different approaches that work well, and that's part of the beauty of the SuperCollider platform.

So let's begin with composition, which for me, almost always begins with building SynthDefs. And one of the SynthDefs from this piece that I was most happy with, outputs a bandpass-filtered sawtooth wave, which, all things considered, is a very straightforward concept, but there are a few enhancements I like to include that help make the SynthDef more versatile, and I'll highlight these enhancements as we go. For the basic UGen function, we have a sawtooth wave with a frequency input, sent through a bandpass filter with controls for center frequency and reciprocal quality, and output the signal. In many cases, including this one, we also want to include an envelope generator so we can shape the amplitude of the sound over time. And of course we need to start with an argument declaration and provide sensible default values.

(
SynthDef(\bpfsaw, {
	var sig;
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	Out.ar(out, sig);
}).add;
) //then env, then args

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

The default output sounds like this:

Synth.new(\bpfsaw);

So over the course of this video, we'll be looking at a variety of techniques that can help transform a relatively simple sound into a more complex and interesting sound. And one such technique is iteration. In the following example, we use do to iterate over a collection of four midi note numbers converted to cycles per second. And for each number in the Array, we use an argument declaration to pass that value into a function which creates a Synth, and uses that input value for the frequency of the Synth. And, since we'll have four instances, it makes sense to lower the amplitude to avoid clipping.

(
[58,65,68,73].midicps.do{
	arg f;
	Synth.new(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
		]
	);
}
)

By generating random numbers for argument values within an iterative function, the output of each Synth is unique. Here, the center frequency of the filter ranges between the 1st and 12th partial, and each of the four bandpass filters has a uniquely generated quality as well. Each time this code is evaluated, we hear resonance at different parts of the frequency spectrum.

( //several times
[58,65,68,73].midicps.do{
	arg f;
	Synth.new(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f * exprand(1,12),
			\rq, exprand(0.01,0.5),
		]
	);
}
)

There's lots of opportunity for experimentation here. If we want to embrace randomness even more, we can create four Synths but completely ignore the values being passed into the function.

(
4.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, exprand(100,1000),
			\amp, 0.25,
			\cf, exprand(200,5000),
			\rq, exprand(0.01,0.5),
		]
	);
}
)

You might find some use for the Scale object, which is an abstract representation of a musical scale. In fact, lots of pre-built scale instances are readily available, like major, minor, chromatic, and you can see the complete list with Scale.directory, and more information in the Scale help file. After choosing a scale, degrees converts to an array of integer scale degrees. Then using simple addition, we can transpose the scale degrees to a more sensible range, in this case, a natural minor scale beginning on middle C. Convert to cycles per second... and choose a random scale degree each time the function is called. With each full evaluation we hear four pitches from a c minor scale, and duplicate pitches are possible.


//within iterative code
Scale.major; //minor, chromatic

Scale.directory;

Scale.minor.degrees;

(
4.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees+60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(250,1000),
			\rq, exprand(0.01,0.5),
		]
	);
}
)

Using Scale and choose is a nice way to strike a balance between deterministic pitches and complete randomness. Even the number of Synths we generate can be randomized. Remember that this syntax shortcut gives us the array of integers from 1 to 6, so now, whenever we evaluate, we choose one of these integers and produce that many Synths. And conveniently, we can also see this value in the post window.

(
(1..6).choose.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees+60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200,1000),
			\rq, exprand(0.01,0.5),
		]
	);
}
)

Before we go any further, let's return to our SynthDef to make some improvements. In the examples we just heard, the random values chosen for Synth arguments don't continuously vary over the course of the Synth duration, instead they remain fixed at their initial value. But we can change this by using low frequency noise generators to autonomously vary one or more of the input arguments. So to start, let's multiply the fundamental frequency by an instance of LFNoise1, and this will allow us to dynamically detune the fundamental. A frequency of 0.5 means we choose a new random value once every 2 seconds. LFNoise1 normally ranges between positive and negative 1, but we want it to range between a positive and negative detune value. We can use the range method, which we've seen many times:

LFNoise1.kr(0.5).range(detune.neg, detune)

but the bipolar method is a more convenient way of doing the same thing

LFNoise1.kr(0.5).bipolar(detune)

but, using even fewer characters, we can take advantage of the fact that the default output is -1 to +1, and therefore we can specify detune as the mul argument, thereby scaling the output by the detune value. I'm imagining detune as a value in semitones, so to make this work as a frequency multiplier, we need to use midiratio to convert semitones to frequency ratios.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, cf=1500, rq=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

So, with a default value of 0.2, the detuning effect is fairly weak, since we're only detuning by a fifth of a half step in either direction, which is not very much.

Synth.new(\bpfsaw);

But we really start to notice the effect if we create multiple instances, because each Synth has its own independent noise generator, which results in irregular frequency beating.

2.do{Synth.new(\bpfsaw, [\amp, 0.5])};

And with even more instances, we get a sort of chorus effect.

10.do{Synth.new(\bpfsaw, [\amp, 0.2])};

Notice that if we want to disable the detuning effect altogether, we don't have to revert to an earlier version of the SynthDef, we can just specify 0 for the detune argument.

10.do{Synth.new(\bpfsaw, [\amp, 0.2, \detune, 0])};

And of course we now have the option of a larger detune value, which creates a meandering pitch cluster effect.

10.do{Synth.new(\bpfsaw, [\amp, 0.2, \detune, 3])};

Let's do something similar for the center frequency and quality. I am being a little arbitrary with these frequency values. My only consideration is that I want to choose random values at a relatively slow rate, so 0.2 and 0.1 are reasonable choices, but I'm not choosing them for any specific reason. We also need to make sure we include these new arguments in our declaration. I'm specifying default values that are sensible, but again, not chosen for any particular reason.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

So here's what our SynthDef sounds like with ten instances, each with a fundamental of 50hz.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.2,
		]
	)
};
)

Let's continue experimenting and have the center frequencies vary between the 2nd and fiftieth partial.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
		]
	)
};
)

If we specify a reciprocal quality range relatively close to 1, thereby lowering the quality of the filter, the filtering effect is weakened and we hear something that more closely resembles the original detuned sawtooth wave.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.8,
			\rqmax, 1,
		]
	)
};
)

But if these values are close to zero, we increase filter quality and therefore strengthen the filtering effect. In this case we can still perceive the 50Hz fundamental, but we also hear strong sweeping resonances at random points throughout the harmonic series.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
		]
	)
};
)

Now I'd like to turn our attention to spatialization, because, as you may have noticed, we're still dealing with monophonic sound. One of the simplest options with a mono signal is to add a pan position argument and an instance of Pan2 near the end of the SynthDef.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

Zero corresponds to the center of the stereo space... and with something like point 7, all ten Synths are panned heavily toward the right channel...And in this case each Synth has a random pan position, giving us a richer stereophonic experience:

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
			\pan, 0, //0.7, rrand(-1.0,1.0),
		]
	)
};
)

A simple alternative for creating stereo sound is to invoke multichannel expansion using the duplication shortcut, exclamation point 2. This creates an Array of two copies, which the server interprets by writing these signals to consecutive output channels.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	Out.ar(out, sig!2);
}).add;
)

We can see and hear that output channels 0 and 1 contain the exact same signal.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\detune, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
		]
	)
};
)

There are several other spots in the SynthDef where we could alternatively place exclam 2, such as after the envelope, after the sawtooth wave, or after the bandpass filter, and these choices would all have the same signal copying effect. In tutorial 5, however, we saw that functions, delineated by an enclosure of curly braces, respond differently to duplication. As a quick review: duplicating a random process results in an array containing copies of the randomly generated value:

rrand(0,100)!4;

But duplicating a function, regardless of what it contains, causes the function to be re-evaluated each time it's duplicated. So when that function contains random processes, we get uniquely generated results with each copy.

{rrand(0,100)}!4;

Let's apply this technique to our SynthDef. If we duplicated our noise generators, without enclosing them in curly braces, the result is an exact copy of the noise generator output. So once again, we have identical signals in both output channels.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio!2);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax)!2,
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)!2
	);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\detune, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
		]
	)
};
)

But, enclose our noise generators in curly braces before multichannel expanding them, and each noise generator copy outputs a unique random signal, which we can see clearly in the level meters.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(0.2).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\detune, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
		]
	)
};
)

Now if we want to pan this signal left and right, we can't use Pan2, because Pan2 expects one monophonic input signal. A good choice here is a UGen called Balance2, which treats two monophonic inputs as left and right channels, adjusts their amplitudes according to a pan position argument, and outputs a combined stereo signal. Becuase we've multichannel expanded our input, it's actually an Array of two signals, so we refer to the individual monophonic signals by specifying sig at zero for the left channel, and sig at one for the right channel.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(0.2).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Here's hard left...hard right...and center

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\detune, 0.2,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
			\pan, -1, //1, 0
		]
	)
};
)

Pan2 and Balance2 are slightly different, but both very solid choices for simple stereo spatialization. Now, arguably, it's sort of rare to be dealing with multichannel signals with more than two channels, but it's definitely not unheard of. And even though we can't get the full effect in this video, I want to briefly show an approach for spatializing more than two audio channels.

First we need to increase the number of SuperCollider's hardware output channels and reboot the server for this change to take effect, and we'll also re-open the level meters.

(
s.options.numOutputBusChannels = 8;
s.reboot;
)

s.meter;

I'm going to return our signal to a monophonic state, and introduce a UGen called PanAz, which is short for Azimuth Panner. An azimuth panner assumes the user is in the middle of circular formation of an arbitrary number of equidistantly spaced speakers, and allows us to position a monophonic signal somewhere within this ring of speakers. By default, PanAz assumes the front of the listening space is a pair of speakers, that the left front speaker corresponds to output zero, and that the output indices increase as we move clockwise around the ring. The first argument is the number of output channels, let's imagine we have 8 speakers. Next the monophonic input signal, and then the pan position. Like Pan2 and Balance2, PanAz expects a value between plus and minus 1, but interprets this value differently: a position of zero corresponds to front and center. As this value goes from zero to negative 1, the sound moves from front to back around the left side. As we go from zero to positive 1, the sound moves from front to back along the right side. And so one thing I really like about PanAz is that it doesn't matter how many speakers you actually have. You only need to specify the circular position of a sound, and PanAz figures out the rest.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	sig = PanAz.ar(8, sig, pan);
	Out.ar(out, sig);
}).add;
)

So here are ten instances with a few arbitrary arguments. A pan value of 0 puts the sound front and center, so on the meter window it appears in outputs 0 and 1

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 20,
			\amp, 0.5,
			\detune, 1,
			\cfmin, 50*40,
			\cfmax, 50*50,
			\pan, 0, //0.25, 0.5, 1
		]
	)
};
)

As we increase the pan position, the sound moves clockwise around the ring of speakers. Because 0 is front and 1 is rear, then 0.25 is 45 degrees to the right of front center, so we see signal in channels 1 and 2. A pan position of 0.5 is directly to the right of the listener, so in this theoretical octophonic setup, we see level in channels 2 and 3. A value of either 1 or negative 1 produces signal in channels 4 and 5... and so forth.

We can't modulate the number of channels, but we can modulate the pan position. A low frequency sawtooth wave provides an oscillating ramp from minus 1 to positive 1, so it's perfect for simulating a sound source moving in circles around the listener.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	sig = PanAz.ar(8, sig, LFSaw.kr(0.5));
	Out.ar(out, sig);
}).add;
)

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 20,
			\amp, 0.5,
			\detune, 1,
			\cfmin, 50*40,
			\cfmax, 50*50,
		]
	)
};
)

Other UGens make for interesting spatial effects as well. For example, LFNoise1 outputs random linear ramp segments, so it makes the output sound like it's moving randomly around the listening space.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  LFNoise1.kr(0.5,detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin,cfmax),
		LFNoise1.kr(0.1).exprange(rqmin,rqmax)
	);
	sig = sig * env * amp;
	sig = PanAz.ar(8, sig, LFNoise1.kr(1));
	Out.ar(out, sig);
}).add;
)

For clarity, let's just listen to one instance, while watching the level meters.

(
1.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 120,
			\amp, 0.5,
			\detune, 1,
			\cfmin, 50*40,
			\cfmax, 50*50,
			\rqmin, 0.1,
			\rqmax, 0.2,
		]
	)
};
)

With ten Synths, each has a unique random spatialization. //10.do

It's disappointing that we can't hear this sound in its true octophonic glory, but I hope you'll take my word for it that this kind of thing sounds great when you're lucky enough to have the hardware at your disposal. So for now, let's return to the stereo version with multichannel expansion and Balance2.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(0.2).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Alright, next I want to talk about nested randomness, in other words, controlling some aspect of a random process with another random process. Now, for me, the appeal of random UGens like LFNoise is that they help make sound less predictable, which in turn can make sound more interesting to listen to. But nesting random UGens can really enrich this effect. I want to start with a very simple example of what I'm talking about.

Here we have a sine wave.

{SinOsc.ar(440, 0, 0.1)!2}.play;

Modifying like so, we control the frequency with a non-interpolating noise generator, LFNoise0.

{SinOsc.ar(LFNoise0.kr(8).exprange(200,800), 0, 0.1)!2}.play;

The frequency of the sine wave randomly varies between 200 and 800, but the frequency of the noise generator does not-- instead it's fixed at a constant 8 values per second, and you can actually hear that 8Hz rhythm very clearly. [play again] But, let's go one level deeper and control the frequency of the noise generator with another noise generator.

{SinOsc.ar(LFNoise0.kr(LFNoise0.kr(8).exprange(2,30)).exprange(200,800), 0, 0.1)!2}.play;

The random aspects become even less predictable. Not only does the frequency of the sine wave randomly vary, but the rate at which the frequency changes is now also random. Now, I totally realize that the code for this kind of technique looks objectively confusing. And even if we spaced this code onto multiple lines with multiple variables, it can still be considerably challenging to conceptualize what's actually going on here. So even though it's possible to continue this nesting process inward and inward and inward, I pretty much always stop here, mostly for the sake of my own sanity.

So let's take this nesting idea and apply it to the bandpass filter's center frequency. For added flexibility, I'll add two new arguments to control the minimum and maximum output of the nested noise generator, which will determine the minimum and maximum speed at which the center frequency can vary. The previous example used a constant frequency of 0.2, so I'm choosing a default range of 0.1 and 0.3, to keep from drastically changing the default sound.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq *  {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2
	);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Here's how it sounds so far.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.01,
			\rqmax, 0.05,
		]
	)
};
)

If we increase the overall range of the nested noise generator, let's say, from 1 to 6 Hz, the center frequencies will change more quickly, and the resonant sweeping effects will become faster and more prominent.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.01,
			\rqmax, 0.05,
			\cfhzmin, 1,
			\cfhzmax, 6,
		]
	)
};
)

In this case, we're already dealing with a pretty wide frequency range, the 2nd partial to the 50th partial, and the filter quality is pretty high as well. So in this case, if we increase these range values even more, the filter resonance becomes so strong that the fundamental starts to disappear altogether and the sound starts to transform into a bubbly texture.

(
10.do{
	Synth.new(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.5,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.01,
			\rqmax, 0.05,
			\cfhzmin, 5,
			\cfhzmax, 40,
		]
	)
};
)

In the interest of time, I'm going to stop here with nested randomness, but I encourage you to continue experimenting at home. But remember that your ears are a precious commodity, and SC will not protect you if you accidentally type an extra zero or forget a decimal point. So if you ever feel like you're starting to lose your conceptual grasp on what you're doing, for your health, first take the headphones off, turn down the computer volume, and always keep an eye on the level meters.

Ok, we're at the point where the SynthDef in this video is almost identical to the version I used in my own work. The last thing I want to add is a low shelf filter. In the original composition, I added this because there were times when I wanted the option to boost or attenuate a certain range of low frequencies, so I'm including it here as well. Notice I'm setting the default decibel value to 0, so if we don't specify otherwise, we essentially bypass the low shelf filter.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3, lsf=200, ldb=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.2).exprange(rqmin,rqmax)}!2
	);
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Right, so, with this SynthDef in its final form, we're ready to turn our attention to more techniques for creating larger and more interesting composite musical gestures. As a starting point, let's imagine we want to create a chord progression, and I think using Patterns, Pbind in particular, is one of the best ways to do this, so here we'll be revisiting some ideas from tutorial 10. Setting dur to a fixed value of 2 gives us a new event every 2 seconds, and I'll also provide fixed values for a few other parameters. For the pitch pattern, Pseq is a good choice for a fixed sequence, but an Array of integers like this gives us a melodic progression with a single pitch for each event.

(
Pbind(
	\instrument, \bpfsaw,
	\dur, 2,
	\midinote, Pseq([54,61,56], 1), //last
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1500,
	\atk, 1,
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
).play;
)

To create a chord progression, we can instead provide Pseq with an Array containing other Arrays. In this case, the first generated event passes the array 23 35 54 63 64 to the midinote key, and as a result, this first event results in the creation of five Synths, one for each midinote. The next event uses the next sub-array, which corresponds to the next chord, and so forth. I'm going to extend the the time aspects of this pattern so we can savor these chords a little more.

(
Pbind(
	\instrument, \bpfsaw,
	\dur, 5, //change
	\midinote, Pseq([
		[23,35,54,63,64],
		[45,52,54,59,61,64],
		[28,40,47,56,59,63]
	], 1),
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1500,
	\atk, 2, //change
	\rel, 8, //change
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
).play;
)

If instead we want chords to be in a less predictable order, we can replace Pseq with something else, such as Pxrand, which chooses randomly from a collection but never repeats the same choice twice in a row. And, for the sake of variety, I'll add another sub-array so that we have four chords to choose from. Now, you might notice that midinote is the only finite pattern within this Pbind-- Pxrand chooses one array and then stops. Everything else is a single symbol or number, which are interpreted as infinite patterns. So because Pxrand generates only one value, the enclosing Pbind generates only one event.

(
Pbind(
	\instrument, \bpfsaw,
	\dur, 5,
	\midinote, Pxrand([
		[23,35,54,63,64],
		[45,52,54,59,61,64],
		[28,40,47,56,59,63],
		[42,52,57,61,63]
	], 1),
	\detune, 0.08,
	\cfmin, 100,
	\cfmax, 1500,
	\atk, 2,
	\rel, 8,
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
).play;
)

But if we replace 1 with inf, then all then internal values are interpreted as infinite patterns, and these chords will play on forever, which means, we should definitely give it a name so we can stop it later. And, also let's not forget that we have a huge pattern library at our disposal, so for fun and for variety, let's throw a few more into the mix.

(
~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, Pwhite(4.5, 7.0, inf),
	\midinote, Pxrand([
		[23,35,54,63,64],
		[45,52,54,59,61,64],
		[28,40,47,56,59,63],
		[42,52,57,61,63]
	], inf),
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, 100,
	\cfmax, 1500,
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0, 2.5, inf),
	\rel, Pwhite(6.5, 10.0, inf),
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
).play;
)

~chords.stop;

Now, here's a surprising twist. We can use this SynthDef to create an entirely different type of sound, just by specifying a few unusual argument values, and without having to make any changes to the SynthDef itself.

(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=4, c1=1, c2=(-1),
	freq=500, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3, lsf=200, ldb=0,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,1,0],[atk,sus,rel],[c1,0,c2]), doneAction:2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.2).exprange(rqmin,rqmax)}!2
	);
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

So far we've been specifying frequency values that the human ear perceives as having a distinct pitch-- roughly 20Hz to 20000Hz. But remember we're dealing with a sawtooth wave, so listen to what happens when the frequency drops below 20Hz.

(
Synth.new(
	\bpfsaw,
	[
		\freq, 128, //64, 32, 16, 8, 2
		\atk, 0,
		\rel, 3,
	]
);
)

With low frequency values, we don't stop hearing the sound altogether, we just stop perceiving pitch and instead start perceiving the rhythm of the individual sawtooth cycles. But having a low frequency doesn't make our sawtooth wave any less spectrally rich, so we can still use the bandpass filter to draw out certain frequencies from these individual clicks. First let's raise the quality of the filter.

(
Synth.new(
	\bpfsaw,
	[
		\freq, 2,
		\atk, 0,
		\rel, 5,
		\rqmin, 0.02, //0.005
		\rqmax, 0.05, //0.008
	]
);
)

We can hear these clicks start to resonate at specific pitches, as determined by the center frequency of the bandpass filter. The resonant pitches themselves are moving around because, recall, our bandpass center frequency is controlled by a noise generator with a minimum of 500Hz and maximum of 2000Hz. But we can set these values equal to one another in order to fix the center frequency at a constant value, in this case, 880Hz

(
Synth.new(
	\bpfsaw,
	[
		\freq, 2,
		\atk, 0,
		\rel, 5,
		\rqmin, 0.005,
		\rqmax, 0.008,
		\cfmin, 880,
		\cfmax, 880
	]
);
)

So the next thing to do is start thinking of creative ways to take this Synth and use it to construct larger and more complex ideas. So let's start building a pattern to create multiple instances like this one.

Starting on the more random side of things, random delta time, random frequency... and we'll set the center frequency minimum and maximum far apart from one another to allow the resonant pitches to wander up and down.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Pexprand(0.1,1,inf),
	\freq, Pexprand(0.25,9,inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, 150,
	\cfmax, 1500,
	\amp, 1,
	\out, 0,
).play
)

~marimba.stop;

But if we want to bring back our original idea of fixed resonant frequencies, we need the center frequency minimum and maximum to be equal, and for this we can use the Pkey pattern to copy the value from a previous key, in this case, using Pkey to make sure that cfmax is always equal to whatever is generated for cfmin.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Pexprand(0.1, 1, inf),
	\freq, Pexprand(0.25, 9, inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Pexprand(150,1500,inf),
	\cfmax, Pkey(\cfmin),
	\amp, 1,
	\out, 0,
).play
)

Although we hear a variety of pitches, each individual Synth is fixed at one particular frequency.

~marimba.stop;

Let's say we want the pitches to be consistent with our chord progression from earlier. In that case, here's an opportunity to reuse the Scale object. Here we create an array of midinotes of an E major scale, convert to cycles per second, and use Prand to choose a random pitch.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Pexprand(0.1, 1, inf),
	\freq, Pexprand(0.25, 9, inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf),
	\cfmax, Pkey(\cfmin),
	\amp, 1,
	\out, 0,
).play
)

~marimba.stop;

Patterns understand mathematical operations like addition, subtraction, and much more, so transposing these pitches is pretty easy. Since this Prand outputs values in cycles per second, we can just multiply by another Prand that outputs octave transposition ratios. In this case the selected pitches can be one octave lower, stay the same, or be one or two octaves higher.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Pexprand(0.1, 1, inf),
	\freq, Pexprand(0.25, 9, inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin),
	\amp, 1,
	\out, 0,
).play
)

~marimba.stop;

To make the rhythmic aspects more regular, we get rid of these two Pexprands, and replace them with more deterministic choices. In this case, a new Synth every second or half second, and the rhythm of each sawtooth wave will be chosen from a random collection of low values with close arithmetic relationships. The slowest rhythm will be one percussive articulation every 2 seconds, and the fastest is 8 per second. And let's also extend the amplitude envelope of each Synth a bit.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1, 0.5],inf),
	\freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
).play
)

~marimba.stop;

Let's say we want to detune these frequencies a bit. We don't actually adjust the detune value for this, because the detune value affects the fundamental frequency, so adjusting detune would actually slightly speed up or slow down the perceived rhythm. Instead, it's the center frequency that controls the perceived frequency, so that's the value we want to modify. Specifically, we'll just multiply the maximum center frequency by some random value slightly larger than 1, so that there's a bit of wiggle room for the center frequencies to move around. The effect here can be a little subtle, but you should be able to hear that the scale degrees are now just slightly out of tune with one another.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1, 0.5],inf),
	\freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, 0,
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025,inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
).play
)

~marimba.stop;

And just to demonstrate how the detune argument actually behaves in this particular case, here you'll notice that when detune deviates away from zero, we no longer have perfect rhythmic synchronization between simultaneous Synths.

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1, 0.5],inf),
	\freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, Pwhite(0, 0.1, inf),
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025,inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
).play;
)

~marimba.stop;

And for the final touch, let's combine these two sounds.

(
~chords = Pbind(
	\instrument, \bpfsaw,
	\dur, Pwhite(4.5, 7.0, inf),
	\midinote, Pxrand([
		[23,35,54,63,64],
		[45,52,54,59,61,64],
		[28,40,47,56,59,63],
		[42,52,57,61,63]
	], inf),
	\detune, Pexprand(0.05, 0.2, inf),
	\cfmin, 100,
	\cfmax, 1500,
	\rqmin, Pexprand(0.01, 0.15, inf),
	\atk, Pwhite(2.0, 2.5, inf),
	\rel, Pwhite(6.5, 10.0, inf),
	\ldb, 6,
	\amp, 0.2,
	\out, 0,
).play;

~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1, 0.5],inf),
	\freq, Prand([1/2, 2/3, 1, 4/3, 2, 5/2, 3, 4, 6, 8], inf),
	\detune, Pwhite(0, 0.1, inf),
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps, inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025,inf),
	\atk, 3,
	\sus, 1,
	\rel, 5,
	\amp, 1,
	\out, 0,
).play;
)

~chords.stop;
~marimba.stop;

That's it for tutorial 15. Generally speaking, these are the sorts of techniques I'll often use when I'm composing a piece or experimenting with sound in SuperCollider. I hope this video gives you some ideas for your own work, or just helps shed some light on the process. In the next video, we'll continue with composition by creating a couple more SynthDefs. One of these SynthDefs will deal with Buffer playback, accompanied by some useful Buffer management strategies. And we'll also create a homemade reverb SynthDef and use it to start putting together a small chain of effects on the audio server. And in the video after that, we'll start putting all the pieces together into something that can be easily performed and edited. As always, thanks so much for watching, and see you next time.