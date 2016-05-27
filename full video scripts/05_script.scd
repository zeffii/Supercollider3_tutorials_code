s.boot;

Hey everyone, welcome to tutorial number 5, where I'll talk about how SuperCollider deals with multichannel sound. You might have noticed that most of the sound we've been producing so far is monophonic, in other words, a single channel of sound being sent to one speaker. Multichannel expansion is a convenient feature of SuperCollider in which an Array of UGens is translated into multiple channels of audio.

Since we're going to be talking about multichannel audio, let's bring up the level meters for inputs and outputs, which we can create by evaluating s.meter or the default shortcut, command-M.

s.meter;

It's probably hard to see since it's so small, but on the left half of this window, there are 8 level meters corresponding to input signals, and on the right, 8 level meters corresponding to output signals. I'm using a separate microphone for recording this tutorial, which is why you don't see the level meters mirroring my voice. You can independently change the number of inputs and outputs, but we don't need to deal with that right now, so I'll save it for another tutorial.

The last thing I'll point out before we dig into multichannel expansion is that there's a help document called Multichannel expansion, which you can read if you want more information.

The essence of multichannel expansion is that whereas a single UGen produces a single channel of audio, an Array of UGens will produce multiple channels of audio. When asked to play a multichannel signal, SuperCollider will output the channels on busses with consecutive, ascending indices. And just to review, an Array is an ordered collection of items, delineated by an enclosure of square brackets, with items separated by commas, such as this.

[1, 2, 3];

For example, we've seen this before. A function like this, with a single UGen will produce a monophonic output on bus zero, as we can see on the levels window.

x = {SinOsc.ar}.play;
x.free;

But if we play an Array of two UGens, SuperCollider translates the array into a two-channel output signal. Because we don't specify otherwise, SuperCollider plays the first signal on output bus 0, and the second on output bus 1.

x = {[SinOsc.ar, SinOsc.ar]}.play;
x.free;

To hear this effect more clearly, we can have these two oscillators run at different frequencies:

x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play;
x.free;

We hear 300Hz in the left speaker, and 500Hz in the right.

This example can be written even more efficiently, by using an internal Array of arguments instead of an Array of UGens. In the following example, we use the Array [300, 500] as the frequency argument, and SuperCollider expands this expression into an Array of two SinOscs in which the frequency values are consecutively distributed, which is essentially identical to the example above:

x = {SinOsc.ar([300, 500])}.play;
x.free;

If we perform mathematical operations involving two multichannel UGens, then the arguments for one UGen will correspond with the arguments for the other UGen. For example, I'll add a two-channel amplitude control signal and multiply it by the audio output.

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7,1]).range(0,1);
	sig = SinOsc.ar([300,500]);
	sig = sig * amp;
}.play;
)

x.free;

When we multiply these two signals together, the first channel of the amplitude control signal is multiplied by the first channel of the audio signal, and the same goes for the 2nd channel of each signal. So as a result, the amplitude of the 300Hz tone in the left speaker fluctuates 7 times per second, while the frequency of the 500Hz tone in the right speaker fluctuates once per second.

If we perform mathematical operations with two multichannel signals that don't have the same number of channels, then the resulting signal will have as many channels as the longer array. The shorter array will wrap back around to the beginning to account for the longer array. So for example, if we multiply a two-channel signal by a one-channel signal, then the one-channel signal will be applied to each of the two-channels in the other signal. In this example, the 7Hz amplitude pulsing is applied to both the 300Hz oscillator and the 500Hz oscillator.

(
x = {
	var amp, sig;
	amp = SinOsc.kr(7).range(0,1);
	sig = SinOsc.ar([300,500]);
	sig = sig * amp;
}.play;
)

x.free;

Of course, we could make arrays that have size greater than two, but if you've only got two speakers, there's not much point since the extra channels have nowhere to go. With this example, even though we can see that SuperCollider is producing five channels, we only hear the first two.

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
}.play;
)

x.free;

There is, however, a UGen called Mix that takes a UGen Array of arbitrary size and mixes the discrete signals down to a single channel. In this case I'm also going to scale the amplitude down to 1/4th to avoid clipping.

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Mix(sig) * 0.25;
}.play;
)

x.free;

Since we're listening to the output of the Mix UGen, we're back to dealing with monophonic sound, so you could consider applying multichannel expansion to the mixed signal, like this

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = [Mix(sig), Mix(sig)] * 0.25;
}.play;
)

x.free;

Now's a good time to introduce the ".dup" method, which when applied to any object, returns an array of duplicates, like this:

60.dup(4);

This means that the above example could be rewritten in the following way:


(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Mix(sig).dup(2) * 0.25;
}.play;
)

x.free;

The exclamation point is available as a syntactical shortcut for .dup

60!4;

So the last line of the above example can also be written like this:

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Mix(sig)!2 * 0.25;
}.play;
)

x.free;

Splay is a UGen somewhat similar to Mix, but instead of mixing down to a single channel, Splay will spread an arbitrarily large array of channels across a stereo field, resulting in a more complex sound. You'll hear it most clearly if you use headphones.

(
x = {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
}.play;
)

x.free;

I want to take a brief detour from this example to illustrate an important nuance of UGen duplication. In the following example, I'm creating pink noise at half-amplitude, and then duplicating this UGen. As a result, an exact copy of the instance of PinkNoise is created, and so we hear the exact same audio in both channels, and we can see this clearly on the output level meters.

x = {PinkNoise.ar(0.5)!2}.play;
x.free;

However, if duplication occurs on an argument within the UGen, then the argument is duplicated, but SuperCollider creates a unique instance of the UGen for each argument. Therefore we can see and hear that the output of each channel is unique. This nuance is less obvious in deterministic UGens like SinOsc, but it's important to bear in mind with noise generators like this.

x = {PinkNoise.ar(0.5!2)}.play;
x.free;

Let's return to the previous example, and I'll convert it into a SynthDef in order to illustrate another common pitfall. Remember that in a SynthDef, if you want to output a signal, you need to include an output UGen. ... So here an important question arises: what do we supply for the bus argument of Out.ar?

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

If we specify bus 0, SuperCollider writes the first channel to this bus, and correctly assumes that we want the remaining channels on consecutive, ascending busses. So this is the correct approach.

It's not uncommon to try something like this, and in fact, it looks pretty reasonable. We've got a stereo signal, and we want to write it to busses 0 and 1:

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar([0,1], sig);
}).add;
)

x = Synth.new(\multi);
x.free;

When we create the Synth, it doesn't necessarily sound wrong, but there's something unusual happening with the level meters.

Here's what's actually happening here. By specifying an array of busses for Out.ar, we are accidentally invoking multichannel expansion on the output UGen, which is already processing a multichannel signal. So as a result, the stereo signal is written to bus 0, which causes it to appear on busses 0 and 1, but it is ALSO being written to bus 1, causing the stereo signal to appear on busses 1 and 2 as well. This means there's signal overlap on bus 1, which is why that level indicator is higher than on bus 0 or 2. So this isn't right at all. The correct approach is to not invoke multichannel expansion on output UGens. Instead, just specify the lowest numbered bus for output UGens, usually zero, and let SuperCollider handle the consecutive distribution of audio channels.

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0,1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

Let's look at duplication of randomly generated numbers. Like the previous example with pink noise, there's a similar but different nuance to keep in mind. In the following example, first, a random number is chosen between 50 and 1200, and then that number is duplicated into an array of size four. So, everytime we evaluate this line, we'll get an array of 4 copies of a randomly generated value

rrand(50,1200)!4;

However, if we surround rrand with curly braces, we create a function, and functions respond to duplication in a different way. The difference is that the contents of the function are evaluated each time it's duplicated, so here we will get an array of uniquely generated random numbers:

{rrand(50,1200)}!4;

Again, it's a subtle difference in syntax, but an important one.

Let's try adding some multichannel randomness to our example. Instead of arrays of fixed values, i'll randomize the amplitudes and frequencies using the technique I just demonstrated. I'll use curly braces to delineate functions, and I'll duplicate them each 8 times.

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr({exprand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({exprand(50,1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

If I take away the curly braces, SuperCollider will create arrays of eight identical numbers, so the complexity of the sound will be greatly reduced. In fact, in this case, each of the 8 channels will be exactly the same, so the whole point of multichannel expansion is lost.

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr(exprand(0.2,12)!8).range(0,1);
	sig = SinOsc.ar(exprand(50,1200)!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

But, using the language operator exprand, even with curly braces, isn't the best option for SynthDefs. Using lowercase exprand in a SynthDef chooses random values when the SynthDef is compiled, and these random values remain fixed, for every instance of Synth that's created. So here, even though I'm creating several Synths, you can hear that the randomly chosen values are the same each time.

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr({exprand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({exprand(50,1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

The best option is to use the UGen ExpRand, with capital E capital R. While lowercase exprand picks values when the SynthDef is compiled, uppercase ExpRand chooses random values when the Synth is created. I'll create multiple synths just like I did a second ago, but here, listen to the unique frequencies and amplitudes of each generated Synth:

(
SynthDef.new(\multi, {
	var amp, sig;
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

You can find more random number generator UGens by looking in Browse, UGens, ... Random.

Just to make things sound extra nice, I'll add an envelope to this SynthDef for a nice smooth 10 second attack and 10 second release. I'll use doneAction:2 so each Synth will free itself when the envelope is complete. Now we can easily create a rich, complex texture of sine waves.

(
SynthDef.new(\multi, {
	var amp, sig, env;
	env = EnvGen.kr(
		Env.new([0,1,0],[10,10],[1,-1]),
		doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!8);
	sig = sig * amp * env;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);

That's it for tutorial number 5. There are lots of other multichannel UGens, which can be found under Browse, UGens, and Multichannel. There are additional categories at the top of the list of Multichannel UGens. Multichannel expansion with Arrays is very powerful, but it can also be difficult to conceptualize. So to conclude, I suggest the best way to grasp multichannel expansion is to experiment with it, and make sure to use the level indicators so you can see what's happening. In the next video I'll talk about iteration in SuperCollider and how it can be used for iterative synthesis. Thanks for watching.