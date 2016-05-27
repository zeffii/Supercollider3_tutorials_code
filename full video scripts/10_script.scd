Hey everyone, welcome to tutorial number 10. In this video I'll be talking about Patterns. To put things very broadly, patterns provide a means of sequencing data through algorithmic and computational processes. Usually, patterns are used to generate a sequence of Synths, allowing the user to dynamically create and manipulate textures, drones, rhythms, and so on. But patterns are not limited to sound synthesis. They can be used to sequence MIDI data, control graphical interfaces, and much more. Because patterns take the idea of sequencing to a fairly abstract level, and because the pattern library is so diverse, it can be difficult to get started with patterns, but fortunately, patterns are one of the most, if not THE most, well-documented aspects of the language.

In the help documentation, under Browse, Streams-Patterns-Events, and at the top, there's A Practical Guide to patterns, written by H. James Harkins. This is a great resource for useful, well-paced, and detailed information about Patterns, and, seriously, you should read it. Also, Ron Kuivila has a chapter on Events and Patterns in the SuperCollider book, which is very thorough, and definitely worth reading as well. There's another tutorial in the help documentation called Understanding Streams, Patterns and Events, and you might also consider taking a look at the Pattern help file, which gives a brief but solid introduction, and some examples. Finally, if you simply want to browse the pattern library yourself, you can click on patterns, and browse by category.

Let's begin with a simple SynthDef which generates a sine wave, pans it in the stereo field, and applies a simple amplitude envelope.

s.boot;

(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

Synth.new(\sine);

I'm going to start with a pattern called Pbind, which responds to the play message by generating a sequence of Events. I'm not going to go into the details of what exactly an Event is, but if you want to learn more, I will refer you again to Harkins' practical guide, in particular, chapter 8.

There are several pre-defined event types, and the default, and most common type is called the note event. A note event simply generates a Synth on the audio server, and we're going to use Pbind to sequence these note events. It's worth taking a look at the Pbind help file, which has some instructive examples, and in particular, there's a section titled SynthDef and Event, which outlines the typical approach to using SynthDef and Pbind together, as we're about to do.

Pbind expects a series of symbol-value pairs, also called key-value pairs. First, we specify the type of event that we want Pbind to generate, in this case, note events.

(
p = Pbind(
	\type, \note,
);
)

Specifying the event type determines the subsequent expected symbols. Since note events generate Synths, we need to tell Pbind which SynthDef we want to use, and this is done with the key, \instrument, followed by the name of the SynthDef. If we play this Pbind now, even without specifying anything like frequency, amplitude, etc, this alone is enough to generate sound.

(
p = Pbind(
	\type, \note,
	\instrument, \sine,
).play;
)

We hear a stream of short sinusoids, at a rate of 1 per second. And we can confirm this by checking the node tree,

s.plotTree;

Pbind.play returns an EventStreamPlayer, and this is the object that actually generates the events. I've stored the player in the global variable p, so I can run p.stop to terminate the stream.

p.stop;

and command-period will also work. Because \note is the default event type, technically we don't need to specify this symbol-value pair. We can just delete it and everything still works.

(
p = Pbind(
	\instrument, \sine,
).play;
)

p.stop;

Because Pbind generates a stream of events, it's only logical that we should be able to control the length of time between successive events. This is usually called delta time, and is specified by providing a value for the \dur key. In the previous example, we didn't specify a value for dur, and so the default value of the note Event was used, which happens to be 1, which is why we heard 1 Synth per second. Here we'll get a Synth every half second:

(
p = Pbind(
	\instrument, \sine,
	\dur, 0.5,
).play;
)

p.stop;

And here's 10 Synths per second.

(
p = Pbind(
	\instrument, \sine,
	\dur, 0.1,
).play;
)

p.stop;

But a constant delta time doesn't really give us much flexibility. Rather than specify a fixed numerical value for dur, we can use a pattern to control the data over time. So let's take a look at a very common pattern called Pseq. Pseq takes an array of values, and sequences through these values, in order, a certain number of times. Here the delta time will output 0.6, 0.15, and 0.15, infinitely.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
).play;
)

p.stop;

Just a quick note here- to print the output of a pattern in real time, we use the trace method. This is useful for debugging, or just visualizing your data.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
).play;
)

p.stop;

We haven't even specified frequency, amplitude, or anything like that, which means Pbind has been using the default values for the keys as defined in the default note event, in particular, we're hearing middle C at an amplitude of 0.1. But because we're generating Synths, this means that the arguments in our SynthDef are available as valid Pbind keys, and these values will override the default event parameters. So let's control the frequency of the sine waves, using another Pseq.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\freq, Pseq([330, 247, 370], inf).trace,
).play;
)

p.stop;

Let's take a step back and make sure we understand what's happening here. Pbind.play returns an EventStreamPlayer, which is creating Synths on the audio server. The delta time and pitch are determined by sequential patterns that repeat infinitely. For each note event, the next item from each internal pattern is embedded into the note event, therefore controlling that particular aspect of the sound.

Suppose the arrays in these two sequential patterns weren't the same size. In this example, these two Pseq's will fall out of phase with each other, but Pbind doesn't know or care. All Pbind does is pull the next value from each of its internal patterns, and creates a Synth with those parameters.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\freq, Pseq([330, 247, 370, 220], inf).trace,
).play;
)

p.stop;

In many cases, we don't want an infinite stream of events, instead we want a particular number of events. The rule here, is that the resulting event stream is only as long as its shortest internal value pattern. So here, if we change the number of repeats in the dur pattern from infinite, to 4, then we'll only get four iterations of that value array, which means 12 note events in total, and then the stream will stop.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], 4).trace,
	\freq, Pseq([330, 247, 370, 220], inf).trace,
).play;
)

If we set the number of repeats of the frequency pattern to, let's say, 2, then it will yield exactly 8 values. This makes the frequency pattern even shorter than the dur pattern, which means the overall eventStreamPlayer created by Pbind will only generate 8 note events:

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], 4).trace,
	\freq, Pseq([330, 247, 370, 220], 2).trace,
).play;
)

p.stop;

So that's the essence of how Pseq works. I want to take this moment to point out that you don't always have to deal in cycles per second. While it is technically possible to convert to midi note numbers like this,

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\freq, Pseq([60, 65, 67, 74].midicps, inf).trace,
).play;
)

p.stop;

You can actually just create a midinote key, and provide midi note numbers as is, like this

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\midinote, Pseq([60, 65, 67, 74], inf).trace,
).play;
)

p.stop;

You might find it sort of surprising that you can use the symbol midinote even though it's not defined in our synthdef. This is possible because there is a hierarchy of predefined keys for certain events, detailed in the Pbind help file. But this hierarchy is only available if you follow the naming conventions here. For example, if you use freq, lowercase f-r-e-q in your SynthDef for the pitch of your sound, then you have the option of using midinote, note, or degree in your Pbind. If you use some other name, like hertz or cycles, then this heirarchy is not available to you. Just to demonstrate this, let's say I use the argument hz instead of freq

(
SynthDef.new(\sine, {
	arg hz=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(hz);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

And then create an eventstreamplayer, midinote gets converted to freq, but neither of these arguments exist in our SynthDef. So the default value for hz, 440, is what we hear.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\midinote, Pseq([60, 65, 67, 74], inf).trace,
).play;
)

p.stop;

To control the pitch of the sound, we'd have to specify a hz pattern explicitly, which is fine, but we would be forgoing the flexibility and convenience of the built-in pitch hierarchy.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\hz, Pseq([330, 247, 370, 220], inf).trace,
).play;
)

p.stop;

So what you should take away from this, is that it is to your advantage to use, in your SynthDefs, the arguments listed in the Pbind help file, such as freq, amp, sustain, etc, although it is not by any means required that you do so. It's also worth noting that when dealing with pitch in a Pbind, you operate at one of these hierarchy levels, for example, you'd use midinote, ctranspose, and harmonic, but generally it's not a good idea to mix and match from different tiers. For example, if you specify a pattern for freq AND a pattern for midinote, well, it just doesn't make sense-- you're simply providing either conflicting or redundant information.

Let's change hz back to freq, and take things in a new direction. In particular, let's talk about some patterns that generate random numbers.

(
SynthDef.new(\sine, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

Pexprand generates a certain number of random values with an exponential distribution, between a given mininum and maximum.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf),
	\freq, Pexprand(50, 4000, inf).trace,
).play;
)

p.stop;

Pwhite, which gets its name from white noise, generates random values within a range, with a linear distribution.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf).trace,
	\freq, Pexprand(50,4000,inf),
).play;
)

p.stop;

Ok, so for the sake of making interesting sound, it's probably about time to add some patterns to control additional SynthDef arguments. Here I'll randomize the attack and release times so that each sine wave is fairly long. Of course, lots of simultaneous signal means we run the risk of clipping, so I'll lower the amplitude significantly, but maintain a bit of randomness there as well. And I'll also randomize the pan position, so that each individual sinusoid is panned randomly in the stereo field, but stays away from extreme left or extreme right.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)

s.plotTree;
p.stop;

Let's take a look at the node tree again,

s.plotTree;

and we can see that the EventStreamPlayer is generating a whole bunch of Synths, and we're finally starting to hear the strength and flexibility of pattern composition.

p.stop;

There's much more to discuss, so let's push forward. Suppose we want these sine waves to align with a harmonic series. Patterns understand mathematical operations and methods, so we can use the round method on the frequency pattern:

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).round(55).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)

p.stop;

We can achieve the same effect with a different tier of pitch symbols, in particular, midinote and harmonic. And I'll also trace the partial number.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\midinote, 33,
	\harmonic, Pexprand(1, 80, inf).round.trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)

p.stop;


And from both of these examples, we can pretty clearly perceive a 55Hz fundamental.

Yknow, these high partials kind of pop out of the texture a little bit more than I'd like, so let's say we want the higher partials to be not quite as loud as the lower ones. Put a different way, we need to have our amplitude pattern rely on the values from the pitch pattern. For this we use the pattern Pkey, which copies values from a pattern at an earlier key, in this case, harmonic. All we need to do now is map these partial numbers onto a range that's suitable for amplitude. And I think I'm just going to take the reciprocal of the partial number, and... I guess multiply by 0.3 to give our signal extra headroom.

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\midinote, 33,
	\harmonic, Pexprand(1, 80, inf).round.trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pkey(\harmonic).reciprocal * 0.3,
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)

p.stop;

One thing we haven't done yet is give ourselves the ability to manipulate patterns in real-time, while the pattern is playing. This is usually done by enclosing a Pbind within a Pdef, the syntax of which is very similar to MIDIdef, and SynthDef. Once inside a Pdef, there's also no longer any need for the global variable.

(
Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, 33,
		\harmonic, Pexprand(1, 80, inf).round.trace,
		\atk, Pwhite(2.0, 3.0, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf),
	);
).play;
)

Once playing, we can simply change the contents of the Pbind, re-evaluate, and the changes take effect without disrupting the event stream.

For example, we can change the fundamental...the maximum partial number...the attack and release times...and we can stop the stream by replacing play with stop

Even if you're not planning on doing real-time pattern manipulation, it's never really a bad idea to use Pdef.

Alright I'm going to do a total switch here and move away from harmonic textures and turn the attention to rhythm. I'm going to change the sound source from sine waves to buffer playback, and I'm actually going to make an entirely new SynthDef. But first, I want to load some sound sources into buffers. So on my desktop I've got a small library of the sounds of an acoustic guitar body being struck in different ways, roughly categorized by low, mid, and high range sounds.

I'm going to use a dictionary to store these sounds, which I usually find to be one of the most flexible options.

(
d = Dictionary.new;
d.add(\low -> PathName.new("/Users/eli/Desktop/knocks/low/").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	})
);
d.add(\mid -> PathName.new("/Users/eli/Desktop/knocks/mid/").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	})
);
d.add(\high -> PathName.new("/Users/eli/Desktop/knocks/high/").entries.collect({
	arg sf;
	Buffer.read(s, sf.fullPath);
	})
);
)

So I've added three keys to dictionary d, and each key points to an array of the appropriate sound files, loaded into buffers. Here are a few random low hits

d[\low].choose.postln.play;

and some high ones

d[\high].choose.postln.play;

And here's my SynthDef. As was the case before, I'm keeping things very simple, with only bufnum, rate, and amplitude arguments.

(
SynthDef.new(\bufplay, {
	arg buf=0, rate=1, amp=1;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf)*rate, doneAction:2);
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)

just to make sure it works:

Synth.new(\bufplay, [\buf, d[\high].choose.bufnum]);

Ok, So let's build another Pbind. First we need the name of the SynthDef, which is bufplay. We also need a pattern for delta time, let's just give ourselves a steady stream of 0.12 seconds per event. Now for which buffer to play, we have some options. We could use Pseq and provide an explicit bufnum order, but I want to take this opportunity to introduce another pattern, called Prand. Unlike Pwhite, which selects a number from a given range, Prand randomly selects an item from a given collection. So I'm just going to concatenate the three arrays within our dictionary, which gives us the low, mid and high sound files, altogether in one array, and then let Prand choose from this array infinitely. For now, I'll set the playback rate and amplitude to be fixed values.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([0.12], inf),
		\buf, Prand(d[\low]++d[\mid]++d[\high], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

If we only want certain buffers, we can just modify the buffer pattern and re-evaluate, since we're inside of a Pdef.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([0.12], inf),
		\buf, Prand(d[\high], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

Pdef(\rhythm).stop;

Often, it's preferable to think about rhythm in terms of beats per minute, rather than floating point second values. And this is pretty easy to do, actually. Let's say we want these soundfiles to roll in as 16th notes at 128 beats per minute in a time signature of 4/4. The first thing I'll do is change the dur pattern so that the raw delta time is literally one 1/16th of our theoretical 4/4 measure. Then, we can use the stretch key, again, this is in the Pbind help file, to stretch the raw delta times by the length, in seconds, of one bar of 4/4 at 128 bpm. So the real question is, how do we calculate seconds per bar from beats per minute?

Well, we start with beats per minute.

128

We can divide by 60 to get beats per second,

128/60

we can invert this value to get seconds per beat

60/128

and since there are four beats per bar, we just multiply this value by 4.

60/128*4

So one bar of 4/4 at 128 bpm lasts exactly 1.875 seconds. Plug that in for the stretch key, and we've got 16th notes at our desired tempo.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\low]++d[\mid]++d[\high], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

I want to quickly throw a few more patterns at you: First, there's Pxrand, which is like Prand, but Pxrand will never choose the same value twice in a row. It's a subtle difference, but worth mentioning.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pxrand(d[\low]++d[\mid]++d[\high], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

There's also Pwrand, which makes random choices according to an array of weights. Here, Pwrand will choose the low sound 80% of the time, the midrange sound 15% of the time, and the high sound 5% of the time.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pwrand([d[\low][0], d[\mid][0], d[\high][0]], [0.8, 0.15, 0.05], inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

Of course, it's not exactly easy to provide an array of weights whose values add up to 1. For this reason, you can append the message noramalizeSum, like this

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pwrand([d[\low][0], d[\mid][0], d[\high][0]], [8, 2, 1].normalizeSum.postln, inf),
		\rate, 1,
		\amp, 0.5,
	);
).play;
)

Pdef(\rhythm).stop;

There's also Pshuf, which takes an array of values and chooses a random order. This means each element in the array gets played exactly once before the pattern repeats. In the interest of moving forward, I'll let you experiment with Pshuf on your own.

Let's go back a few steps and constrain some of this randomness in order to create a more regular accent pattern. Although there are multiple ways to do this, I'm going to manipulate the amplitude pattern. Of course, we could write out something specific with Pseq, like this:

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\l]++d[\m]++d[\h], inf),
		\rate, 1,
		\amp, Pseq([0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1], inf),
	);
).play;
)

which gives us an accent on beats 1 and 3.

But, you know, typing all those 0.1s is kind of lame. So, duplication with the exclamation point is a little bit faster and cleaner

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\low]++d[\mid]++d[\high], inf),
		\rate, 1,
		\amp, Pseq([0.8]++(0.1!7), inf),
	);
).play;
)

But we're ignoring a very important and powerful feature of patterns, which is that we can nest patterns inside of one another. In the following code, the overall amplitude pattern is a Pseq, which contains a value of 0.8, followed by a Pexprand which outputs 7 random values. This means one iteration of the enclosing Pseq will output 8 values in total, and this 8-value sequence is repeated infinitely.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Prand(d[\low]++d[\mid]++d[\high], inf),
		\rate, 1,
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

Doing it this way, we preserve some degree of randomness, while maintaining a consistent and perceivable accent pattern.

Well, Since I've bothered to split these sound files into low, mid, and high ranges, how about this-- Let's always get a low hit on beat 1, and always a high hit on beat three. So here I'll have to change my buf pattern, and again, here's an example of nested patterns.

So I'll start with an overall Pseq, and I'm also gonna space this pattern out on multiple lines for clarity. A low hit on the first beat, 7 16th notes that can be anything, a high hit halfway through the measure, and then 7 more 16th notes we don't really care about, and this overall sequence is repeated over and over.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\low], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
				Prand(d[\high], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
			],inf
		),
		\rate, 1,
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

I think this is starting to sound pretty good. Let's randomize the playback rate a bit to make things just a little less predictable.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\low], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
				Prand(d[\high], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
			],inf
		),
		\rate, Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play;
)

You might notice that the stream has a bit of a hiccup when we re-evaluate the Pdef. This is because we're not quantizing this pattern. Quantization is the process of locking a pattern's onset time to a fixed rhythmic grid.

Pdef(\rhythm).stop;

Since we're dealing with a 4/4 pattern at 128 beats per minute, we should quantize this pattern to a grid as determined by the duration of one bar. This means any changes to the pattern won't take effect until the next downbeat. There are different ways to do this, but here's what I usually do. First, we set the event stream player's quant argument, in parentheses, immediately following the play message, like this.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\low], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
				Prand(d[\high], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
			],inf
		),
		\rate, Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play(quant:1.875);
)

And when I make changes to the Pdef, I use this quantization syntax. Here I'll change the playback rate significantly.

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\low], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
				Prand(d[\high], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
			],inf
		),
		\rate, Pexprand(4.0, 4.1, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).quant_(1.875);
)

And you can hear that these changes only occur when the next downbeat arrives.

Pdef(\rhythm).stop;

Of course, this means you can quantize multiple patterns to the same grid. So, here's a modified version of the sine wave pattern from earlier. But I'm going to start the acoustic guitar pattern first,

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\l], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
				Prand(d[\h], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
			],inf
		),
		\rate, Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play(quant:1.875);
)

And now, whenever I feel like it, I'll start the new sine wave pattern

(
Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, 1/16,
		\stretch, 1.875,
		\note, Pxrand([0,3,5,9,10,12],inf),
		\atk, 0.005,
		\rel, Pexprand(0.01, 0.5, inf),
		\amp, Pexprand(0.05,0.5,inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	)
).play(quant:1.875);
)

Notice that the quant values ensure that these two patterns are locked to the same grid. Let's make a few real-time changes...I'll increase the buffer playback rate, and also transpose the sine waves down a major sixth...Then I'll make the unaccented notes even quieter, and transpose the sine waves up two semitones from their current level...

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 1.875,
		\buf, Pseq(
			[
				Prand(d[\l], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
				Prand(d[\h], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
			],inf
		),
		\rate, Pexprand(3.5, 4.5, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).quant_(1.875);

Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, 1/16,
		\stretch, 1.875,
		\note, Prand([0,3,5,9,10,12],inf),
		\gtranspose, -9,
		\atk, 0.005,
		\rel, Pexprand(0.01, 0.5, inf),
		\amp, Pexprand(0.05,0.7,inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	)
).quant_(1.875);
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
				Prand(d[\low], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
				Prand(d[\high], 1),
				Prand(d[\low]++d[\mid]++d[\high], 7),
			],inf
		),
		\rate, Pexprand(3.5, 4.5, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.01, 7)], inf),
	);
).quant_(1.875);

Pdef(
	\sinepat,
	Pbind(
		\instrument, \sine,
		\dur, 1/16,
		\stretch, 1.875,
		\note, Prand([0,3,5,9,10,12],inf),
		\gtranspose, -7,
		\atk, 0.005,
		\rel, Pexprand(0.01, 0.5, inf),
		\amp, Pexprand(0.05,0.7,inf),
		\pan, Pwhite(-0.8, 0.8, inf),
	)
).quant_(1.875);
)

Pdef(\rhythm).stop;
Pdef(\sinepat).stop;

If you want two or more patterns to just start together, but don't care about synchronization issues after they begin playing, then you can just place your event patterns inside Ppar, which is short for parallel pattern, and play it.

(
p = Pbind(
	\instrument, \bufplay,
	\dur, Pseq([1/16], inf),
	\stretch, 1.875,
	\buf, Pseq(
		[
			Prand(d[\low], 1),
			Prand(d[\low]++d[\mid]++d[\high], 7),
			Prand(d[\high], 1),
			Prand(d[\low]++d[\mid]++d[\high], 7),
		],inf
	),
	\rate, Pexprand(0.8, 1.25, inf),
	\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
);

q = Pbind(
	\instrument, \sine,
	\dur, 1/16,
	\stretch, 1.875,
	\note, Prand([0,3,5,9,10,12],inf),
	\atk, 0.005,
	\rel, Pexprand(0.01, 0.5, inf),
	\amp, Pexprand(0.05,0.5,inf),
	\pan, Pwhite(-0.8, 0.8, inf),
);

x = Ppar([p, q], 1).play;
)

x.stop;

And that's about all for tutorial number 10. As you can probably tell from this video, patterns are incredibly powerful, and there's so much you can do with them. I've covered a lot of new material in this video, but at the same time, there's a lot of material I haven't covered. It's possible I might return to this topic in a later video, but for now, don't forget about H. James Harkins practical guide, and Ron Kuivila's chapter in the SuperCollider book. But, in any case, I hope this video has enough clear information to push you in a direction with enough momentum that you can start making some interesting music with patterns.

In the next video, I'll talk about how SuperCollider integrates with the Open Sound Control protocol, or OSC for short. If you've been enjoying this video series so far, please consider giving a thumbs up and subscribing to my channel. Thanks so much for watching, and see you next time.
